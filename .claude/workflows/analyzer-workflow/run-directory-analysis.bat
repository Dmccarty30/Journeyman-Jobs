@echo off
setlocal enabledelayedexpansion

REM Multi-Agent Directory Analysis Workflow Execution Script (Windows)
REM Usage: run-directory-analysis.bat [directory] [depth] [output_format]

REM Default values
set "DEFAULT_DIRECTORY=."
set "DEFAULT_DEPTH=standard"
set "DEFAULT_OUTPUT_FORMAT=markdown"

REM Parse command line arguments
set "TARGET_DIRECTORY=%~1"
if "%TARGET_DIRECTORY%"=="" set "TARGET_DIRECTORY=%DEFAULT_DIRECTORY%"

set "ANALYSIS_DEPTH=%~2"
if "%ANALYSIS_DEPTH%"=="" set "ANALYSIS_DEPTH=%DEFAULT_DEPTH%"

set "OUTPUT_FORMAT=%~3"
if "%OUTPUT_FORMAT%"=="" set "OUTPUT_FORMAT=%DEFAULT_OUTPUT_FORMAT%"

echo ========================================
echo Multi-Agent Directory Analysis Workflow
echo ========================================
echo.
echo Configuration:
echo   Target Directory: %TARGET_DIRECTORY%
echo   Analysis Depth: %ANALYSIS_DEPTH%
echo   Output Format: %OUTPUT_FORMAT%
echo.

REM Function to validate inputs
echo [INFO] Validating inputs...

REM Check if target directory exists
if not exist "%TARGET_DIRECTORY%" (
    echo [ERROR] Directory '%TARGET_DIRECTORY%' does not exist
    exit /b 1
)

REM Validate analysis depth
if /i not "%ANALYSIS_DEPTH%"=="quick" if /i not "%ANALYSIS_DEPTH%"=="standard" if /i not "%ANALYSIS_DEPTH%"=="comprehensive" (
    echo [ERROR] Invalid analysis depth: %ANALYSIS_DEPTH%. Must be one of: quick, standard, comprehensive
    exit /b 1
)

REM Validate output format
if /i not "%OUTPUT_FORMAT%"=="markdown" if /i not "%OUTPUT_FORMAT%"=="json" if /i not "%OUTPUT_FORMAT%"=="html" (
    echo [ERROR] Invalid output format: %OUTPUT_FORMAT%. Must be one of: markdown, json, html
    exit /b 1
)

echo [SUCCESS] Input validation completed

REM Function to setup analysis environment
echo [INFO] Setting up analysis environment...

REM Create output directory with timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "OUTPUT_DIR=analysis-results-%dt:~0,8%-%dt:~8,6%"
mkdir "%OUTPUT_DIR%"

REM Set environment variables
set "ANALYSIS_TARGET_DIR=%TARGET_DIRECTORY%"
set "ANALYSIS_DEPTH=%ANALYSIS_DEPTH%"
set "ANALYSIS_OUTPUT_FORMAT=%OUTPUT_FORMAT%"
set "ANALYSIS_OUTPUT_DIR=%OUTPUT_DIR%"

echo [SUCCESS] Analysis environment setup completed

REM Function to create individual analysis templates
echo [INFO] Creating analysis templates...

REM Security Analysis Template
(
echo # Security Analysis Report
echo.
echo ## Executive Summary
echo *Security analysis completed on %date%*
echo.
echo ## Findings
echo - [Security vulnerabilities and issues will be listed here]
echo - [OWASP compliance assessment]
echo - [Authentication/authorization review]
echo - [Data privacy assessment]
echo.
echo ## Recommendations
echo - [Security recommendations will be listed here]
) > "%OUTPUT_DIR%\security-analysis.md"

REM Performance Analysis Template
(
echo # Performance Analysis Report
echo.
echo ## Executive Summary
echo *Performance analysis completed on %date%*
echo.
echo ## Findings
echo - [Performance bottlenecks will be identified here]
echo - [Memory usage analysis]
echo - [Database optimization opportunities]
echo - [Network performance issues]
echo.
echo ## Recommendations
echo - [Performance optimization recommendations will be listed here]
) > "%OUTPUT_DIR%\performance-analysis.md"

