import os
import sys
import tempfile
import threading
from pathlib import Path
import tkinter as tk
from tkinter import Tk, filedialog, ttk
from PIL import Image
import pystray
from pystray import MenuItem as item
from pdf2image import convert_from_path
import winreg

# Set application name and version
APP_NAME = "PDF2PNG Converter"
APP_VERSION = "1.0.0"
COMPANY_NAME = "OkayAbedin"
AUTHOR = "Minhazul Abedin"

# Get application paths
if getattr(sys, 'frozen', False):
    # Running as compiled executable
    APPLICATION_PATH = os.path.dirname(sys.executable)
    ICON_PATH = os.path.join(APPLICATION_PATH, "icon.ico")
    
    # Set Poppler path - check multiple possible locations
    POPPLER_PATHS = [
        os.path.join(APPLICATION_PATH, "poppler-bin"),
        os.path.join(APPLICATION_PATH, "bin", "poppler-bin"),
        os.path.join(os.path.dirname(APPLICATION_PATH), "bin", "poppler-bin"),
        os.path.join(APPLICATION_PATH)
    ]
else:
    # Running as script
    APPLICATION_PATH = os.path.dirname(os.path.abspath(__file__))
    ICON_PATH = os.path.join(os.path.dirname(APPLICATION_PATH), "resources", "icon.ico")
    
    # Check multiple possible locations for poppler in dev environment
    POPPLER_PATHS = [
        os.path.join(os.path.dirname(APPLICATION_PATH), "bin", "poppler-bin"),
        os.path.join(os.path.dirname(APPLICATION_PATH), "poppler-bin"),
        os.path.join(APPLICATION_PATH, "poppler-bin")
    ]

# Try to find Poppler from config file first
CONFIG_FILE = os.path.join(APPLICATION_PATH, "poppler_path.txt")
if os.path.exists(CONFIG_FILE):
    try:
        with open(CONFIG_FILE, 'r') as f:
            config_poppler_path = f.read().strip()
            if os.path.exists(config_poppler_path):
                POPPLER_PATHS.insert(0, config_poppler_path)
                print(f"Added Poppler path from config: {config_poppler_path}")
    except:
        pass

# Find the first valid Poppler path
POPPLER_PATH = None
for path in POPPLER_PATHS:
    if os.path.exists(path) and os.path.isdir(path):
        # Check if path contains pdftoppm.exe (the main tool we need)
        if os.path.exists(os.path.join(path, "pdftoppm.exe")):
            POPPLER_PATH = path
            # Add to PATH environment variable
            os.environ["PATH"] = path + os.pathsep + os.environ["PATH"]
            print(f"Using Poppler path: {path}")
            break

# If no valid path found, try one more approach - add all possible paths to PATH
if POPPLER_PATH is None:
    for path in POPPLER_PATHS:
        if os.path.exists(path):
            os.environ["PATH"] = path + os.pathsep + os.environ["PATH"]
            print(f"Added path to environment: {path}")
            
    # Check if pdftoppm.exe is in the current directory
    if os.path.exists(os.path.join(APPLICATION_PATH, "pdftoppm.exe")):
        POPPLER_PATH = APPLICATION_PATH
        print(f"Using application directory for Poppler: {APPLICATION_PATH}")

OUTPUT_FOLDER = os.path.join(os.path.expanduser("~"), "Documents", "PDF2PNG")

# Ensure output directory exists
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def add_to_startup():
    """Add application to Windows startup"""
    try:
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0, winreg.KEY_SET_VALUE
        )
        
        # Get the path to the executable
        if getattr(sys, 'frozen', False):
            app_path = sys.executable
        else:
            app_path = os.path.abspath(__file__)
            
        winreg.SetValueEx(key, APP_NAME, 0, winreg.REG_SZ, f'"{app_path}"')
        winreg.CloseKey(key)
        return True
    except Exception as e:
        print(f"Error adding to startup: {e}")
        return False

