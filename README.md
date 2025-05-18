# PDF2PNG Converter

A simple Windows application to convert PDF files to PNG images with a single click.

Developed by Minhazul Abedin | OkayAbedin

## Project Structure

```
/
├── src/                  # Source code
│   ├── pdf2png_converter.py     # Main application code
│   ├── splash.py                # Splash screen implementation
│   └── start_pdf2png.py         # Starter script (without console)
├── resources/            # Application resources
│   ├── icon.ico          # Application icon
│   └── banner.txt        # Banner text
├── bin/                  # Binary dependencies
│   └── poppler-bin/      # Poppler binaries for PDF processing
├── docs/                 # Documentation
│   ├── user_guide.md     # User guide
│   ├── release_notes.md  # Release notes
│   └── EULA.txt          # End User License Agreement
└── build/                # Build scripts and configuration
    ├── build.bat         # Main build script
    ├── PDF2PNG_Converter.spec  # PyInstaller spec for main app
    ├── requirements.txt  # Python dependencies
    └── installer.nsi     # NSIS installer script
```

## Features

- System tray icon for quick access
- Convert PDFs to high-quality PNG images
- Right-click on PDF files to convert directly
- Automatically opens the output folder after conversion
- Option to run at Windows startup

## Development Setup

1. Make sure you have Python 3.8+ installed
2. Install the required dependencies:
   ```
   pip install -r build/requirements.txt
   ```
3. Run the application in development mode:
   ```
   python src/splash.py
   ```

## Building the Application

To build the application into an executable:

1. Make sure you have all dependencies installed
2. Run the build script:
   ```
   cd build
   ./build.bat
   ```
3. The executables will be created in the `dist` folder
4. To create an installer, install NSIS and run:
   ```
   cd build
   makensis installer.nsi
   ```

## Installation

For end users, simply run the generated installer (`PDF2PNG_Converter_Setup.exe`). This will:
1. Install the application to your preferred location
2. Create desktop and Start Menu shortcuts
3. Add a right-click context menu for PDF files

## Usage

1. Click on the system tray icon to see the menu.
2. Select "Convert PDF to PNG" to choose a PDF file for conversion.
3. The PNG images will be saved to a folder in your Documents directory.
4. The output folder will open automatically after conversion.

Alternatively, you can right-click on any PDF file and select "Convert to PNG".

## Output Location

All converted PNG images are saved to:
```
%USERPROFILE%\Documents\PDF2PNG\
```

## Dependencies

- pdf2image (for PDF conversion)
- pystray (for system tray functionality)
- Pillow (for image processing)
- PyInstaller (for building the executable)
- pywin32 (for Windows integration)
- Poppler (included in the bin directory)

## License

[MIT License](LICENSE)

## Author

Minhazul Abedin | OkayAbedin
