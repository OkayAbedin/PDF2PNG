import os
import sys
import tkinter as tk
from PIL import Image, ImageTk
import threading
import time

# Set application name and version
APP_NAME = "PDF2PNG Converter"
APP_VERSION = "1.0.0"
COMPANY_NAME = "OkayAbedin"
AUTHOR = "Minhazul Abedin"

def get_app_path():
    """Get application path"""
    if getattr(sys, 'frozen', False):
        # Running as compiled executable
        application_path = os.path.dirname(sys.executable)
    else:
        # Running as script
        application_path = os.path.dirname(os.path.abspath(__file__))
    return application_path

def get_resource_path():
    """Get resource path"""
    if getattr(sys, 'frozen', False):
        # Running as compiled executable (resources are in the executable directory)
        resource_path = os.path.dirname(sys.executable)
    else:
        # Running as script (resources are in the parent's resources directory)
        resource_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "resources")
    return resource_path

def show_splash():
    """Display splash screen"""
    # Create root window
    root = tk.Tk()
    root.overrideredirect(True)  # Remove window decorations
    
    # Get screen dimensions
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    
    # Set window dimensions and position
    width = 400
    height = 300
    x = (screen_width // 2) - (width // 2)
    y = (screen_height // 2) - (height // 2)
    root.geometry(f"{width}x{height}+{x}+{y}")
    
    # Set background color
    root.configure(bg="#FFFFFF")
    
    # Add border
    border_frame = tk.Frame(root, bg="#0078D7")
    border_frame.pack(fill=tk.BOTH, expand=True, padx=2, pady=2)
      # Content frame
    content_frame = tk.Frame(border_frame, bg="#FFFFFF")
    content_frame.pack(fill=tk.BOTH, expand=True, padx=2, pady=2)
    
    # Load logo
    icon_path = os.path.join(get_resource_path(), "icon.ico")
    if os.path.exists(icon_path):
        try:
            # Convert ICO to a size we can use
            img = Image.open(icon_path)
            img = img.resize((128, 128), Image.LANCZOS)
            logo = ImageTk.PhotoImage(img)
            
            # Display logo
            logo_label = tk.Label(content_frame, image=logo, bg="#FFFFFF")
            logo_label.image = logo  # Keep a reference
            logo_label.pack(pady=20)
        except Exception as e:
            print(f"Error loading icon: {e}")
    
    # Application title
    title_label = tk.Label(content_frame, text=APP_NAME, font=("Arial", 20, "bold"), bg="#FFFFFF", fg="#0078D7")
    title_label.pack()
    
    # Version and company info
    version_label = tk.Label(content_frame, text=f"Version {APP_VERSION}", font=("Arial", 10), bg="#FFFFFF")
    version_label.pack()
    
    company_label = tk.Label(content_frame, text=f"© 2025 {AUTHOR}\n{COMPANY_NAME}", font=("Arial", 10), bg="#FFFFFF")
    company_label.pack(pady=10)
    
    # Progress bar
    progress_frame = tk.Frame(content_frame, bg="#FFFFFF")
    progress_frame.pack(fill=tk.X, padx=50, pady=10)
    
    progress_bar = tk.Canvas(progress_frame, height=6, bg="#E0E0E0", highlightthickness=0)
    progress_bar.pack(fill=tk.X)
    
    # Animated progress indicator
    progress_width = 0
    progress_item = progress_bar.create_rectangle(0, 0, progress_width, 6, fill="#0078D7", outline="")
    
    def update_progress():
        nonlocal progress_width
        max_width = progress_frame.winfo_width()
        
        for i in range(100):
            if root.winfo_exists():
                progress_width = int((i + 1) * max_width / 100)
                progress_bar.coords(progress_item, 0, 0, progress_width, 6)
                root.update()
                time.sleep(0.02)
          # Start main application
        root.after(500, start_main_app, root)
    
    def start_main_app(splash_root):
        # Close splash screen
        splash_root.destroy()
        
        # Import main module
        import sys
        import os
        
        # Adjust path to find the main module
        if not getattr(sys, 'frozen', False):
            # Add parent directory to path when running as a script
            sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            from src.pdf2png_converter import main
        else:
            # When frozen, import should work directly
            from pdf2png_converter import main
            
        main()
    
    # Start progress animation in a separate thread
    root.update()
    threading.Thread(target=update_progress, daemon=True).start()
    
    # Start main loop
    root.mainloop()

if __name__ == "__main__":
    show_splash()