def remove_from_startup():
    """Remove application from Windows startup"""
    try:
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0, winreg.KEY_SET_VALUE
        )
        winreg.DeleteValue(key, APP_NAME)
        winreg.CloseKey(key)
        return True
    except Exception as e:
        print(f"Error removing from startup: {e}")
        return False

def convert_pdf_to_png(pdf_path, output_folder=None):
    """Convert PDF file to PNG images"""
    if output_folder is None:
        output_folder = OUTPUT_FOLDER
    
    # Create log file for debugging
    log_file = os.path.join(OUTPUT_FOLDER, "conversion_log.txt")
    
    def log_message(message):
        with open(log_file, "a") as f:
            f.write(f"{message}\n")
        print(message)
    
    log_message(f"Starting conversion of {pdf_path}")
    log_message(f"Output folder: {output_folder}")
    log_message(f"Poppler path: {POPPLER_PATH}")
    log_message(f"PATH environment: {os.environ['PATH']}")
        
    # Create output folder if it doesn't exist
    os.makedirs(output_folder, exist_ok=True)
    
    # Get PDF file name without extension
    pdf_name = os.path.splitext(os.path.basename(pdf_path))[0]
    
    # Create subfolder for this PDF
    pdf_output_folder = os.path.join(output_folder, pdf_name)
    os.makedirs(pdf_output_folder, exist_ok=True)
    
    try:
        # Setup conversion arguments
        conversion_args = {}
        
        # Check if we have a valid Poppler path
        if POPPLER_PATH and os.path.exists(POPPLER_PATH):
            conversion_args['poppler_path'] = POPPLER_PATH
            log_message(f"Using Poppler path: {POPPLER_PATH}")
        else:
            log_message("WARNING: Predefined Poppler path not found!")
            
            # Check all possible locations for poppler
            possible_poppler_locations = [
                os.path.join(APPLICATION_PATH, "poppler-bin"),
                os.path.join(os.path.dirname(sys.executable) if getattr(sys, 'frozen', False) else APPLICATION_PATH, "poppler-bin"),
                os.path.join(APPLICATION_PATH, "dist", "poppler-bin"),
                os.path.join(os.path.dirname(APPLICATION_PATH) if getattr(sys, 'frozen', False) else APPLICATION_PATH, "poppler-bin"),
                r"C:\Program Files\poppler\bin",
                r"C:\Program Files (x86)\poppler\bin",
                r"C:\poppler\bin",
            ]
            
            # Also check if we have the binaries in the current directory
            if getattr(sys, 'frozen', False):
                possible_poppler_locations.append(os.path.dirname(sys.executable))
            
            # Try to find a working Poppler installation
            import shutil
            for possible_path in possible_poppler_locations:
                if os.path.exists(possible_path):
                    log_message(f"Found potential Poppler directory: {possible_path}")
                    if os.path.exists(os.path.join(possible_path, "pdftoppm.exe")):
                        log_message(f"Found pdftoppm.exe at: {possible_path}")
                        conversion_args['poppler_path'] = possible_path
                        # Add to PATH as well
                        os.environ["PATH"] = possible_path + os.pathsep + os.environ["PATH"]
                        break
            
            # If still not found, try to find pdftoppm.exe in PATH as a last resort
            if 'poppler_path' not in conversion_args:
                pdftoppm_path = shutil.which("pdftoppm")
                if pdftoppm_path:
                    poppler_dir = os.path.dirname(pdftoppm_path)
                    log_message(f"Found pdftoppm in PATH at: {pdftoppm_path}")
                    conversion_args['poppler_path'] = poppler_dir
                else:
                    log_message("ERROR: pdftoppm not found in PATH or any standard location!")
                    
                    # Final attempt: Try to extract Poppler binaries from resource
                    try:
                        temp_dir = os.path.join(tempfile.gettempdir(), "pdf2png_poppler")
                        os.makedirs(temp_dir, exist_ok=True)
                        log_message(f"Creating temporary Poppler directory at: {temp_dir}")
                        
                        # Copy poppler files from application directory if they exist
                        src_dir = os.path.join(APPLICATION_PATH, "poppler-bin")
                        if os.path.exists(src_dir):
                            for file in os.listdir(src_dir):
                                src_file = os.path.join(src_dir, file)
                                dst_file = os.path.join(temp_dir, file)
                                if os.path.isfile(src_file) and not os.path.exists(dst_file):
                                    shutil.copy2(src_file, dst_file)
                                    log_message(f"Copied {file} to temporary directory")
                            
                            conversion_args['poppler_path'] = temp_dir
                            os.environ["PATH"] = temp_dir + os.pathsep + os.environ["PATH"]
                    except Exception as e:
                        log_message(f"Failed to create temporary Poppler directory: {str(e)}")
        
        # List directory contents to check if Poppler files exist in the selected path
        if 'poppler_path' in conversion_args and os.path.exists(conversion_args['poppler_path']):
            selected_path = conversion_args['poppler_path']
            log_message(f"Selected Poppler directory contents at {selected_path}:")
            for file in os.listdir(selected_path):
                log_message(f"  - {file}")
        else:
            log_message("WARNING: No valid Poppler directory was found!")
            
            # One last desperate attempt - copy our poppler binaries directly to the working directory
            log_message("Making last attempt to provide Poppler binaries...")
            try:
                if os.path.exists("d:/AutomationScripts/PDF2PNG/poppler-bin"):
                    # Copy the pdftoppm.exe file directly to the local directory
                    src_file = "d:/AutomationScripts/PDF2PNG/poppler-bin/pdftoppm.exe"
                    dst_dir = os.path.dirname(os.path.abspath(__file__)) if not getattr(sys, 'frozen', False) else os.path.dirname(sys.executable)
                    dst_file = os.path.join(dst_dir, "pdftoppm.exe")
                    
                    if os.path.exists(src_file) and not os.path.exists(dst_file):
                        import shutil
                        shutil.copy2(src_file, dst_file)
                        log_message(f"Copied pdftoppm.exe to working directory: {dst_dir}")
                        
                        # Also copy required DLLs
                        for dll in ["poppler.dll", "freetype.dll", "libpng16.dll", "zlib.dll", "jpeg8.dll"]:
                            src_dll = f"d:/AutomationScripts/PDF2PNG/poppler-bin/{dll}"
                            dst_dll = os.path.join(dst_dir, dll)
                            if os.path.exists(src_dll) and not os.path.exists(dst_dll):
                                shutil.copy2(src_dll, dst_dll)
                                log_message(f"Copied {dll} to working directory")
                        
                        # Use working directory for Poppler
                        conversion_args['poppler_path'] = dst_dir
            except Exception as e:
                log_message(f"Last attempt failed: {str(e)}")
        
        # Convert PDF to images
        log_message("Starting PDF conversion...")
        images = convert_from_path(pdf_path, **conversion_args)
        
        log_message(f"Conversion successful! Got {len(images)} pages.")
        
        # Save each page as PNG
        for i, image in enumerate(images):
            image_path = os.path.join(pdf_output_folder, f"{pdf_name}_page_{i+1}.png")
            image.save(image_path, "PNG")
            log_message(f"Saved page {i+1} to {image_path}")
            
        return pdf_output_folder
    except Exception as e:
        log_message(f"ERROR converting PDF: {str(e)}")
        import traceback
        log_message(traceback.format_exc())
        return None

