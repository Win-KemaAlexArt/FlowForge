#!/bin/bash

# ===============================================================================
# 🔍 AUDIT-DOCS.SH - Automated Documentation Audit System
# ===============================================================================
# 
# Purpose: Автоматический поиск устаревшего контента в документации FlowForge
# Version: 1.0.0
# Date: 2025-01-11
# Author: FlowForge Auto-Tracking System
#
# AUTO-TRACKING_PROMPT: v1.0
# -------------------------------------------------------------------------------
# ⚡ ИНСТРУКЦИИ ПРИ ОБНОВЛЕНИИ ЭТОГО СКРИПТА:
#
# 1. ПРОВЕРИТЬ связанные документы:
#    - docs/auto-tracking/Sync_Checklist_Template.md
#    - docs/roadmaps/temporary/Temporary_Sync_Roadmap.md
#    - docs/inventory/Documentation_Inventory.md
#
# 2. ЕСЛИ изменилась architectural paradigm:
#    - Обновить PATTERNS ниже
#    - Обновить AUTO_SUGGESTIONS
#    - Документировать изменения
#
# 3. ОБНОВИТЬ дату Last Audit Run в конце скрипта
#
# Current Architectural Paradigm (2025-01-11):
#   - Docker MCP Toolkit (Hybrid Strategy)
#   - GPU Acceleration (10x performance)
#   - FlowForge Variant B Integration
#   - Phase 4 effort: 12-16h (was 25-36h, -60%)
#   - Phase 0.S effort: 2-3h (was 9h, -75%)
#
# Critical Metrics:
#   - GPU Performance: 10x faster (5-10s → 0.5-1s)
#   - Effort Reduction: 60% (Phase 4)
#   - Security: 3x better (9/10 vs 3/10)
#   - Setup Time: 40x faster (30 sec vs 20 min)
#
# Last Sync Check: 2025-01-11
# ===============================================================================

set -euo pipefail

# ===============================================================================
# 🎨 CONFIGURATION
# ===============================================================================

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/docs/audit_reports"

# Exclude patterns
EXCLUDE_DIRS="node_modules|archive_legacy|\.windsurf/\.memory|\.git"

# Output formats
OUTPUT_FORMAT="${1:-table}"  # table | json | detailed | all

# Colors (ANSI)
if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
    RED='\033[0;31m'
    ORANGE='\033[0;33m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' ORANGE='' YELLOW='' GREEN='' BLUE='' BOLD='' RESET=''
fi

# Priority symbols
CRITICAL_SYMBOL="🔴"
HIGH_SYMBOL="🟠"
MEDIUM_SYMBOL="🟡"
LOW_SYMBOL="🟢"
INFO_SYMBOL="ℹ️"

# ===============================================================================
# 📋 AUDIT PATTERNS (6 Categories)
# ===============================================================================

declare -A PATTERNS=(
    # 🔴 CRITICAL - Immediate fix required
    ["CRITICAL_PHASE4_3WEEKS"]="Phase 4.*3 weeks"
    ["CRITICAL_PHASE4_25_36H"]="Phase 4.*25-36h|Phase 4.*25-36 hours"
    ["CRITICAL_STANDALONE_MCP"]="standalone.*MCP|standalone MCP server"
    ["CRITICAL_CUSTOM_CLIENT"]="custom MCP client"
    ["CRITICAL_OLD_DATES"]="2025-01-0[0-9][^-]"
    
    # 🟠 HIGH - Fix within 7 days
    ["HIGH_CPU_ONLY"]="CPU-only|cpu-only"
    ["HIGH_NO_GPU"]="without GPU|no GPU acceleration"
    ["HIGH_OLD_INFERENCE"]="5-10s.*inference|inference.*5-10"
    ["HIGH_OLD_SETUP"]="20 min.*setup|setup.*20 min"
    ["HIGH_NO_DOCKER_MCP"]="MCP.*integration"
    
    # 🟡 MEDIUM - Fix within 14 days
    ["MEDIUM_WRONG_EFFORT"]="25-30% reduction|30% effort"
    ["MEDIUM_WRONG_SECURITY"]="2x.*security|security.*2x"
    ["MEDIUM_VARIANT_A"]="Variant A.*current|FlowForge Variant A"
    
    # 🟢 LOW - Fix when possible
    ["LOW_OLD_METRICS"]="significantly faster|значительно быстрее"
    ["LOW_QUALITATIVE"]="несколько часов|a few hours"
)

