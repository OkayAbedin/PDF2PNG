import os
import subprocess
import sys
import ctypes

# Constants from WinUser.h
SW_HIDE = 0
SW_SHOW = 5

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def hide_console():
    kernel32 = ctypes.WinDLL('kernel32')
    user32 = ctypes.WinDLL('user32')
    
    hwnd = kernel32.GetConsoleWindow()
    if hwnd:
        user32.ShowWindow(hwnd, SW_HIDE)

def show_graphical_error(message):
    import tkinter as tk
    from tkinter import messagebox
    
    root = tk.Tk()
    root.withdraw()
    messagebox.showerror("PDF2PNG Converter Error", message)
    root.destroy()

def main():
    # Hide console window
    hide_console()
    
    # Get application directory
    if getattr(sys, 'frozen', False):
        app_dir = os.path.dirname(sys.executable)
    else:
        app_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Path to the executable
    exe_path = os.path.join(app_dir, "PDF2PNG_Converter.exe")
    
    if not os.path.exists(exe_path):
        show_graphical_error(f"Could not find {exe_path}.\nPlease ensure the application is properly installed.")
        return
    
    # Launch the application
    try:
        # Use subprocess.Popen to avoid opening a console window
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startupinfo.wShowWindow = SW_HIDE
        
        subprocess.Popen(
            [exe_path],
            startupinfo=startupinfo,
            creationflags=subprocess.CREATE_NO_WINDOW
        )
    except Exception as e:
        show_graphical_error(f"Error launching PDF2PNG Converter:\n{str(e)}")

if __name__ == "__main__":
    main()
