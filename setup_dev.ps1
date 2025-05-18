# Development Setup Script for PDF2PNG Converter
# This script helps set up the development environment and install necessary dependencies

# Check if Python is installed
try {
    $pythonVersion = python --version
    Write-Host "Found $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Python 3.8+ from https://www.python.org/downloads/" -ForegroundColor Yellow
    exit
}

# Create and activate virtual environment
Write-Host "Setting up virtual environment..." -ForegroundColor Cyan
python -m venv venv
if ($?) {
    Write-Host "Virtual environment created" -ForegroundColor Green
    
    # Activate virtual environment
    Write-Host "Activating virtual environment..." -ForegroundColor Cyan
    .\venv\Scripts\Activate.ps1
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    pip install -r requirements.txt
    
    if ($?) {
        Write-Host "Dependencies installed successfully!" -ForegroundColor Green
        
        # Poppler for Windows is required for pdf2image
        Write-Host "Downloading Poppler for Windows..." -ForegroundColor Cyan
        
        # Create temp directory for downloads
        $tempDir = New-Item -ItemType Directory -Force -Path ".\temp"
        $popplerZip = Join-Path $tempDir.FullName "poppler-windows.zip"
        $popplerDir = Join-Path (Get-Location) "poppler-windows"
        
        # Download poppler
        Invoke-WebRequest -Uri "https://github.com/oschwartz10612/poppler-windows/releases/download/v23.08.0-0/Release-23.08.0-0.zip" -OutFile $popplerZip
        
        # Extract poppler
        Write-Host "Extracting Poppler..." -ForegroundColor Cyan
        Expand-Archive -Path $popplerZip -DestinationPath $tempDir -Force
        
        # Move to proper location
        if (Test-Path $popplerDir) {
            Remove-Item -Path $popplerDir -Recurse -Force
        }
        Move-Item -Path (Join-Path $tempDir "poppler-23.08.0") -Destination $popplerDir
        
        # Clean up
        Remove-Item -Path $tempDir -Recurse -Force
        
        # Set environment variable for this session
        $env:PATH = "$env:PATH;$popplerDir\Library\bin"
        [System.Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$popplerDir\Library\bin", "Process")
        
        Write-Host "Development environment setup complete!" -ForegroundColor Green
        Write-Host "You can run the application with: python pdf2png_converter.py" -ForegroundColor Green
        
        # Ask if the user wants to run the application
        $runApp = Read-Host "Do you want to run the application now? (Y/N)"
        if ($runApp -eq "Y" -or $runApp -eq "y") {
            Write-Host "Running PDF2PNG Converter..." -ForegroundColor Cyan
            python pdf2png_converter.py
        }
    } else {
        Write-Host "Failed to install dependencies" -ForegroundColor Red
    }
} else {
    Write-Host "Failed to create virtual environment" -ForegroundColor Red
}