declare -A PATTERN_PRIORITIES=(
    ["CRITICAL_PHASE4_3WEEKS"]="CRITICAL"
    ["CRITICAL_PHASE4_25_36H"]="CRITICAL"
    ["CRITICAL_STANDALONE_MCP"]="CRITICAL"
    ["CRITICAL_CUSTOM_CLIENT"]="CRITICAL"
    ["CRITICAL_OLD_DATES"]="CRITICAL"
    
    ["HIGH_CPU_ONLY"]="HIGH"
    ["HIGH_NO_GPU"]="HIGH"
    ["HIGH_OLD_INFERENCE"]="HIGH"
    ["HIGH_OLD_SETUP"]="HIGH"
    ["HIGH_NO_DOCKER_MCP"]="HIGH"
    
    ["MEDIUM_WRONG_EFFORT"]="MEDIUM"
    ["MEDIUM_WRONG_SECURITY"]="MEDIUM"
    ["MEDIUM_VARIANT_A"]="MEDIUM"
    
    ["LOW_OLD_METRICS"]="LOW"
    ["LOW_QUALITATIVE"]="LOW"
)

declare -A AUTO_SUGGESTIONS=(
    ["CRITICAL_PHASE4_3WEEKS"]="Update to 'Phase 4: 12-16h' (60% reduction via Docker MCP)"
    ["CRITICAL_PHASE4_25_36H"]="Update to 'Phase 4: 12-16h' (60% reduction via Docker MCP)"
    ["CRITICAL_STANDALONE_MCP"]="Update to 'Docker MCP Toolkit' approach"
    ["CRITICAL_CUSTOM_CLIENT"]="Use 'Docker MCP Gateway' instead"
    ["CRITICAL_OLD_DATES"]="Update date to >= 2025-01-11"
    
    ["HIGH_CPU_ONLY"]="Add GPU acceleration mention (10x performance)"
    ["HIGH_NO_GPU"]="Add GPU support with fallback to CPU"
    ["HIGH_OLD_INFERENCE"]="Update to 0.5-1s with GPU acceleration"
    ["HIGH_OLD_SETUP"]="Update to 30 sec setup with Docker MCP"
    ["HIGH_NO_DOCKER_MCP"]="Add Docker MCP Toolkit references"
    
    ["MEDIUM_WRONG_EFFORT"]="Update to 60% effort reduction"
    ["MEDIUM_WRONG_SECURITY"]="Update to 3x security improvement"
    ["MEDIUM_VARIANT_A"]="Update to FlowForge Variant B"
    
    ["LOW_OLD_METRICS"]="Use quantitative metrics (10x, 60%, etc)"
    ["LOW_QUALITATIVE"]="Replace with specific hours (e.g., 2-3h)"
)

# ===============================================================================
# 🛠️ UTILITY FUNCTIONS
# ===============================================================================

print_header() {
    echo -e "${BLUE}${BOLD}"
    echo "🔍 AUDIT REPORT: FlowForge Documentation"
    echo "==========================================="
    echo -e "${RESET}"
}

print_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    
    printf "\r${BLUE}Progress: [${GREEN}"
    printf "%${filled}s" | tr ' ' '█'
    printf "${RESET}"
    printf "%${empty}s" | tr ' ' '░'
    printf "${BLUE}] ${percent}%% (${current}/${total} files)${RESET}"
}

colorize_priority() {
    local priority=$1
    case $priority in
        "CRITICAL") echo -e "${RED}${CRITICAL_SYMBOL} CRITICAL${RESET}" ;;
        "HIGH")     echo -e "${ORANGE}${HIGH_SYMBOL} HIGH${RESET}" ;;
        "MEDIUM")   echo -e "${YELLOW}${MEDIUM_SYMBOL} MEDIUM${RESET}" ;;
        "LOW")      echo -e "${GREEN}${LOW_SYMBOL} LOW${RESET}" ;;
        *)          echo -e "${INFO_SYMBOL} ${priority}" ;;
    esac
}

# ===============================================================================
# 📊 MAIN AUDIT FUNCTION
# ===============================================================================

