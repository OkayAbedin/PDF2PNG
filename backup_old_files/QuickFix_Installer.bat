@echo off
REM PDF2PNG Converter - Quick Fix Script
REM This script quickly fixes installation issues by copying files to the right locations

echo PDF2PNG Converter - Quick Fix Script
echo ===================================
echo.

REM Define source and destination paths
set SOURCE_DIR=%~dp0
set DEST_DIR=%LOCALAPPDATA%\PDF2PNG Converter
set POPPLER_SOURCE=%SOURCE_DIR%poppler-bin
set MAIN_SOURCE=%SOURCE_DIR%dist\PDF2PNG_Converter.exe
set STARTER_SOURCE=%SOURCE_DIR%dist\PDF2PNG_Starter.exe

echo Source directory: %SOURCE_DIR%
echo Destination directory: %DEST_DIR%
echo.

REM Check if source files exist
if not exist "%MAIN_SOURCE%" (
    echo ERROR: Cannot find main executable at %MAIN_SOURCE%
    echo Ensure you have built the application using build.bat
    goto :error
)

if not exist "%STARTER_SOURCE%" (
    echo ERROR: Cannot find starter executable at %STARTER_SOURCE%
    echo Ensure you have built the application using build.bat
    goto :error
)

if not exist "%POPPLER_SOURCE%" (
    echo ERROR: Cannot find Poppler binaries at %POPPLER_SOURCE%
    echo Please run setup_poppler.bat first
    goto :error
)

REM Create destination directory if it doesn't exist
if not exist "%DEST_DIR%" (
    echo Creating destination directory...
    mkdir "%DEST_DIR%"
)

REM Create output directory
set OUTPUT_DIR=%USERPROFILE%\Documents\PDF2PNG
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

REM Copy executables
echo Copying executables...
echo From: %MAIN_SOURCE%
echo To: %DEST_DIR%\PDF2PNG_Converter.exe

if not exist "%MAIN_SOURCE%" (
    echo ERROR: Source main executable does not exist at: %MAIN_SOURCE%
    dir "%SOURCE_DIR%dist"
    goto :error
)

copy /Y "%MAIN_SOURCE%" "%DEST_DIR%\PDF2PNG_Converter.exe"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to copy main executable
    echo ErrorLevel: %ERRORLEVEL%
    goto :error
) else (
    echo Main executable copied successfully
)

echo From: %STARTER_SOURCE%
echo To: %DEST_DIR%\PDF2PNG_Starter.exe

if not exist "%STARTER_SOURCE%" (
    echo ERROR: Source starter executable does not exist at: %STARTER_SOURCE%
    dir "%SOURCE_DIR%dist"
    goto :error
)

copy /Y "%STARTER_SOURCE%" "%DEST_DIR%\PDF2PNG_Starter.exe"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to copy starter executable
    echo ErrorLevel: %ERRORLEVEL%
    goto :error
) else (
    echo Starter executable copied successfully
)

REM Copy icon
copy /Y "%SOURCE_DIR%icon.ico" "%DEST_DIR%\" > nul

REM Copy Poppler binaries
echo Copying Poppler binaries...
if not exist "%DEST_DIR%\poppler-bin" mkdir "%DEST_DIR%\poppler-bin"
xcopy /E /Y "%POPPLER_SOURCE%\*.*" "%DEST_DIR%\poppler-bin\" > nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to copy Poppler binaries
    goto :error
)

REM Copy other necessary files
echo Copying support files...
copy /Y "%SOURCE_DIR%Enhanced_Launcher.bat" "%DEST_DIR%\" > nul
copy /Y "%SOURCE_DIR%EULA.txt" "%DEST_DIR%\" > nul
copy /Y "%SOURCE_DIR%release_notes.md" "%DEST_DIR%\" > nul
copy /Y "%SOURCE_DIR%banner.txt" "%DEST_DIR%\" > nul

REM Create shortcuts
echo Creating shortcuts...
set SHORTCUT_CMD=powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\PDF2PNG Converter.lnk'); $s.TargetPath = '%DEST_DIR%\Enhanced_Launcher.bat'; $s.IconLocation = '%DEST_DIR%\icon.ico'; $s.Save()"
%SHORTCUT_CMD%

set MENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\PDF2PNG Converter
if not exist "%MENU_DIR%" mkdir "%MENU_DIR%"

set MENU_SHORTCUT_CMD=powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%MENU_DIR%\PDF2PNG Converter.lnk'); $s.TargetPath = '%DEST_DIR%\Enhanced_Launcher.bat'; $s.IconLocation = '%DEST_DIR%\icon.ico'; $s.Save()"
%MENU_SHORTCUT_CMD%

set MENU_UNINSTALL_CMD=powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%MENU_DIR%\Uninstall PDF2PNG Converter.lnk'); $s.TargetPath = 'cmd.exe'; $s.Arguments = '/c rd /s /q ""%DEST_DIR%"" && rd /s /q ""%MENU_DIR%"" && del ""%USERPROFILE%\Desktop\PDF2PNG Converter.lnk""'; $s.Save()"
%MENU_UNINSTALL_CMD%

echo.
echo Installation complete!
echo.
echo Would you like to run PDF2PNG Converter now? (Y/N)
set /p choice=
if /i "%choice%"=="Y" (
    start "" "%DEST_DIR%\Enhanced_Launcher.bat"
)

goto :eof

:error
echo.
echo An error occurred during the installation process.
echo Please fix the errors above and try again.
echo.
pause
