@echo off
echo Cleaning build files...

if exist "build" (
    echo Removing build directory...
    rmdir /S /Q "build"
)

if exist "dist" (
    echo Removing dist directory...
    rmdir /S /Q "dist"
)

if exist "PDF2PNG_Converter_Setup.exe" (
    echo Removing installer...
    del "PDF2PNG_Converter_Setup.exe"
)

if exist "__pycache__" (
    echo Removing __pycache__ directory...
    rmdir /S /Q "__pycache__"
)

echo Clean completed!
echo You can now run build.bat to rebuild the application.
pause
