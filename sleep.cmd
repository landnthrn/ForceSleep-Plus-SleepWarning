@echo off
color 0A

if "%~1"=="" (
    call "%~dp0forcesleep.cmd"
    exit /b %ERRORLEVEL%
)

set "ARG=%~1"
for %%C in (on off status time monitor restart) do (
    if /I "%ARG%"=="%%C" (
        shift
        call "%~dp0forcesleep.cmd" %%C %*
        exit /b %ERRORLEVEL%
    )
)

call "%~dp0forcesleep.cmd" %*
exit /b %ERRORLEVEL%
