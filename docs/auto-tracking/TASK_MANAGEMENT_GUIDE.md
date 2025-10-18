# 📋 TASK MANAGEMENT GUIDE - FlowForge

**Version:** 1.0.0  
**Date:** 2025-01-16  
**Purpose:** Руководство по task-oriented workflow с автоматизацией

---

## 🎯 КОНЦЕПЦИЯ

**Цель:** Канбан-подход к roadmap management с автоматическим отслеживанием прогресса

**Принципы:**
1. Каждая задача = отдельный .md файл с checkboxes
2. MASTER-ROADMAP.md = high-level kanban с линками на задачи
3. Автоматическое обновление roadmap при завершении задач
4. Архивация завершенных задач с сохранением ссылок

---

## 📐 СТРУКТУРА

```
FlowForge/
├── MASTER-ROADMAP.md              # High-level kanban
├── tasks/                         # Все активные задачи
│   ├── phase_0.S/
│   │   ├── 0.S.1_docker_compose_setup.md
│   │   ├── 0.S.2_gpu_configuration.md
│   │   └── 0.S.3_monitoring_setup.md
│   ├── playragna/
│   │   └── phase_3.2_ragna_integration.md
│   └── workflow-engine/
│       └── phase_0.3_cli_core.md
├── archive/                       # Завершенные задачи
│   └── phase_0.R/
│       └── 0.R_docker_mcp_research.md
└── scripts/
    └── task-manager.py            # Автоматизация
```

---

## 🔄 WORKFLOW

### Создание новой задачи

1. **Создать task file:**
```bash
# Template structure
cp docs/auto-tracking/TASK_TEMPLATE.md tasks/phase_X.X/X.X.Y_task_name.md
```

2. **Заполнить метаданные:**
```markdown
# Task X.X.Y: Task Name

**Phase:** X.X
**Owner:** Team name
**Effort:** N hours
**Priority:** 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW
**Status:** ⏳ PENDING

## ✅ SUB-TASKS
- [ ] Sub-task 1 (30 min)
- [ ] Sub-task 2 (1h)
- [ ] Sub-task 3 (30 min)
```

3. **Добавить линк в MASTER-ROADMAP.md:**
```markdown
**Tasks:**
- [ ] [X.X.Y: Task Name](tasks/phase_X.X/X.X.Y_task_name.md) (Nh)
```

---

### Работа над задачей

1. **Отмечать выполненные sub-tasks:**
```markdown
## ✅ SUB-TASKS
- [x] Sub-task 1 (30 min) ✅
- [ ] Sub-task 2 (1h)
- [ ] Sub-task 3 (30 min)
```

2. **Запустить синхронизацию:**
```bash
python scripts/task-manager.py scan
# → Автоматически обновит progress в roadmap
```

---

### Завершение задачи

1. **Все checkboxes = [x]:**
```markdown
## ✅ SUB-TASKS
- [x] Sub-task 1 (30 min) ✅
- [x] Sub-task 2 (1h) ✅
- [x] Sub-task 3 (30 min) ✅
```

2. **Автоматическое обновление roadmap:**
```bash
python scripts/task-manager.py scan
# → MASTER-ROADMAP.md: - [ ] → - [x]
```

3. **Архивация (опционально):**
```bash
python scripts/task-manager.py archive
# → Переместит в archive/phase_X.X/
```

---

## 🛠️ КОМАНДЫ

### scan - Сканирование и обновление
```bash
python scripts/task-manager.py scan
```
**Действия:**
- Сканирует все task files
- Подсчитывает [x] vs [ ]
- Обновляет checkboxes в MASTER-ROADMAP.md

**Когда использовать:** После каждого commit с изменениями в task files

---

### validate - Проверка зависимостей
```bash
python scripts/task-manager.py validate
```
**Действия:**
- Проверяет blocking dependencies
- Выявляет race conditions (task started без завершения dependencies)
- Возвращает error code если есть проблемы

**Когда использовать:** Перед началом работы над новой задачей

---

### archive - Архивация завершенных
```bash
python scripts/task-manager.py archive
```
**Действия:**
- Находит задачи с 100% completion
- Перемещает в `archive/{phase}/`
- Сохраняет ссылочную целостность (links остаются рабочими)

**Когда использовать:** После завершения целой фазы или еженедельно

---

### report - Статус отчет
```bash
python scripts/task-manager.py report
```
**Действия:**
- Генерирует ASCII progress bars
- Группирует задачи по фазам
- Показывает статус (⏳/🔄/✅)

**Когда использовать:** Для weekly status meetings или personal tracking

---

## 📊 ПРИМЕРЫ

### Пример 1: Начало работы над Phase 0.S

```bash
# 1. Проверить зависимости
python scripts/task-manager.py validate
# ✅ All dependencies valid

# 2. Открыть task file
code tasks/phase_0.S/0.S.1_docker_compose_setup.md

# 3. Работать над задачей, отмечая checkboxes
# - [x] Create shared-infrastructure/ directory
# - [x] Write docker-compose.yml
# - [ ] Create .env.example

# 4. Синхронизировать roadmap
python scripts/task-manager.py scan
# ✅ Updated 1 task status in MASTER-ROADMAP.md

# 5. Commit changes
git add tasks/phase_0.S/ MASTER-ROADMAP.md
git commit -m "Phase 0.S.1: Progress 2/5 sub-tasks"
```

---

### Пример 2: Завершение задачи

```bash
# Все checkboxes = [x]
python scripts/task-manager.py scan
# ✅ Updated 1 task status in MASTER-ROADMAP.md

# Проверка результата
git diff MASTER-ROADMAP.md
# -  - [ ] [0.S.1: Docker Compose Setup](tasks/...)
# +  - [x] [0.S.1: Docker Compose Setup](tasks/...)

# Commit
git commit -am "Phase 0.S.1: COMPLETE ✅"
```