def select_and_convert_pdf():
    """Open file dialog to select PDF and convert it"""
    # Create and hide the root window
    root = Tk()
    root.withdraw()
    
    # Open file dialog
    pdf_path = filedialog.askopenfilename(
        title="Select PDF file to convert",
        filetypes=[("PDF Files", "*.pdf")]
    )
    
    root.destroy()
    
    if pdf_path:
        # Create a progress indication
        progress_root = Tk()
        progress_root.withdraw()  # Hide the main window
        
        # Configure the progress window
        progress_window = tk.Toplevel(progress_root)
        progress_window.title("Converting PDF")
        progress_window.geometry("300x100")
        progress_window.resizable(False, False)
        
        # Center the window
        window_width = 300
        window_height = 100
        screen_width = progress_window.winfo_screenwidth()
        screen_height = progress_window.winfo_screenheight()
        center_x = int(screen_width/2 - window_width/2)
        center_y = int(screen_height/2 - window_height/2)
        progress_window.geometry(f'{window_width}x{window_height}+{center_x}+{center_y}')
        
        # Add company logo/icon if available
        if os.path.exists(ICON_PATH):
            progress_window.iconbitmap(ICON_PATH)
        
        # Add message and progress bar
        message_label = tk.Label(progress_window, text=f"Converting PDF to PNG...\nPlease wait")
        message_label.pack(pady=10)
        
        progress = tk.ttk.Progressbar(progress_window, mode="indeterminate", length=250)
        progress.pack(pady=10)
        progress.start()
        
        # Function to perform conversion in background
        def do_conversion():
            nonlocal pdf_path
            output_path = convert_pdf_to_png(pdf_path)
            progress_window.after(500, lambda: conversion_complete(output_path))
        
        # Function to handle conversion completion
        def conversion_complete(output_path):
            progress_window.destroy()
            progress_root.destroy()
            if output_path:
                # Open the output folder
                os.startfile(output_path)
        
        # Start conversion in a separate thread to keep UI responsive
        threading.Thread(target=do_conversion, daemon=True).start()
        
        # Start the Tkinter event loop
        progress_root.mainloop()
        
        return True
    return False