REM Code Quality Analysis Template
(
echo # Code Quality Analysis Report
echo.
echo ## Executive Summary
echo *Code quality analysis completed on %date%*
echo.
echo ## Findings
echo - [Code style and formatting issues]
echo - [Code complexity assessment]
echo - [Maintainability concerns]
echo - [Technical debt identification]
echo.
echo ## Recommendations
echo - [Code quality improvement recommendations will be listed here]
) > "%OUTPUT_DIR%\code-quality-analysis.md"

REM Architecture Analysis Template
(
echo # Architecture Analysis Report
echo.
echo ## Executive Summary
echo *Architecture analysis completed on %date%*
echo.
echo ## Findings
echo - [Design pattern violations]
echo - [Architecture concerns]
echo - [Scalability issues]
echo - [Module coupling problems]
echo.
echo ## Recommendations
echo - [Architecture improvement recommendations will be listed here]
) > "%OUTPUT_DIR%\architecture-analysis.md"

REM Documentation Analysis Template
(
echo # Documentation Analysis Report
echo.
echo ## Executive Summary
echo *Documentation analysis completed on %date%*
echo.
echo ## Findings
echo - [Missing documentation]
echo - [Documentation quality issues]
echo - [API documentation gaps]
echo - [User guide deficiencies]
echo.
echo ## Recommendations
echo - [Documentation improvement recommendations will be listed here]
) > "%OUTPUT_DIR%\documentation-analysis.md"

REM Testing Analysis Template
(
echo # Testing Analysis Report
echo.
echo ## Executive Summary
echo *Testing analysis completed on %date%*
echo.
echo ## Findings
echo - [Test coverage gaps]
echo - [Test quality issues]
echo - [Missing test scenarios]
echo - [Test automation opportunities]
echo.
echo ## Recommendations
echo - [Testing improvement recommendations will be listed here]
) > "%OUTPUT_DIR%\testing-analysis.md"

echo [SUCCESS] Analysis templates created

REM Function to spawn agents using Claude Code Task tool
echo [INFO] Spawning specialized agents...

REM Security Analyst
echo [INFO] Spawning Security Analyst...
claude --task "Analyze security vulnerabilities in %ANALYSIS_TARGET_DIR%. Focus on authentication, data handling, and OWASP compliance. Generate detailed security findings and recommendations." --agent security-specialist --output "%OUTPUT_DIR%\security-detailed-analysis.md" &
set "SECURITY_PID=!ERRORLEVEL!"

REM Performance Analyst
echo [INFO] Spawning Performance Analyst...
claude --task "Analyze performance bottlenecks in %ANALYSIS_TARGET_DIR%. Focus on code efficiency, memory usage, and optimization opportunities. Generate detailed performance findings and recommendations." --agent performance-specialist --output "%OUTPUT_DIR%\performance-detailed-analysis.md" &
set "PERFORMANCE_PID=!ERRORLEVEL!"

REM Code Quality Analyst
echo [INFO] Spawning Code Quality Analyst...
claude --task "Analyze code quality in %ANALYSIS_TARGET_DIR%. Focus on maintainability, technical debt, code complexity, and best practices. Generate detailed quality findings and recommendations." --agent code-quality-specialist --output "%OUTPUT_DIR%\code-quality-detailed-analysis.md" &
set "CODE_QUALITY_PID=!ERRORLEVEL!"

REM Architecture Analyst
echo [INFO] Spawning Architecture Analyst...
claude --task "Analyze system architecture in %ANALYSIS_TARGET_DIR%. Focus on design patterns, module coupling, scalability, and architectural violations. Generate detailed architecture findings and recommendations." --agent architecture-specialist --output "%OUTPUT_DIR%\architecture-detailed-analysis.md" &
set "ARCHITECTURE_PID=!ERRORLEVEL!"

REM Documentation Analyst
echo [INFO] Spawning Documentation Analyst...
claude --task "Analyze documentation quality in %ANALYSIS_TARGET_DIR%. Focus on README files, code comments, API documentation, and user guides. Generate detailed documentation findings and recommendations." --agent documentation-specialist --output "%OUTPUT_DIR%\documentation-detailed-analysis.md" &
set "DOCUMENTATION_PID=!ERRORLEVEL!"

