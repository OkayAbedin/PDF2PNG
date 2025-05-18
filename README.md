# PDF2PNG Converter

![](resources/icon.ico)

> Convert PDF files to high-quality PNG images with just a single click

**Version:** 1.0.0  
**Released:** May 18, 2025  
**Developed by:** Minhazul Abedin | OkayAbedin

---

## 📋 Overview

PDF2PNG Converter is a lightweight Windows utility that seamlessly converts PDF documents to PNG image files. The application provides a user-friendly interface through the system tray and integrates with Windows Explorer for quick right-click conversion.

## ✨ Key Features

- **Simple Interface:** Access via system tray icon
- **Windows Integration:** Right-click on any PDF file to convert directly
- **High-Quality Output:** Creates crisp, clear PNG images
- **Auto-Open:** Output folder opens automatically after conversion
- **Startup Option:** Configure to run when Windows starts
- **Minimal Footprint:** Small installation size with all dependencies included

## 🚀 Getting Started

### Installation

**For End Users:**
1. Download and run the installer (`PDF2PNG_Converter_Setup.exe`)
2. Follow the installation wizard to:
   - Choose your installation location
   - Create desktop and Start Menu shortcuts
   - Add right-click context menu integration for PDF files

### Usage

**Method 1: System Tray**
1. Click the PDF2PNG icon in your system tray
2. Select "Convert PDF to PNG" from the menu
3. Choose a PDF file from the file picker
4. Wait for conversion to complete
5. Explore the automatically opened output folder

**Method 2: Right-Click Menu**
1. Right-click on any PDF file in Windows Explorer
2. Select "Convert to PNG" from the context menu
3. Wait for conversion to complete
4. Explore the automatically opened output folder

### Output Location

All converted PNG images are saved to:
```
%USERPROFILE%\Documents\PDF2PNG\
```

## 🧰 For Developers

### System Requirements

- Windows 10 or later
- Python 3.8+
- NSIS (for creating installers)

### Development Setup

1. Clone the repository
2. Install the required dependencies:
   ```
   pip install -r build/requirements.txt
   ```
3. Run the application in development mode:
   ```
   python src/splash.py
   ```

### Building the Application

1. Make sure all dependencies are installed
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

### Project Structure

```
/
├── src/                  # Source code
│   ├── pdf2png_converter.py     # Main conversion logic
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

### Dependencies

- **pdf2image:** Core PDF conversion functionality
- **pystray:** System tray interface implementation
- **Pillow:** Image processing and manipulation
- **PyInstaller:** Creates standalone executables
- **pywin32:** Windows integration capabilities
- **Poppler:** PDF rendering engine (included in bin directory)

## 📄 License

This project is licensed under the [MIT License](LICENSE)

## 👤 Author

Minhazul Abedin | OkayAbedin

## 📞 Support

If you encounter any issues or have questions, please submit an issue through the repository or contact the developer at contact.minhazabedin@gmail.com