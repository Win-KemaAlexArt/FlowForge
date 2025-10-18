# ===============================================================================
# 🔍 AUDIT-DOCS.PS1 - Automated Documentation Audit System (PowerShell)
# ===============================================================================
# 
# Purpose: Автоматический поиск устаревшего контента в документации FlowForge
# Version: 1.0.0
# Date: 2025-01-11
# Author: FlowForge Auto-Tracking System
# Platform: Windows PowerShell 5.1+
#
# AUTO-TRACKING_PROMPT: v1.0
# -------------------------------------------------------------------------------
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

param(
    [string]$Format = "table"  # table | json | detailed | all
)

# ===============================================================================
# 🎨 CONFIGURATION
# ===============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$OutputDir = Join-Path $RootDir "docs\audit_reports"

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# ===============================================================================
# 📋 AUDIT PATTERNS
# ===============================================================================

$Patterns = @{
    # 🔴 CRITICAL
    "CRITICAL_PHASE4_3WEEKS" = @{
        Pattern = "Phase 4.*3 weeks"
        Priority = "CRITICAL"
        Suggestion = "Update to 'Phase 4: 12-16h' (60% reduction via Docker MCP)"
    }
    "CRITICAL_PHASE4_25_36H" = @{
        Pattern = "Phase 4.*(25-36h|25-36 hours)"
        Priority = "CRITICAL"
        Suggestion = "Update to 'Phase 4: 12-16h' (60% reduction via Docker MCP)"
    }
    "CRITICAL_STANDALONE_MCP" = @{
        Pattern = "standalone.*MCP|standalone MCP server"
        Priority = "CRITICAL"
        Suggestion = "Update to 'Docker MCP Toolkit' approach"
    }
    "CRITICAL_CUSTOM_CLIENT" = @{
        Pattern = "custom MCP client"
        Priority = "CRITICAL"
        Suggestion = "Use 'Docker MCP Gateway' instead"
    }
    "CRITICAL_OLD_DATES" = @{
        Pattern = "2025-01-0[0-9][^-]"
        Priority = "CRITICAL"
        Suggestion = "Update date to >= 2025-01-11"
    }
    
    # 🟠 HIGH
    "HIGH_CPU_ONLY" = @{
        Pattern = "CPU-only|cpu-only"
        Priority = "HIGH"
        Suggestion = "Add GPU acceleration mention (10x performance)"
    }
    "HIGH_NO_GPU" = @{
        Pattern = "without GPU|no GPU acceleration"
        Priority = "HIGH"
        Suggestion = "Add GPU support with fallback to CPU"
    }
    "HIGH_OLD_INFERENCE" = @{
        Pattern = "5-10s.*inference|inference.*5-10"
        Priority = "HIGH"
        Suggestion = "Update to 0.5-1s with GPU acceleration"
    }
    "HIGH_OLD_SETUP" = @{
        Pattern = "20 min.*setup|setup.*20 min"
        Priority = "HIGH"
        Suggestion = "Update to 30 sec setup with Docker MCP"
    }
    
    # 🟡 MEDIUM
    "MEDIUM_WRONG_EFFORT" = @{
        Pattern = "25-30% reduction|30% effort"
        Priority = "MEDIUM"
        Suggestion = "Update to 60% effort reduction"
    }
    "MEDIUM_WRONG_SECURITY" = @{
        Pattern = "2x.*security|security.*2x"
        Priority = "MEDIUM"
        Suggestion = "Update to 3x security improvement"
    }
    "MEDIUM_VARIANT_A" = @{
        Pattern = "Variant A.*current|FlowForge Variant A"
        Priority = "MEDIUM"
        Suggestion = "Update to FlowForge Variant B"
    }
    
    # 🟢 LOW
    "LOW_OLD_METRICS" = @{
        Pattern = "significantly faster|значительно быстрее"
        Priority = "LOW"
        Suggestion = "Use quantitative metrics (10x, 60%, etc)"
    }
    "LOW_QUALITATIVE" = @{
        Pattern = "несколько часов|a few hours"
        Priority = "LOW"
        Suggestion = "Replace with specific hours (e.g., 2-3h)"
    }
}

# Priority symbols
$Symbols = @{
    "CRITICAL" = "🔴"
    "HIGH" = "🟠"
    "MEDIUM" = "🟡"
    "LOW" = "🟢"
}

# ===============================================================================
# 🔍 MAIN AUDIT FUNCTION
# ===============================================================================

