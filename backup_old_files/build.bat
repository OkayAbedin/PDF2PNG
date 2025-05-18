@echo off
echo Building PDF2PNG Converter...

REM Check if Python is installed
where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Python is not installed or not in PATH. Please install Python first.
    exit /b 1
)

REM Install dependencies
echo Installing dependencies...
python -m pip install -r requirements.txt

REM Build executable with PyInstaller
echo Building executable with PyInstaller...

REM Clean previous build
if exist "build" rmdir /S /Q "build"
if exist "dist" rmdir /S /Q "dist"

REM Run PyInstaller with the spec file
echo Building main converter executable...
python -m PyInstaller PDF2PNG_Converter.spec

REM Check for successful build
if not exist "dist\PDF2PNG_Converter.exe" (
    echo Build failed! Main executable not created.
    exit /b 1
)

REM Build the starter executable
echo Building starter executable...
python -m PyInstaller --onefile --noconsole --icon=icon.ico --name=PDF2PNG_Starter start_pdf2png.py

REM Check for successful build
if not exist "dist\PDF2PNG_Starter.exe" (
    echo Build failed! Starter executable not created.
    exit /b 1
)

echo Executables built successfully!

REM Check if NSIS is installed
if not exist "%PROGRAMFILES(x86)%\NSIS\makensis.exe" (
    if not exist "%PROGRAMFILES%\NSIS\makensis.exe" (
        echo NSIS is not installed. Please install NSIS first.
        echo You can download it from https://nsis.sourceforge.io/Download
        exit /b 1
    )
)

REM Build installer with NSIS
echo Building installer with NSIS...
if exist "%PROGRAMFILES(x86)%\NSIS\makensis.exe" (
    "%PROGRAMFILES(x86)%\NSIS\makensis.exe" installer_new.nsi
) else (
    "%PROGRAMFILES%\NSIS\makensis.exe" installer_new.nsi
)

echo Build completed!
echo The installer is located at: PDF2PNG_Converter_Setup.exe

pause