run_audit() {
    local start_time=$(date +%s)
    
    print_header
    echo -e "${BLUE}Scanning: ${ROOT_DIR}${RESET}"
    echo -e "${BLUE}Exclude: ${EXCLUDE_DIRS}${RESET}"
    echo -e "${BLUE}Patterns: ${#PATTERNS[@]}${RESET}"
    echo ""
    
    # Find all .md files
    local md_files=()
    while IFS= read -r -d '' file; do
        md_files+=("$file")
    done < <(find "$ROOT_DIR" -type f -name "*.md" \
        -not -path "*/node_modules/*" \
        -not -path "*/archive_legacy/*" \
        -not -path "*/.windsurf/.memory/*" \
        -not -path "*/.git/*" \
        -print0)
    
    local total_files=${#md_files[@]}
    echo -e "${BLUE}Found: ${total_files} .md files${RESET}\n"
    
    # Results storage
    declare -A results
    local issue_count=0
    local files_with_issues=0
    declare -A priority_counts=(["CRITICAL"]=0 ["HIGH"]=0 ["MEDIUM"]=0 ["LOW"]=0)
    
    # Scan each file
    local current=0
    for file in "${md_files[@]}"; do
        ((current++))
        print_progress $current $total_files
        
        local rel_path="${file#$ROOT_DIR/}"
        local file_has_issues=false
        
        # Check each pattern
        for pattern_name in "${!PATTERNS[@]}"; do
            local pattern="${PATTERNS[$pattern_name]}"
            local priority="${PATTERN_PRIORITIES[$pattern_name]}"
            local suggestion="${AUTO_SUGGESTIONS[$pattern_name]}"
            
            # Search pattern with line numbers
            while IFS=: read -r line_num context; do
                if [[ -n "$context" ]]; then
                    # Store result
                    local key="${issue_count}"
                    results["${key}_file"]="$rel_path"
                    results["${key}_line"]="$line_num"
                    results["${key}_priority"]="$priority"
                    results["${key}_pattern"]="$pattern_name"
                    results["${key}_context"]="$context"
                    results["${key}_suggestion"]="$suggestion"
                    
                    ((issue_count++))
                    ((priority_counts[$priority]++))
                    file_has_issues=true
                fi
            done < <(grep -n -E "$pattern" "$file" 2>/dev/null || true)
        done
        
        if [[ "$file_has_issues" == true ]]; then
            ((files_with_issues++))
        fi
    done
    
    echo "" # New line after progress
    
    # Calculate metrics
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local clean_files=$((total_files - files_with_issues))
    local clean_percentage=$((clean_files * 100 / total_files))
    
    # Output results based on format
    case $OUTPUT_FORMAT in
        "table")
            output_table results $issue_count priority_counts $total_files $files_with_issues $clean_files $clean_percentage $duration
            ;;
        "json")
            output_json results $issue_count priority_counts $total_files $files_with_issues $clean_files $duration
            ;;
        "detailed")
            output_detailed results $issue_count priority_counts $total_files $files_with_issues $clean_files $duration
            ;;
        "all")
            output_table results $issue_count priority_counts $total_files $files_with_issues $clean_files $clean_percentage $duration
            echo ""
            output_json results $issue_count priority_counts $total_files $files_with_issues $clean_files $duration > "$OUTPUT_DIR/audit_report.json"
            output_detailed results $issue_count priority_counts $total_files $files_with_issues $clean_files $duration > "$OUTPUT_DIR/audit_report_detailed.md"
            echo -e "\n${GREEN}✅ Reports saved to: $OUTPUT_DIR/${RESET}"
            ;;
    esac
}

# ===============================================================================
# 📊 OUTPUT FUNCTIONS
# ===============================================================================

