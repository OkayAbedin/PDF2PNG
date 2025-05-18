@echo off
REM PDF2PNG Converter - Installation Verification
REM This script verifies that all components are installed correctly

echo PDF2PNG Converter - Installation Verification
echo ===========================================
echo.

REM Define paths
set APP_DIR=%~dp0
set MAIN_EXE=%APP_DIR%PDF2PNG_Converter.exe
set STARTER_EXE=%APP_DIR%PDF2PNG_Starter.exe
set POPPLER_DIR=%APP_DIR%poppler-bin
set PDFTOPPM=%POPPLER_DIR%\pdftoppm.exe

echo Installation directory: %APP_DIR%
echo.

echo Checking main executable...
if exist "%MAIN_EXE%" (
    echo [OK] Main executable found: %MAIN_EXE%
    echo     Size: %~z1MAIN_EXE% bytes
) else (
    echo [MISSING] Main executable not found: %MAIN_EXE%
)

echo Checking starter executable...
if exist "%STARTER_EXE%" (
    echo [OK] Starter executable found: %STARTER_EXE%
    echo     Size: %~z1STARTER_EXE% bytes
) else (
    echo [MISSING] Starter executable not found: %STARTER_EXE%
)

echo Checking Poppler directory...
if exist "%POPPLER_DIR%" (
    echo [OK] Poppler directory found: %POPPLER_DIR%
    
    echo Checking pdftoppm.exe...
    if exist "%PDFTOPPM%" (
        echo [OK] pdftoppm.exe found: %PDFTOPPM%
    ) else (
        echo [MISSING] pdftoppm.exe not found: %PDFTOPPM%
    )
) else (
    echo [MISSING] Poppler directory not found: %POPPLER_DIR%
)

echo.
echo Would you like to check the PATH setting? (Y/N)
set /p check_path=

if /i "%check_path%"=="Y" (
    echo.
    echo Current PATH:
    echo %PATH%
    echo.
    echo Setting correct PATH...
    set PATH=%POPPLER_DIR%;%APP_DIR%;%PATH%
    echo New PATH:
    echo %PATH%
)

echo.
echo Would you like to try launching the application? (Y/N)
set /p launch_app=

if /i "%launch_app%"=="Y" (
    echo.
    echo Launching PDF2PNG Converter...
    if exist "%STARTER_EXE%" (
        start "" "%STARTER_EXE%"
        echo Launched using starter executable.
    ) else if exist "%MAIN_EXE%" (
        start "" "%MAIN_EXE%"
        echo Launched using main executable.
    ) else (
        echo Cannot launch - executables not found.
    )
)

echo.
echo Verification complete.
echo If you encounter issues, please run the fix_installation.ps1 script.
echo.
pause
