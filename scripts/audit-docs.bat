@echo off
setlocal enabledelayedexpansion

REM ===============================================================================
REM 🔍 AUDIT-DOCS.BAT - Automated Documentation Audit System (Windows)
REM ===============================================================================
REM 
REM Purpose: Автоматический поиск устаревшего контента в документации FlowForge
REM Version: 1.0.0
REM Date: 2025-01-11
REM Author: FlowForge Auto-Tracking System
REM Platform: Windows (PowerShell required)
REM
REM AUTO-TRACKING_PROMPT: v1.0
REM -------------------------------------------------------------------------------
REM Current Architectural Paradigm (2025-01-11):
REM   - Docker MCP Toolkit (Hybrid Strategy)
REM   - GPU Acceleration (10x performance)
REM   - Phase 4 effort: 12-16h (was 25-36h, -60%%)
REM   - Phase 0.S effort: 2-3h (was 9h, -75%%)
REM
REM Last Sync Check: 2025-01-11
REM ===============================================================================

echo.
echo 🔍 AUDIT REPORT: FlowForge Documentation
echo ===========================================
echo.

REM Call PowerShell script for actual audit
powershell -ExecutionPolicy Bypass -File "%~dp0audit-docs.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Audit found CRITICAL issues!
    exit /b 1
)

exit /b 0
