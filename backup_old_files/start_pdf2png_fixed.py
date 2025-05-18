import os
import sys
import subprocess
import tkinter as tk
from tkinter import messagebox

def show_error(message):
    """Display an error message in a GUI dialog"""
    root = tk.Tk()
    root.withdraw()
    messagebox.showerror("PDF2PNG Converter Error", message)
    root.destroy()

def main():
    """Main entry point for the starter executable"""
    # Get current directory (where the starter executable is)
    if getattr(sys, 'frozen', False):
        app_dir = os.path.dirname(sys.executable)
    else:
        app_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Path to the main converter executable
    main_exe = os.path.join(app_dir, "PDF2PNG_Converter.exe")
    
    # Check if the main executable exists
    if not os.path.exists(main_exe):
        show_error(f"Could not find {main_exe}.\nPlease ensure the application is properly installed.")
        return
    
    # Set environment variable for Poppler path
    poppler_path = os.path.join(app_dir, "poppler-bin")
    if os.path.exists(poppler_path):
        os.environ["PATH"] = f"{poppler_path};{app_dir};{os.environ['PATH']}"
    else:
        show_error(f"Could not find Poppler binaries at {poppler_path}.\nPDF conversion may not work properly.")
    
    # Create output directory if it doesn't exist
    output_dir = os.path.join(os.path.expanduser("~"), "Documents", "PDF2PNG")
    os.makedirs(output_dir, exist_ok=True)
    
    try:
        # Launch the main converter using subprocess
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        
        # Use CREATE_NO_WINDOW flag to prevent console window
        process = subprocess.Popen(
            [main_exe],
            startupinfo=startupinfo,
            creationflags=subprocess.CREATE_NO_WINDOW,
            env=os.environ
        )
        
        # Don't wait for process to finish - allow it to run independently
    except Exception as e:
        show_error(f"Error launching PDF2PNG Converter:\n{str(e)}")

if __name__ == "__main__":
    main()
