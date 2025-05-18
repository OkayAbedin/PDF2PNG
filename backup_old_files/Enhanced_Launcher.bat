@echo off
REM PDF2PNG Converter Enhanced Launcher
REM This script ensures proper environment setup and error handling

echo PDF2PNG Converter
echo ================
echo.

REM Store the application path
set APP_DIR=%~dp0
set MAIN_EXE=%APP_DIR%PDF2PNG_Converter.exe
set STARTER_EXE=%APP_DIR%PDF2PNG_Starter.exe
set POPPLER_DIR=%APP_DIR%poppler-bin

REM Check if the executable exists
echo Checking for executables...
if not exist "%MAIN_EXE%" (
    echo ERROR: Main executable not found at: %MAIN_EXE%
    echo Current Directory: %CD%
    echo App Directory: %APP_DIR%
    dir "%APP_DIR%"
    echo.
    echo Please ensure the application is properly installed.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

if not exist "%STARTER_EXE%" (
    echo WARNING: Starter executable not found at: %STARTER_EXE%
    echo Will attempt to use main executable instead.
    echo.
)

REM Check for poppler binaries
if not exist "%POPPLER_DIR%" (
    echo ERROR: Poppler directory not found at: %POPPLER_DIR%
    echo PDF conversion will not work without Poppler.
    echo.
    echo Creating poppler-bin directory...
    mkdir "%POPPLER_DIR%"
    echo.
)

REM Ensure Poppler is in PATH with highest priority
set PATH=%POPPLER_DIR%;%APP_DIR%;%PATH%

REM Create output directory
set OUTPUT_DIR=%USERPROFILE%\Documents\PDF2PNG
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

echo PATH is set to: %PATH%
echo Output directory: %OUTPUT_DIR%
echo.

REM Launch the application, preferring starter if it exists
echo Launching PDF2PNG Converter...
if exist "%STARTER_EXE%" (
    echo Using Starter executable: %STARTER_EXE%
    start "" "%STARTER_EXE%"
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Failed to launch Starter executable with error code %ERRORLEVEL%
        echo Will try main executable instead.
        start "" "%MAIN_EXE%"
    )
) else (
    echo Starter not found, using Main executable: %MAIN_EXE%
    start "" "%MAIN_EXE%"
)

echo.
echo If the application doesn't appear, try running:
echo   powershell -ExecutionPolicy Bypass -File "%APP_DIR%fix_installation.ps1"
echo.

timeout /t 3 >nul
