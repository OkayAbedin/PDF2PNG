# PDF2PNG Converter User Guide

## Introduction

PDF2PNG Converter is a simple utility that allows you to convert PDF files to high-quality PNG images with just a few clicks. This guide will help you get started.

## Installation

1. Run the installer and follow the on-screen instructions.
2. Choose your preferred installation location:
   - Program Files (requires administrator privileges)
   - User AppData folder (no administrator privileges required)

## Using the Application

### Method 1: Using the System Tray Icon

1. After installation, the PDF2PNG Converter will appear in your system tray (the icons near the clock).
2. Right-click on the icon to see the menu:
   - **Convert PDF to PNG**: Opens a file dialog to select a PDF file to convert.
   - **Open Output Folder**: Opens the folder where converted images are stored.
   - **Run at Startup**: Toggle option to run the application automatically when Windows starts.
   - **Exit**: Closes the application.

### Method 2: Right-click on PDF Files

1. In Windows Explorer, right-click on any PDF file.
2. Select "Convert to PNG" from the context menu.
3. The PDF will be converted and the output folder will open automatically.

## Output Location

By default, all converted PNG images are saved in:
```
C:\Users\[YourUsername]\Documents\PDF2PNG\
```

Each PDF gets its own subfolder with the same name as the PDF file.

## Troubleshooting

### If the application doesn't start:

1. Try running the application as administrator.
2. Check if the application is blocked by your antivirus software.
3. Run the `troubleshoot.ps1` script included in the installation folder.

### If PDF conversion doesn't work:

1. Check the `conversion_log.txt` file in the output folder for error details.
2. **Most common solution:** Run the `fix_poppler.bat` script included in the installation folder.
3. Make sure the Poppler binaries are properly installed in the application folder.
4. If you see errors about "pdftoppm not found" or "Unable to get page count", this means the Poppler binaries are missing or not properly detected.
5. Run the `setup_poppler.bat` script to download and install the Poppler binaries.
6. Try reinstalling the application with administrator privileges.

#### Advanced Poppler Troubleshooting

If you continue to have issues with PDF conversion:

1. Verify that you have the `poppler-bin` folder in your installation directory.
2. Check that the folder contains files like `pdftoppm.exe`, `poppler.dll`, etc.
3. Make sure Windows Defender or other security software isn't blocking these executables.
4. Try downloading Poppler manually from [GitHub](https://github.com/oschwartz10612/poppler-windows/releases/) and extract the binaries to the `poppler-bin` folder.
5. Create a file called `poppler_path.txt` in the installation folder containing the full path to your Poppler binaries.

## Support

If you encounter any issues or have questions, please contact support at:
support@your-company.com

------------------
PDF2PNG Converter v1.0.0
