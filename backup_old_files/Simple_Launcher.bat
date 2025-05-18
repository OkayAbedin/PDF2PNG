@echo off
REM Simple Launcher for PDF2PNG Converter
REM This script launches the application with proper environment setup

echo Launching PDF2PNG Converter...

REM Set environment variables
set INSTALL_DIR=%LOCALAPPDATA%\PDF2PNG Converter
set PATH=%INSTALL_DIR%\poppler-bin;%INSTALL_DIR%;%PATH%

REM Create output directory if it doesn't exist
if not exist "%USERPROFILE%\Documents\PDF2PNG" (
    mkdir "%USERPROFILE%\Documents\PDF2PNG"
)

REM Launch the application using the starter executable
start "" "%INSTALL_DIR%\PDF2PNG_Starter.exe"

REM No need to wait, exit immediately
exit
