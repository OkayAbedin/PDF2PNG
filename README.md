# PDF2PNG Converter

A simple Windows application to convert PDF files to PNG images with a single click.

## Features

- System tray icon for quick access
- Convert PDFs to high-quality PNG images
- Right-click on PDF files to convert directly
- Automatically opens the output folder after conversion
- Option to run at Windows startup

## Installation

### For Users

1. Download the latest installer (`PDF2PNG_Converter_Setup.exe`) from the releases.
2. Run the installer and follow the on-screen instructions.
3. Once installed, the application will appear in your system tray.

### For Developers

To build the application from source:

1. Make sure you have Python 3.8+ installed.
2. Clone this repository.
3. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```
4. To build the executable and installer:
   - Install NSIS (Nullsoft Scriptable Install System) from https://nsis.sourceforge.io/Download
   - Run `build.bat`

## Usage

1. Click on the system tray icon to see the menu.
2. Select "Convert PDF to PNG" to choose a PDF file for conversion.
3. The PNG images will be saved to a folder in your Documents directory.
4. The output folder will open automatically after conversion.

Alternatively, you can right-click on any PDF file and select "Convert to PNG".

## Dependencies

- pdf2image (for PDF conversion)
- pystray (for system tray functionality)
- Pillow (for image processing)
- PyInstaller (for building the executable)
- pywin32 (for Windows integration)
- Poppler (automatically included in the installer)

## License

[MIT License](LICENSE)

## Author

Your Name
