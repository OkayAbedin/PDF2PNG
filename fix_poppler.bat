@echo off
echo ===============================
echo PDF2PNG - Fix Poppler Issues
echo ===============================
echo.

echo This script will fix common issues with Poppler binaries.
echo The PDF to PNG conversion requires Poppler to work correctly.
echo.

REM Check if we're running from the right directory
if not exist "PDF2PNG_Converter.exe" (
    echo ERROR: This script should be run from the PDF2PNG Converter installation directory.
    echo Please navigate to the installation directory and run this script again.
    goto :EOF
)

echo Checking for Poppler installation...
if not exist "poppler-bin" (
    echo Creating poppler-bin directory...
    mkdir "poppler-bin"
)

if exist "poppler-bin\pdftoppm.exe" (
    echo Poppler seems to be already installed.
) else (
    echo Poppler binaries are missing!
    echo Attempting to download Poppler...
    
    if exist "setup_poppler.bat" (
        echo Running setup_poppler.bat...
        call setup_poppler.bat
    ) else (
        echo Download/extraction failed. Checking for alternative sources...
        
        if exist "dist\poppler-bin" (
            echo Found poppler in dist directory, copying files...
            xcopy /E /Y "dist\poppler-bin\*.*" "poppler-bin\"
        ) else (
            echo ERROR: Could not find Poppler binaries.
            echo Please download Poppler from https://github.com/oschwartz10612/poppler-windows/releases/
            echo and extract the 'bin' folder contents to the 'poppler-bin' folder in this directory.
            pause
            goto :EOF
        )
    )
)

echo.
echo Making Poppler binaries directly available to the application...
copy "poppler-bin\pdftoppm.exe" "pdftoppm.exe" >nul 2>&1
copy "poppler-bin\poppler.dll" "poppler.dll" >nul 2>&1
copy "poppler-bin\freetype.dll" "freetype.dll" >nul 2>&1
copy "poppler-bin\zlib.dll" "zlib.dll" >nul 2>&1
copy "poppler-bin\libpng16.dll" "libpng16.dll" >nul 2>&1
copy "poppler-bin\jpeg8.dll" "jpeg8.dll" >nul 2>&1

echo Creating a configuration file to help the application find Poppler...
echo %CD%\poppler-bin > poppler_path.txt

echo.
echo Poppler setup complete!
echo You should now be able to convert PDF files to PNG.
echo.

echo Press any key to launch the application...
pause >nul
start "" "Run_PDF2PNG_Converter.bat"
