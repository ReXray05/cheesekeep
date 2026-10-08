@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Abrir-Godot.ps1"
if errorlevel 1 pause