---

### Пример 3: Еженедельный статус

```bash
# Генерировать отчет
python scripts/task-manager.py report

# Output:
# 📊 FLOWFORGE TASK STATUS REPORT
# ======================================================================
# 
# 📁 phase_0.S/
# ----------------------------------------------------------------------
#   ✅ 0.S.1: Docker Compose Stack Setup
#      Progress: [████████████████████] 100% (5/5)
#   🔄 0.S.2: GPU Acceleration Configuration
#      Progress: [████████░░░░░░░░░░░░] 40% (2/5)
#   ⏳ 0.S.3: Monitoring & Observability Setup
#      Progress: [░░░░░░░░░░░░░░░░░░░░] 0% (0/3)
```

---

## 🔗 INTEGRATION

### Git Hooks (Recommended)

**Pre-commit hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Validate dependencies before commit
python scripts/task-manager.py validate
if [ $? -ne 0 ]; then
    echo "❌ Dependency validation failed"
    exit 1
fi

# Auto-sync roadmap
python scripts/task-manager.py scan
git add MASTER-ROADMAP.md
```

**Post-merge hook:**
```bash
#!/bin/bash
# .git/hooks/post-merge

# Re-scan after merging
python scripts/task-manager.py scan
echo "✅ Roadmap synchronized after merge"
```

---

### GitHub Actions

**Workflow:** `.github/workflows/task-sync.yml`
```yaml
name: Task Sync Validation
on:
  pull_request:
    paths:
      - 'tasks/**/*.md'
      - 'MASTER-ROADMAP.md'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Validate Dependencies
        run: python scripts/task-manager.py validate
      
      - name: Check Roadmap Sync
        run: |
          python scripts/task-manager.py scan
          git diff --exit-code MASTER-ROADMAP.md || \
            (echo "❌ Roadmap out of sync" && exit 1)
```

---

## 📏 BEST PRACTICES

### 1. Task Granularity
```yaml
✅ GOOD:
  - Task effort: 1-5 hours
  - Sub-tasks: 5-15 items
  - Clear acceptance criteria
  
❌ BAD:
  - Monolithic tasks (>8h)
  - Vague sub-tasks ("Implement feature")
  - No measurable criteria
```

### 2. Dependencies
```yaml
✅ GOOD:
  - Explicit blocking links: [Task X](../phase/task.md)
  - Validated before starting work
  - Clear dependency tree
  
❌ BAD:
  - Implicit dependencies (not documented)
  - Circular dependencies
  - Missing blocked-by relationships
```

### 3. Progress Tracking
```yaml
✅ GOOD:
  - Commit after each completed sub-task
  - Run scan after each commit
  - Weekly reports for visibility
  
❌ BAD:
  - Batch updates at phase end
  - Manual roadmap editing
  - No progress visibility
```

---

## 🚨 TROUBLESHOOTING

### Issue: Roadmap not updating

**Symptom:** `scan` runs but MASTER-ROADMAP.md unchanged

**Причины:**
1. Task ID mismatch (filename vs roadmap link)
2. Path mismatch (relative paths incorrect)
3. Checkbox format incorrect (not `- [ ]` or `- [x]`)

**Solution:**
```bash
# Debug mode (add to task-manager.py)
python scripts/task-manager.py scan --debug
```

---

### Issue: Dependency validation fails

**Symptom:** `validate` returns errors

**Пример:**
```
⚠️ Task 0.S.2 depends on incomplete task 0.S.1 (60% complete)
```

**Solution:**
- Complete dependency first OR
- Update dependency tree if incorrect

---

### Issue: Archive breaks links

**Symptom:** Links to archived tasks return 404

**Solution:** Archive preserves relative links
```markdown
# Before archive
[0.S.1](tasks/phase_0.S/0.S.1_file.md)

# After archive
[0.S.1](archive/phase_0.S/0.S.1_file.md)

# Tool updates links automatically
```

---

## 📚 TEMPLATE

**Task Template:** `docs/auto-tracking/TASK_TEMPLATE.md`
```markdown
# Task X.X.Y: Task Name

**Phase:** X.X  
**Owner:** Team  
**Effort:** N hours  
**Priority:** 🔴/🟠/🟡/🟢  
**Status:** ⏳ PENDING

---

## 🎯 OBJECTIVE
[What this task achieves]

---

## ✅ SUB-TASKS
- [ ] Sub-task 1 (time)
- [ ] Sub-task 2 (time)

---

## 🎯 ACCEPTANCE CRITERIA
- [ ] Criterion 1
- [ ] Criterion 2

---

## 🔗 DEPENDENCIES
**Blocks:** [Task Y](../phase/task_y.md)
**Blocked By:** [Task Z](../phase/task_z.md)

---

**Parent:** [MASTER-ROADMAP.md](../../MASTER-ROADMAP.md)
```

---

## ✅ CHECKLIST: Начало работы

```yaml
Setup (one-time):
  ☐ Установить Python 3.8+ (check: python --version)
  ☐ Создать структуру tasks/ (check: ls tasks/)
  ☐ Протестировать task-manager.py (run: python scripts/task-manager.py report)
  ☐ Настроить git hooks (optional)
  
Daily workflow:
  ☐ Выбрать задачу из tasks/
  ☐ Проверить dependencies (validate)
  ☐ Работать над sub-tasks
  ☐ Отмечать [x] по мере выполнения
  ☐ Commit + scan после каждой sub-task
  
Weekly:
  ☐ Генерировать report
  ☐ Архивировать completed tasks
  ☐ Планировать следующие задачи
```

---

**Version:** 1.0.0  
**Last Updated:** 2025-01-16  
**Maintainer:** FlowForge Core Team
