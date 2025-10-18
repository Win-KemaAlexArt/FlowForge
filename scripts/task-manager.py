#!/usr/bin/env python3
"""
mini-gmenicli - Task Management Core for FlowForge
Автоматическое отслеживание выполнения тасков и синхронизация roadmap

Usage:
    python task-manager.py scan              # Scan all tasks and update roadmap
    python task-manager.py validate          # Validate dependencies
    python task-manager.py archive           # Archive completed tasks
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Tuple
from dataclasses import dataclass

@dataclass
class Task:
    """Представление задачи"""
    file_path: Path
    task_id: str
    title: str
    status: str  # PENDING, IN_PROGRESS, COMPLETED
    checkboxes_total: int
    checkboxes_done: int
    dependencies: List[str]
    
    @property
    def is_completed(self) -> bool:
        """Проверка завершена ли задача"""
        return (self.checkboxes_total > 0 and 
                self.checkboxes_done == self.checkboxes_total)
    
    @property
    def progress(self) -> float:
        """Прогресс выполнения (0.0-1.0)"""
        if self.checkboxes_total == 0:
            return 0.0
        return self.checkboxes_done / self.checkboxes_total


class TaskManager:
    """Core task management system"""
    
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.tasks_dir = self.project_root / "tasks"
        self.roadmap_path = self.project_root / "MASTER-ROADMAP.md"
        self.archive_dir = self.project_root / "archive"
        
    def scan_tasks(self) -> List[Task]:
        """Сканирует все task files и возвращает список задач"""
        tasks = []
        
        for task_file in self.tasks_dir.rglob("*.md"):
            task = self._parse_task_file(task_file)
            if task:
                tasks.append(task)
        
        return tasks
    
    def _parse_task_file(self, file_path: Path) -> Task:
        """Парсит task file и извлекает метаданные"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract task ID from filename (e.g., "0.S.1_docker_compose_setup.md" -> "0.S.1")
        task_id = file_path.stem.split('_')[0]
        
        # Extract title (first # heading)
        title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
        title = title_match.group(1) if title_match else file_path.stem
        
        # Extract status
        status_match = re.search(r'\*\*Status:\*\* (.+?)(?:\s|$)', content)
        status_emoji = status_match.group(1) if status_match else "⏳ PENDING"
        
        # Map emoji to status
        if "✅" in status_emoji or "COMPLETED" in status_emoji:
            status = "COMPLETED"
        elif "🔄" in status_emoji or "IN_PROGRESS" in status_emoji:
            status = "IN_PROGRESS"
        else:
            status = "PENDING"
        
        # Count checkboxes
        checkboxes_done = len(re.findall(r'- \[x\]', content, re.IGNORECASE))
        checkboxes_pending = len(re.findall(r'- \[ \]', content))
        checkboxes_total = checkboxes_done + checkboxes_pending
        
        # Extract dependencies (links to other tasks)
        dependencies = []
        dep_matches = re.findall(r'\[([^\]]+)\]\(\.\.\/[^\)]+\/([^\/\)]+)\.md\)', content)
        for _, task_file in dep_matches:
            dep_id = task_file.split('_')[0]
            dependencies.append(dep_id)
        
        return Task(
            file_path=file_path,
            task_id=task_id,
            title=title,
            status=status,
            checkboxes_total=checkboxes_total,
            checkboxes_done=checkboxes_done,
            dependencies=dependencies
        )
    
    def update_roadmap_status(self, tasks: List[Task]):
        """Обновляет статусы задач в MASTER-ROADMAP.md"""
        if not self.roadmap_path.exists():
            print(f"❌ Roadmap not found: {self.roadmap_path}")
            return
        
        with open(self.roadmap_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        updated_count = 0
        
        for task in tasks:
            # Find task reference in roadmap and update checkbox
            # Pattern: - [ ] [Task Title](tasks/phase_0.S/0.S.1_file.md)
            pattern = rf'(- \[[ x]\] \[[^\]]+\]\(tasks/[^/]+/{re.escape(task.task_id)}_[^\)]+\.md\))'
            
            def replace_checkbox(match):
                nonlocal updated_count
                old_line = match.group(1)
                
                # Determine new checkbox state
                if task.is_completed:
                    new_checkbox = "[x]"
                elif task.progress > 0:
                    new_checkbox = "[ ]"  # Keep pending but could add progress indicator
                else:
                    new_checkbox = "[ ]"
                
                # Replace checkbox
                new_line = re.sub(r'\[[ x]\]', new_checkbox, old_line, count=1)
                
                if old_line != new_line:
                    updated_count += 1
                
                return new_line
            
            content = re.sub(pattern, replace_checkbox, content)
        
        if content != original_content:
            with open(self.roadmap_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Updated {updated_count} task statuses in MASTER-ROADMAP.md")
        else:
            print("✅ No roadmap updates needed (all statuses current)")
    
    def validate_dependencies(self, tasks: List[Task]) -> List[str]:
        """Валидирует блокирующие зависимости"""
        errors = []
        task_map = {task.task_id: task for task in tasks}
        
        for task in tasks:
            if task.status == "IN_PROGRESS" or task.is_completed:
                # Check if all dependencies are completed
                for dep_id in task.dependencies:
                    if dep_id not in task_map:
                        errors.append(f"❌ Task {task.task_id}: Dependency {dep_id} not found")
                        continue
                    
                    dep_task = task_map[dep_id]
                    if not dep_task.is_completed:
                        errors.append(
                            f"⚠️  Task {task.task_id} depends on incomplete task {dep_id} "
                            f"({dep_task.progress*100:.0f}% complete)"
                        )
        
        return errors
    
    def archive_completed_tasks(self, tasks: List[Task]):
        """Архивирует завершенные задачи"""
        archived_count = 0
        
        for task in tasks:
            if task.is_completed:
                # Determine archive path
                phase = task.file_path.parent.name
                archive_phase_dir = self.archive_dir / phase
                archive_phase_dir.mkdir(parents=True, exist_ok=True)
                
                archive_path = archive_phase_dir / task.file_path.name
                
                # Don't archive if already in archive
                if "archive" in str(task.file_path):
                    continue
                
                # Move file to archive
                task.file_path.rename(archive_path)
                archived_count += 1
                print(f"📦 Archived: {task.task_id} → {archive_path.relative_to(self.project_root)}")
        
        if archived_count == 0:
            print("✅ No completed tasks to archive")
    
    def generate_report(self, tasks: List[Task]):
        """Генерирует отчет о статусе задач"""
        print("\n" + "="*70)
        print("📊 FLOWFORGE TASK STATUS REPORT")
        print("="*70 + "\n")
        
        # Group by phase
        phases = {}
        for task in tasks:
            phase = task.file_path.parent.name
            if phase not in phases:
                phases[phase] = []
            phases[phase].append(task)
        
        # Print by phase
        for phase, phase_tasks in sorted(phases.items()):
            print(f"📁 {phase}/")
            print("-" * 70)
            
            for task in sorted(phase_tasks, key=lambda t: t.task_id):
                status_icon = {
                    "COMPLETED": "✅",
                    "IN_PROGRESS": "🔄",
                    "PENDING": "⏳"
                }.get(task.status, "❓")
                
                progress_bar = self._progress_bar(task.progress)
                
                print(f"  {status_icon} {task.task_id}: {task.title}")
                print(f"     Progress: {progress_bar} {task.progress*100:.0f}% "
                      f"({task.checkboxes_done}/{task.checkboxes_total})")
            
            print()
    
    def _progress_bar(self, progress: float, width: int = 20) -> str:
        """Генерирует ASCII progress bar"""
        filled = int(progress * width)
        bar = "█" * filled + "░" * (width - filled)
        return f"[{bar}]"


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python task-manager.py [scan|validate|archive|report]")
        sys.exit(1)
    
    command = sys.argv[1]
    manager = TaskManager()
    
    if command == "scan":
        print("🔍 Scanning tasks...")
        tasks = manager.scan_tasks()
        print(f"✅ Found {len(tasks)} tasks")
        manager.update_roadmap_status(tasks)
    
    elif command == "validate":
        print("🔍 Validating dependencies...")
        tasks = manager.scan_tasks()
        errors = manager.validate_dependencies(tasks)
        
        if errors:
            print(f"\n❌ Found {len(errors)} dependency issues:\n")
            for error in errors:
                print(f"  {error}")
            sys.exit(1)
        else:
            print("✅ All dependencies valid")
    
    elif command == "archive":
        print("📦 Archiving completed tasks...")
        tasks = manager.scan_tasks()
        manager.archive_completed_tasks(tasks)
    
    elif command == "report":
        print("📊 Generating task report...")
        tasks = manager.scan_tasks()
        manager.generate_report(tasks)
    
    else:
        print(f"❌ Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
