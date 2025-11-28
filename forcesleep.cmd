@echo off
setlocal EnableExtensions EnableDelayedExpansion

color 0A

pushd "%~dp0" >nul 2>nul

set "FLAG=%~dp0FORCE_SLEEP_DISABLED.txt"
set "COMMAND=%~1"
set "ARGUMENT=%~2"

if /I "%COMMAND%"=="sleep" (
    set "COMMAND=%~2"
    set "ARGUMENT=%~3"
)

if not defined COMMAND goto :help

if /I "%COMMAND%"=="on" (
    if exist "%FLAG%" del /f /q "%FLAG%" 2>nul
    echo.
    echo Sleep mode: ENABLED
    echo.
    set "EXITCODE=0"
    goto :end
)

if /I "%COMMAND%"=="off" (
    echo. > "%FLAG%"
    echo.
    echo Sleep mode: DISABLED
    echo.
    set "EXITCODE=0"
    goto :end
)

if /I "%COMMAND%"=="status" (
    call :print_status
    set "EXITCODE=0"
    goto :end
)

if /I "%COMMAND%"=="time" (
    powershell -ExecutionPolicy Bypass -File "%~dp0forcesleep_timechange.ps1"
    set "EXITCODE=%ERRORLEVEL%"
    goto :end
)

if /I "%COMMAND%"=="restart" (
    schtasks /end /tn "ForceSleep_Watcher" >nul 2>nul
    timeout /t 2 /nobreak >nul
    schtasks /run /tn "ForceSleep_Watcher"
    set "EXITCODE=%ERRORLEVEL%"
    goto :end
)

if /I "%COMMAND%"=="monitor" (
    powershell -ExecutionPolicy Bypass -File "%~dp0forcesleep_monitor.ps1"
    set "EXITCODE=%ERRORLEVEL%"
    timeout /t 1 /nobreak >nul
    echo.
    pause
    goto :end
)

:help
set "STATUS=ENABLED"
if exist "%FLAG%" set "STATUS=DISABLED"

set "THRESHOLD="
set "SCRIPT_FILE=%~dp0forcesleep.ps1"
if exist "%SCRIPT_FILE%" (
    for /f "usebackq tokens=* delims=" %%A in (`
        powershell -NoProfile -Command "$path = $env:SCRIPT_FILE; if ((Get-Content -LiteralPath $path -Raw) -match '\$ThresholdMinutes\s*=\s*(\d+)') { Write-Output $matches[1] }"` ) do (
        set "THRESHOLD=%%A"
        goto threshold_found
    )
)
:threshold_found

set "IDLE_DISPLAY=Unknown"
set "minutes="
set "hours="
set "mins="
if defined THRESHOLD (
    for /f "tokens=1 delims= " %%A in ("!THRESHOLD!") do set "THRESHOLD=%%A"
    for /f "tokens=1 delims=." %%A in ("!THRESHOLD!") do set "THRESHOLD=%%A"
    set "minutes=!THRESHOLD!"
    if defined minutes (
        echo(!minutes!| findstr /R "^[0-9][0-9]*$" >nul
        if not errorlevel 1 (
            set /a minutes=!minutes!
            if !minutes! lss 60 (
                if !minutes! EQU 1 (
                    set "IDLE_DISPLAY=1 minute"
                ) else (
                    set "IDLE_DISPLAY=!minutes! minutes"
                )
            ) else (
                set /a hours=minutes/60
                set /a mins=minutes%%60
                if !hours! EQU 1 (
                    set "IDLE_DISPLAY=1 hour"
                ) else (
                    set "IDLE_DISPLAY=!hours! hours"
                )
                if !mins! GTR 0 (
                    if !mins! EQU 1 (
                        set "IDLE_DISPLAY=!IDLE_DISPLAY! 1 minute"
                    ) else (
                        set "IDLE_DISPLAY=!IDLE_DISPLAY! !mins! minutes"
                    )
                )
            )
        )
    )
)

call :print_status
echo.
echo Sleep Commands:
echo   sleepon        - Enable idle sleep
echo   sleepoff       - Disable idle sleep
echo   sleepstatus    - Check if enabled/disabled
echo   sleeptime      - Change the set idle time
echo   sleepmonitor   - Change monitor(s) sleep time
echo   sleeprestart   - Restart the watcher task
echo.
set "EXITCODE=0"

:end
popd >nul 2>nul
endlocal & exit /b %EXITCODE%

:print_status
set "STATUS=ENABLED"
if exist "%FLAG%" set "STATUS=DISABLED"

set "THRESHOLD="
set "SCRIPT_FILE=%~dp0forcesleep.ps1"
if exist "%SCRIPT_FILE%" (
    for /f "usebackq tokens=* delims=" %%A in (`
        powershell -NoProfile -Command "$path = $env:SCRIPT_FILE; if ((Get-Content -LiteralPath $path -Raw) -match '\$ThresholdMinutes\s*=\s*(\d+)') { Write-Output $matches[1] }"` ) do (
        set "THRESHOLD=%%A"
        goto threshold_found
    )
)
:threshold_found

set "IDLE_DISPLAY=Unknown"
set "minutes="
set "hours="
set "mins="
if defined THRESHOLD (
    for /f "tokens=1 delims= " %%A in ("!THRESHOLD!") do set "THRESHOLD=%%A"
    for /f "tokens=1 delims=." %%A in ("!THRESHOLD!") do set "THRESHOLD=%%A"
    set "minutes=!THRESHOLD!"
    if defined minutes (
        echo(!minutes!| findstr /R "^[0-9][0-9]*$" >nul
        if not errorlevel 1 (
            set /a minutes=!minutes!
            if !minutes! lss 60 (
                if !minutes! EQU 1 (
                    set "IDLE_DISPLAY=1 minute"
                ) else (
                    set "IDLE_DISPLAY=!minutes! minutes"
                )
            ) else (
                set /a hours=minutes/60
                set /a mins=minutes%%60
                if !hours! EQU 1 (
                    set "IDLE_DISPLAY=1 hour"
                ) else (
                    set "IDLE_DISPLAY=!hours! hours"
                )
                if !mins! GTR 0 (
                    if !mins! EQU 1 (
                        set "IDLE_DISPLAY=!IDLE_DISPLAY! 1 minute"
                    ) else (
                        set "IDLE_DISPLAY=!IDLE_DISPLAY! !mins! minutes"
                    )
                )
            )
        )
    )
)

set "MONITOR_TIME="
for /f "usebackq tokens=* delims=" %%A in (`
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0get_monitor_time.ps1"` ) do (
    set "MONITOR_TIME=%%A"
    goto monitor_found
)
:monitor_found

set "MONITOR_DISPLAY=Unknown"
if defined MONITOR_TIME (
    for /f "tokens=1 delims= " %%A in ("!MONITOR_TIME!") do set "MONITOR_TIME=%%A"
    set /a monitor_minutes=!MONITOR_TIME! 2>nul
    if !errorlevel! EQU 0 (
        if !monitor_minutes! EQU 0 (
            set "MONITOR_DISPLAY=Never"
        ) else if !monitor_minutes! EQU 1 (
            set "MONITOR_DISPLAY=1 minute"
        ) else (
            set "MONITOR_DISPLAY=!monitor_minutes! minutes"
        )
    )
)

echo.
echo Status - !STATUS!
echo Idle Timer - !IDLE_DISPLAY!
echo Sleep Monitor Time - !MONITOR_DISPLAY!
echo.
exit /b 0