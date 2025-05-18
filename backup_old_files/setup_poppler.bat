@echo off
echo Downloading and extracting Poppler for PDF2PNG...

REM Create temp directory for downloads
if not exist "temp" mkdir temp

REM Download Poppler
echo Downloading Poppler...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/oschwartz10612/poppler-windows/releases/download/v23.08.0-0/Release-23.08.0-0.zip' -OutFile 'temp\poppler.zip'"

REM Extract Poppler
echo Extracting Poppler...
powershell -Command "Expand-Archive -Path 'temp\poppler.zip' -DestinationPath 'temp' -Force"

REM Create poppler-bin directory
if not exist "poppler-bin" mkdir poppler-bin

REM Copy the necessary DLLs and executables to poppler-bin
echo Copying Poppler binaries...
xcopy /y "temp\poppler-23.08.0\Library\bin\*.*" "poppler-bin\"

REM Clean up temp directory
echo Cleaning up...
rmdir /s /q temp

echo Poppler has been set up successfully!
echo Now you can rebuild the application with build.bat
pause
