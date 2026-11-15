@echo off
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0Patch.ps1" -Mode Install
pause