def show_about_dialog():
    """Show an about dialog with company information"""
    # Create and hide the root window
    root = tk.Tk()
    root.withdraw()
    
    # Make sure the app won't freeze
    root.after(0, lambda: show_about_message(root))
    
    # Keep the dialog alive until closed
    root.mainloop()

def show_about_message(root):
    """Helper function to show the about dialog and handle closing"""
    from tkinter import messagebox
    
    # Show about message
    messagebox.showinfo(
        title=f"About {APP_NAME}",
        message=f"{APP_NAME} v{APP_VERSION}\n\n" +
                f"© 2025 {AUTHOR}\n" +
                f"{COMPANY_NAME}\n\n" +
                "A simple utility to convert PDF files to PNG images."
    )
    
    # Destroy the root window to close the dialog properly
    root.destroy()

def create_tray_icon():
    """Create system tray icon with menu"""
    # Check if icon file exists, use a default if not
    icon_img = Image.open(ICON_PATH) if os.path.exists(ICON_PATH) else Image.new('RGB', (64, 64), color='red')
    
    # Define menu items
    menu = (
        item('Convert PDF to PNG', select_and_convert_pdf),
        item('Open Output Folder', lambda: os.startfile(OUTPUT_FOLDER)),
        item('Run at Startup', lambda: add_to_startup(), checked=lambda _: is_in_startup()),
        item('About', show_about_dialog),
        item('Exit', lambda: icon.stop())
    )
    
    # Create icon
    global icon
    icon = pystray.Icon(APP_NAME, icon_img, APP_NAME, menu)
    
    # Run icon
    icon.run()

def is_in_startup():
    """Check if application is in Windows startup"""
    try:
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0, winreg.KEY_READ
        )
        try:
            value, _ = winreg.QueryValueEx(key, APP_NAME)
            winreg.CloseKey(key)
            return True
        except:
            winreg.CloseKey(key)
            return False
    except:
        return False

def main():
    """Main application entry point"""
    # Create the system tray icon
    create_tray_icon()

if __name__ == "__main__":
    # Check if the app was run with arguments (for PDF dropping)
    if len(sys.argv) > 1 and os.path.isfile(sys.argv[1]) and sys.argv[1].lower().endswith('.pdf'):
        output_path = convert_pdf_to_png(sys.argv[1])
        if output_path:
            os.startfile(output_path)
    else:
        main()