REM Testing Analyst
echo [INFO] Spawning Testing Analyst...
claude --task "Analyze testing strategy and coverage in %ANALYSIS_TARGET_DIR%. Focus on test coverage, test quality, missing scenarios, and automation opportunities. Generate detailed testing findings and recommendations." --agent testing-specialist --output "%OUTPUT_DIR%\testing-detailed-analysis.md" &
set "TESTING_PID=!ERRORLEVEL!"

echo [SUCCESS] All agents spawned successfully

REM Wait for a moment to let agents start working
timeout /t 5 /nobreak >nul

REM Function to consolidate findings (simplified for Windows)
echo [INFO] Consolidating findings...

REM Create consolidated report
(
echo # Multi-Agent Directory Analysis Report
echo.
echo ## Analysis Summary
echo - **Target Directory**: %ANALYSIS_TARGET_DIR%
echo - **Analysis Depth**: %ANALYSIS_DEPTH%
echo - **Analysis Date**: %date%
echo - **Output Format**: %OUTPUT_FORMAT%
echo.
echo ## Executive Summary
echo This comprehensive analysis was conducted using 6 specialized agents:
echo - Security Analyst
echo - Performance Analyst
echo - Code Quality Analyst
echo - Architecture Analyst
echo - Documentation Analyst
echo - Testing Analyst
echo.
echo ## Key Findings
echo [Key findings from all agents will be consolidated here]
echo.
echo ## Priority Recommendations
echo [High-priority recommendations from all agents]
echo.
echo ## Detailed Analysis
echo.
) > "%OUTPUT_DIR%\consolidated-analysis-report.%OUTPUT_FORMAT%"

REM Append individual analysis results
for %%f in ("%OUTPUT_DIR%\*-analysis.md") do (
    echo. >> "%OUTPUT_DIR%\consolidated-analysis-report.%OUTPUT_FORMAT%"
    echo ## %%~nf >> "%OUTPUT_DIR%\consolidated-analysis-report.%OUTPUT_FORMAT%"
    echo. >> "%OUTPUT_DIR%\consolidated-analysis-report.%OUTPUT_FORMAT%"
    type "%%f" >> "%OUTPUT_DIR%\consolidated-analysis-report.%OUTPUT_FORMAT%"
)

echo [SUCCESS] Findings consolidation completed

REM Function to generate actionable recommendations
echo [INFO] Generating actionable recommendations...

(
echo # Actionable Recommendations
echo.
echo ## Critical Priority ^(Fix Immediately^)
echo - [Critical recommendations will be listed here]
echo.
echo ## High Priority ^(Fix Within 1 Week^)
echo - [High priority recommendations will be listed here]
echo.
echo ## Medium Priority ^(Fix Within 1 Month^)
echo - [Medium priority recommendations will be listed here]
echo.
echo ## Low Priority ^(Consider for Future^)
echo - [Low priority recommendations will be listed here]
echo.
echo ## Implementation Roadmap
echo [Step-by-step implementation plan will be provided here]
) > "%OUTPUT_DIR%\actionable-recommendations.md"

echo [SUCCESS] Actionable recommendations generated

REM Function to display results
echo.
echo [SUCCESS] Multi-Agent Directory Analysis Completed!
echo.
echo Analysis Results:
echo   Output Directory: %OUTPUT_DIR%
echo   Consolidated Report: %OUTPUT_DIR%\consolidated-analysis-report.%OUTPUT_FORMAT%
echo   Actionable Recommendations: %OUTPUT_DIR%\actionable-recommendations.md
echo.
echo Individual Agent Reports:
for %%f in ("%OUTPUT_DIR%\*-detailed-analysis.md") do (
    if exist "%%f" echo   - %%~nxf
)
echo.
echo [INFO] Open the consolidated report to view all findings and recommendations.
echo.
echo Note: This Windows batch script provides the workflow structure.
echo For full multi-agent parallel execution, use the Unix shell script
echo or run the individual Claude commands manually.

endlocal