output_table() {
    local -n res=$1
    local count=$2
    local -n prio=$3
    local total=$4
    local with_issues=$5
    local clean=$6
    local clean_pct=$7
    local dur=$8
    
    echo ""
    echo -e "${BOLD}Scanned: ${total} files | Issues: ${count} | Time: ${dur}s${RESET}"
    echo ""
    
    if [[ $count -gt 0 ]]; then
        # Print table header
        printf "%-12s %-40s %-6s %-25s\n" "Priority" "File" "Line" "Pattern"
        echo "────────────────────────────────────────────────────────────────────────────────────"
        
        # Sort and print by priority
        for priority in "CRITICAL" "HIGH" "MEDIUM" "LOW"; do
            for ((i=0; i<count; i++)); do
                if [[ "${res[${i}_priority]}" == "$priority" ]]; then
                    local pri_colored=$(colorize_priority "$priority")
                    local file="${res[${i}_file]}"
                    local line="${res[${i}_line]}"
                    local pattern="${res[${i}_pattern]}"
                    
                    # Truncate filename if too long
                    if [[ ${#file} -gt 38 ]]; then
                        file="...${file: -35}"
                    fi
                    
                    printf "%-22s %-40s %-6s %-25s\n" "$pri_colored" "$file" "$line" "${pattern#*_}"
                fi
            done
        done
    fi
    
    echo ""
    echo -e "${BOLD}📊 SUMMARY:${RESET}"
    echo -e "${RED}${CRITICAL_SYMBOL} CRITICAL: ${prio[CRITICAL]}${RESET}  ${ORANGE}${HIGH_SYMBOL} HIGH: ${prio[HIGH]}${RESET}  ${YELLOW}${MEDIUM_SYMBOL} MEDIUM: ${prio[MEDIUM]}${RESET}  ${GREEN}${LOW_SYMBOL} LOW: ${prio[LOW]}${RESET}"
    echo -e "${GREEN}✅ Clean: ${clean} files (${clean_pct}%)${RESET}  ${RED}❌ Issues: ${with_issues} files${RESET}"
}

output_json() {
    local -n res=$1
    local count=$2
    local -n prio=$3
    local total=$4
    local with_issues=$5
    local clean=$6
    local dur=$7
    
    echo "{"
    echo "  \"audit_report\": {"
    echo "    \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
    echo "    \"scanned_files\": $total,"
    echo "    \"total_issues\": $count,"
    echo "    \"duration_seconds\": $dur,"
    echo "    \"issues_by_priority\": {"
    echo "      \"CRITICAL\": ${prio[CRITICAL]},"
    echo "      \"HIGH\": ${prio[HIGH]},"
    echo "      \"MEDIUM\": ${prio[MEDIUM]},"
    echo "      \"LOW\": ${prio[LOW]}"
    echo "    },"
    echo "    \"files_with_issues\": $with_issues,"
    echo "    \"clean_files\": $clean,"
    echo "    \"details\": ["
    
    for ((i=0; i<count; i++)); do
        local comma=","
        [[ $i -eq $((count-1)) ]] && comma=""
        
        echo "      {"
        echo "        \"file\": \"${res[${i}_file]}\","
        echo "        \"line\": ${res[${i}_line]},"
        echo "        \"priority\": \"${res[${i}_priority]}\","
        echo "        \"pattern\": \"${res[${i}_pattern]}\","
        echo "        \"context\": \"${res[${i}_context]}\","
        echo "        \"suggestion\": \"${res[${i}_suggestion]}\""
        echo "      }$comma"
    done
    
    echo "    ]"
    echo "  }"
    echo "}"
}

output_detailed() {
    local -n res=$1
    local count=$2
    local -n prio=$3
    local total=$4
    local with_issues=$5
    local clean=$6
    local dur=$7
    
    echo "# 📋 DETAILED AUDIT REPORT"
    echo ""
    echo "**Date:** $(date +"%Y-%m-%d %H:%M:%S")"
    echo "**Duration:** ${dur}s"
    echo "**Files Scanned:** $total"
    echo "**Total Issues:** $count"
    echo ""
    echo "## 📊 Summary"
    echo ""
    echo "- 🔴 **CRITICAL:** ${prio[CRITICAL]} issues"
    echo "- 🟠 **HIGH:** ${prio[HIGH]} issues"
    echo "- 🟡 **MEDIUM:** ${prio[MEDIUM]} issues"
    echo "- 🟢 **LOW:** ${prio[LOW]} issues"
    echo "- ✅ **Clean Files:** $clean ($((clean * 100 / total))%)"
    echo "- ❌ **Files with Issues:** $with_issues ($((with_issues * 100 / total))%)"
    echo ""
    
    for priority in "CRITICAL" "HIGH" "MEDIUM" "LOW"; do
        local prio_count=${prio[$priority]}
        if [[ $prio_count -gt 0 ]]; then
            echo "## ${priority} Issues ($prio_count)"
            echo ""
            
            local issue_num=1
            for ((i=0; i<count; i++)); do
                if [[ "${res[${i}_priority]}" == "$priority" ]]; then
                    echo "### $issue_num. ${res[${i}_file]}:${res[${i}_line]}"
                    echo ""
                    echo "**Pattern:** \`${res[${i}_pattern]}\`"
                    echo ""
                    echo "**Context:**"
                    echo "\`\`\`"
                    echo "${res[${i}_context]}"
                    echo "\`\`\`"
                    echo ""
                    echo "**Suggestion:** ${res[${i}_suggestion]}"
                    echo ""
                    ((issue_num++))
                fi
            done
        fi
    done
}

# ===============================================================================
# 🚀 MAIN EXECUTION
# ===============================================================================

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Show help if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [FORMAT]"
    echo ""
    echo "Formats:"
    echo "  table     Interactive table (default)"
    echo "  json      JSON export"
    echo "  detailed  Detailed markdown report"
    echo "  all       All formats (saves to files)"
    echo ""
    echo "Example:"
    echo "  $0 table"
    echo "  $0 json > report.json"
    echo "  $0 all"
    exit 0
fi

# Run audit
run_audit

# Exit code based on critical issues
if [[ ${priority_counts[CRITICAL]:-0} -gt 0 ]]; then
    exit 1
else
    exit 0
fi