function Run-Audit {
    $StartTime = Get-Date
    
    Write-Host "Scanning: $RootDir" -ForegroundColor Cyan
    Write-Host "Patterns: $($Patterns.Count)" -ForegroundColor Cyan
    Write-Host ""
    
    # Find all .md files
    $MdFiles = Get-ChildItem -Path $RootDir -Filter *.md -Recurse -File |
        Where-Object {
            $_.FullName -notmatch "node_modules" -and
            $_.FullName -notmatch "archive_legacy" -and
            $_.FullName -notmatch "\.windsurf\\\.memory" -and
            $_.FullName -notmatch "\.git"
        }
    
    $TotalFiles = $MdFiles.Count
    Write-Host "Found: $TotalFiles .md files`n" -ForegroundColor Cyan
    
    # Results storage
    $Results = @()
    $PriorityCounts = @{
        "CRITICAL" = 0
        "HIGH" = 0
        "MEDIUM" = 0
        "LOW" = 0
    }
    
    # Scan files
    $Current = 0
    foreach ($File in $MdFiles) {
        $Current++
        $PercentComplete = [math]::Round(($Current / $TotalFiles) * 100)
        Write-Progress -Activity "Scanning files" -Status "$Current of $TotalFiles" -PercentComplete $PercentComplete
        
        $RelPath = $File.FullName.Replace("$RootDir\", "")
        $Content = Get-Content $File.FullName -Raw
        $Lines = Get-Content $File.FullName
        
        foreach ($PatternName in $Patterns.Keys) {
            $PatternInfo = $Patterns[$PatternName]
            $Pattern = $PatternInfo.Pattern
            
            # Search pattern
            $LineNum = 0
            foreach ($Line in $Lines) {
                $LineNum++
                if ($Line -match $Pattern) {
                    $Results += [PSCustomObject]@{
                        File = $RelPath
                        Line = $LineNum
                        Priority = $PatternInfo.Priority
                        Pattern = $PatternName
                        Context = $Line.Trim()
                        Suggestion = $PatternInfo.Suggestion
                    }
                    $PriorityCounts[$PatternInfo.Priority]++
                }
            }
        }
    }
    
    Write-Progress -Activity "Scanning files" -Completed
    
    # Calculate metrics
    $EndTime = Get-Date
    $Duration = ($EndTime - $StartTime).TotalSeconds
    $IssueCount = $Results.Count
    $FilesWithIssues = ($Results | Select-Object -ExpandProperty File -Unique).Count
    $CleanFiles = $TotalFiles - $FilesWithIssues
    $CleanPercentage = [math]::Round(($CleanFiles / $TotalFiles) * 100, 1)
    
    # Output results
    switch ($Format) {
        "table" {
            Output-Table $Results $PriorityCounts $TotalFiles $FilesWithIssues $CleanFiles $CleanPercentage $Duration
        }
        "json" {
            Output-Json $Results $PriorityCounts $TotalFiles $FilesWithIssues $CleanFiles $Duration
        }
        "detailed" {
            Output-Detailed $Results $PriorityCounts $TotalFiles $FilesWithIssues $CleanFiles $Duration
        }
        "all" {
            Output-Table $Results $PriorityCounts $TotalFiles $FilesWithIssues $CleanFiles $CleanPercentage $Duration
            Output-Json $Results $PriorityCounts $TotalFiles $FilesWithIssues $CleanFiles $Duration | 
                Out-File "$OutputDir\audit_report.json" -Encoding UTF8
            Output-Detailed $Results $PriorityCounts $TotalFiles $FilesWithIssues $CleanFiles $Duration | 
                Out-File "$OutputDir\audit_report_detailed.md" -Encoding UTF8
            Write-Host "`n✅ Reports saved to: $OutputDir" -ForegroundColor Green
        }
    }
    
    # Return exit code
    if ($PriorityCounts["CRITICAL"] -gt 0) {
        return 1
    } else {
        return 0
    }
}

# ===============================================================================
# 📊 OUTPUT FUNCTIONS
# ===============================================================================

function Output-Table {
    param($Results, $PriorityCounts, $Total, $WithIssues, $Clean, $CleanPct, $Duration)
    
    Write-Host ""
    Write-Host "Scanned: $Total files | Issues: $($Results.Count) | Time: $([math]::Round($Duration, 1))s" -ForegroundColor White
    Write-Host ""
    
    if ($Results.Count -gt 0) {
        # Table header
        Write-Host ("{0,-12} {1,-45} {2,-6} {3,-25}" -f "Priority", "File", "Line", "Pattern") -ForegroundColor White
        Write-Host ("─" * 90) -ForegroundColor Gray
        
        # Sort by priority
        $PriorityOrder = @("CRITICAL", "HIGH", "MEDIUM", "LOW")
        foreach ($Priority in $PriorityOrder) {
            $FilteredResults = $Results | Where-Object { $_.Priority -eq $Priority } | Sort-Object File, Line
            foreach ($Result in $FilteredResults) {
                $Symbol = $Symbols[$Priority]
                $File = $Result.File
                if ($File.Length -gt 43) {
                    $File = "..." + $File.Substring($File.Length - 40)
                }
                
                $Color = switch ($Priority) {
                    "CRITICAL" { "Red" }
                    "HIGH" { "Yellow" }
                    "MEDIUM" { "DarkYellow" }
                    "LOW" { "Green" }
                }
                
                $PatternShort = ($Result.Pattern -replace "^[A-Z]+_", "")
                Write-Host ("{0} {1,-10} {2,-45} {3,-6} {4,-25}" -f $Symbol, $Priority, $File, $Result.Line, $PatternShort) -ForegroundColor $Color
            }
        }
    }
    
    Write-Host ""
    Write-Host "📊 SUMMARY:" -ForegroundColor White
    Write-Host "🔴 CRITICAL: $($PriorityCounts['CRITICAL'])  " -NoNewline -ForegroundColor Red
    Write-Host "🟠 HIGH: $($PriorityCounts['HIGH'])  " -NoNewline -ForegroundColor Yellow
    Write-Host "🟡 MEDIUM: $($PriorityCounts['MEDIUM'])  " -NoNewline -ForegroundColor DarkYellow
    Write-Host "🟢 LOW: $($PriorityCounts['LOW'])" -ForegroundColor Green
    Write-Host "✅ Clean: $Clean files ($CleanPct%)  " -NoNewline -ForegroundColor Green
    Write-Host "❌ Issues: $WithIssues files" -ForegroundColor Red
}

function Output-Json {
    param($Results, $PriorityCounts, $Total, $WithIssues, $Clean, $Duration)
    
    $Report = @{
        audit_report = @{
            timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            scanned_files = $Total
            total_issues = $Results.Count
            duration_seconds = [math]::Round($Duration, 2)
            issues_by_priority = $PriorityCounts
            files_with_issues = $WithIssues
            clean_files = $Clean
            details = @($Results | ForEach-Object {
                @{
                    file = $_.File
                    line = $_.Line
                    priority = $_.Priority
                    pattern = $_.Pattern
                    context = $_.Context
                    suggestion = $_.Suggestion
                }
            })
        }
    }
    
    return ($Report | ConvertTo-Json -Depth 10)
}

function Output-Detailed {
    param($Results, $PriorityCounts, $Total, $WithIssues, $Clean, $Duration)
    
    $Output = @"
# 📋 DETAILED AUDIT REPORT

**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Duration:** $([math]::Round($Duration, 1))s
**Files Scanned:** $Total
**Total Issues:** $($Results.Count)

## 📊 Summary

- 🔴 **CRITICAL:** $($PriorityCounts['CRITICAL']) issues
- 🟠 **HIGH:** $($PriorityCounts['HIGH']) issues
- 🟡 **MEDIUM:** $($PriorityCounts['MEDIUM']) issues
- 🟢 **LOW:** $($PriorityCounts['LOW']) issues
- ✅ **Clean Files:** $Clean ($([math]::Round(($Clean/$Total)*100, 1))%)
- ❌ **Files with Issues:** $WithIssues ($([math]::Round(($WithIssues/$Total)*100, 1))%)

"@
    
    $PriorityOrder = @("CRITICAL", "HIGH", "MEDIUM", "LOW")
    foreach ($Priority in $PriorityOrder) {
        $FilteredResults = $Results | Where-Object { $_.Priority -eq $Priority }
        if ($FilteredResults.Count -gt 0) {
            $Output += "`n## $Priority Issues ($($FilteredResults.Count))`n`n"
            
            $IssueNum = 1
            foreach ($Result in $FilteredResults) {
                $Output += "### $IssueNum. $($Result.File):$($Result.Line)`n`n"
                $Output += "**Pattern:** ``$($Result.Pattern)```n`n"
                $Output += "**Context:**`n````````n$($Result.Context)`n`````````n`n"
                $Output += "**Suggestion:** $($Result.Suggestion)`n`n"
                $IssueNum++
            }
        }
    }
    
    return $Output
}

# ===============================================================================
# 🚀 MAIN EXECUTION
# ===============================================================================

# Show help
if ($Format -eq "help" -or $Format -eq "--help" -or $Format -eq "-h") {
    Write-Host @"
Usage: .\audit-docs.ps1 [FORMAT]

Formats:
  table     Interactive table (default)
  json      JSON export
  detailed  Detailed markdown report
  all       All formats (saves to files)

Example:
  .\audit-docs.ps1 table
  .\audit-docs.ps1 json | Out-File report.json
  .\audit-docs.ps1 all
"@
    exit 0
}

# Run audit
$ExitCode = Run-Audit
exit $ExitCode
