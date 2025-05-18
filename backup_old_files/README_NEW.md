# [DEPRECATED] Project Structure Planning Document

This file was used for planning the new project structure. The structure has now been implemented.

Please see README.md for the current project documentation.

## Original Planning Content

A simple Windows application to convert PDF files to PNG images with a single click.

## Project Structure

```
/
├── src/                  # Source code
│   ├── pdf2png_converter.py     # Main application code
│   └── start_pdf2png.py         # Starter script (without console)
├── resources/            # Application resources
│   ├── icon.ico          # Application icon
│   └── banner.txt        # Banner text
├── bin/                  # Binary dependencies
│   └── poppler-bin/      # Poppler binaries
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
   python src/pdf2png_converter.py
   ```

## Building the Application

To build the application:

1. Make sure you have NSIS (Nullsoft Scriptable Install System) installed
2. Run the build script:
   ```
   build/build.bat
   ```
3. The installer will be created in the project root directory

## License

© 2025 Minhazul Abedin | OkayAbedin
All rights reserved.
