@echo off
echo PDF2PNG Converter Launcher
echo =========================
echo.

REM Check if poppler-bin exists
if not exist "%~dp0poppler-bin" (
    echo WARNING: poppler-bin directory not found!
    echo Creating poppler-bin directory...
    mkdir "%~dp0poppler-bin"
    
    if exist "%~dp0dist\poppler-bin" (
        echo Found Poppler in dist folder, copying files...
        xcopy /E /Y "%~dp0dist\poppler-bin\*.*" "%~dp0poppler-bin\"
    ) else (
        echo Please run setup_poppler.bat to download and install Poppler.
        echo Press any key to continue anyway...
        pause >nul
    )
)

REM Make Poppler binaries available in the current directory as well
if exist "%~dp0poppler-bin\pdftoppm.exe" (
    if not exist "%~dp0pdftoppm.exe" (
        echo Copying essential Poppler files to application directory...
        copy "%~dp0poppler-bin\pdftoppm.exe" "%~dp0pdftoppm.exe" >nul
        copy "%~dp0poppler-bin\poppler.dll" "%~dp0poppler.dll" >nul
        copy "%~dp0poppler-bin\freetype.dll" "%~dp0freetype.dll" >nul
        copy "%~dp0poppler-bin\zlib.dll" "%~dp0zlib.dll" >nul
        copy "%~dp0poppler-bin\libpng16.dll" "%~dp0libpng16.dll" >nul
        copy "%~dp0poppler-bin\jpeg8.dll" "%~dp0jpeg8.dll" >nul
    )
)

REM Set the correct paths for DLLs with higher priority than system paths
set PATH=%~dp0;%~dp0poppler-bin;%PATH%

echo Using PATH: %PATH%

REM Check for the executable
if not exist "%~dp0PDF2PNG_Converter.exe" (
    echo ERROR: PDF2PNG_Converter.exe not found!
    echo Please ensure the application is properly installed.
    pause
    exit /b 1
)

REM Create a documents directory if it doesn't exist
if not exist "%USERPROFILE%\Documents\PDF2PNG" (
    echo Creating output directory...
    mkdir "%USERPROFILE%\Documents\PDF2PNG"
)

echo Starting PDF2PNG Converter...
echo Output will be saved to: %USERPROFILE%\Documents\PDF2PNG

REM Run the application
start "" "%~dp0PDF2PNG_Converter.exe"

echo Application launched!
echo If the application doesn't start, please run troubleshoot.ps1 script.
echo If PDF conversion isn't working, check conversion_log.txt in the output folder.
echo.
timeout /t 10
