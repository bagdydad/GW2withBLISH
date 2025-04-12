@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Guild Wars 2 Launcher with Blish HUD

set "CONFIG_FILE=%~dp0gw2_launcher.cfg"
set "GW2_EXE="
set "BLISH_EXE="
set "AUTO_LOGIN="

:LAUNCH
call :LOAD_CONFIG
if not defined GW2_EXE (
    goto CONFIGURE
)
if not defined BLISH_EXE (
    goto CONFIGURE
)

echo.
echo Starting Blish HUD...
start "" "!BLISH_EXE!"
timeout /t 3 /nobreak >nul

echo Starting Guild Wars 2...
start "" /wait "!GW2_EXE!" !AUTO_LOGIN!

echo.
echo Closing Blish HUD...
taskkill /f /im "Blish HUD.exe" >nul 2>&1
echo All done!
exit

:CONFIGURE
:SET_GW2
echo.
echo Drag and drop the Guild Wars 2.exe here then press enter. (Gw2-64.exe):
set /p "NEW_PATH="
set "NEW_PATH=!NEW_PATH:"=!"
if exist "!NEW_PATH!" (
    set "GW2_EXE=!NEW_PATH!"
    echo GW2 Path updated.
) else (
    echo Invalid path. File not found.
)

:SET_BLISH
echo.
echo Drag and drop the Blish HUD.exe here then press enter. (Blish HUD.exe):
set /p "NEW_PATH="
set "NEW_PATH=!NEW_PATH:"=!"
if exist "!NEW_PATH!" (
    set "BLISH_EXE=!NEW_PATH!"
    echo BLISH HUB Path updated.
) else (
    echo Invalid path. File not found.
)

setlocal
set "ICON_PATH=%GW2_EXE%"
set "DESKTOP=%~dp0"
set "BAT_PATH=%~dp0%~nx0"
set "SHORTCUT_NAME=Guild Wars 2"
set "VBS_FILE=%TEMP%\create_shortcut.vbs"

> "%VBS_FILE%" echo Set oWS = WScript.CreateObject("WScript.Shell")
>> "%VBS_FILE%" echo sLinkFile = "%DESKTOP%\%SHORTCUT_NAME%.lnk"
>> "%VBS_FILE%" echo Set oLink = oWS.CreateShortcut(sLinkFile)
>> "%VBS_FILE%" echo oLink.TargetPath = "%BAT_PATH%"
>> "%VBS_FILE%" echo oLink.WorkingDirectory = "%~dp0"
>> "%VBS_FILE%" echo oLink.IconLocation = "%ICON_PATH%"
>> "%VBS_FILE%" echo oLink.Save

cscript //nologo "%VBS_FILE%"
del "%VBS_FILE%"
echo Shortcut created.

:TOGGLE_LOGIN
if "%AUTO_LOGIN%"=="-autologin" (
    set "AUTO_LOGIN="
    echo Auto-Login disabled.
) else (
    set "AUTO_LOGIN=-autologin"
    echo Auto-Login enabled.
)

:SAVE_CONFIG
(
    echo !GW2_EXE!
    echo !BLISH_EXE!
    echo !AUTO_LOGIN!
) > "%CONFIG_FILE%"
echo Configuration saved.

timeout /t 3 /nobreak >nul
REM goto LAUNCH
echo All done!
echo You can start the game via the shortcut in the Guild Wars 2's path.
echo Press any key to close this window.
pause
exit

:LOAD_CONFIG
if not exist "%CONFIG_FILE%" goto :EOF

set "LINE_NUM=0"
for /f "usebackq delims=" %%A in ("%CONFIG_FILE%") do (
    set /a "LINE_NUM+=1"
    if !LINE_NUM! equ 1 set "GW2_EXE=%%A"
    if !LINE_NUM! equ 2 set "BLISH_EXE=%%A"
    if !LINE_NUM! equ 3 set "AUTO_LOGIN=%%A"
)
goto :EOF