# Complete Fix Script for PDF2PNG Converter
# This script performs a clean build and installation

Write-Host "PDF2PNG Converter - Complete Fix Script" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host

# Set paths
$sourceDir = "D:\AutomationScripts\PDF2PNG"
$installDir = "$env:LOCALAPPDATA\PDF2PNG Converter"
$outputDir = "$env:USERPROFILE\Documents\PDF2PNG"

Write-Host "Source directory: $sourceDir" -ForegroundColor Cyan
Write-Host "Install directory: $installDir" -ForegroundColor Cyan
Write-Host "Output directory: $outputDir" -ForegroundColor Cyan
Write-Host

# Step 1: Clean previous build artifacts
Write-Host "Step 1: Cleaning previous build artifacts..." -ForegroundColor Yellow
if (Test-Path "$sourceDir\build") {
    Remove-Item -Path "$sourceDir\build" -Recurse -Force
    Write-Host "  Removed build directory" -ForegroundColor Green
}

if (Test-Path "$sourceDir\dist") {
    Remove-Item -Path "$sourceDir\dist" -Recurse -Force
    Write-Host "  Removed dist directory" -ForegroundColor Green
}

# Step 2: Run PyInstaller to build executables
Write-Host "Step 2: Building executables with PyInstaller..." -ForegroundColor Yellow

# Main executable
Write-Host "  Building main converter executable..." -ForegroundColor Yellow
$mainBuildResult = Start-Process -FilePath "python" -ArgumentList "-m PyInstaller $sourceDir\PDF2PNG_Converter.spec" -WorkingDirectory $sourceDir -NoNewWindow -Wait -PassThru
if ($mainBuildResult.ExitCode -ne 0) {
    Write-Host "  ERROR: Failed to build main executable. Exit code: $($mainBuildResult.ExitCode)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  Main executable built successfully" -ForegroundColor Green
}

# Starter executable
Write-Host "  Building starter executable..." -ForegroundColor Yellow
$starterBuildResult = Start-Process -FilePath "python" -ArgumentList "-m PyInstaller --onefile --noconsole --icon=$sourceDir\icon.ico --name=PDF2PNG_Starter $sourceDir\start_pdf2png.py" -WorkingDirectory $sourceDir -NoNewWindow -Wait -PassThru
if ($starterBuildResult.ExitCode -ne 0) {
    Write-Host "  ERROR: Failed to build starter executable. Exit code: $($starterBuildResult.ExitCode)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  Starter executable built successfully" -ForegroundColor Green
}

# Step 3: Create installation directory
Write-Host "Step 3: Creating installation directory..." -ForegroundColor Yellow
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    Write-Host "  Created installation directory: $installDir" -ForegroundColor Green
} else {
    Write-Host "  Installation directory already exists" -ForegroundColor Green
}

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    Write-Host "  Created output directory: $outputDir" -ForegroundColor Green
} else {
    Write-Host "  Output directory already exists" -ForegroundColor Green
}

# Step 4: Copy files to installation directory
Write-Host "Step 4: Copying files to installation directory..." -ForegroundColor Yellow

# Check for executables
$mainExe = "$sourceDir\dist\PDF2PNG_Converter.exe"
$starterExe = "$sourceDir\dist\PDF2PNG_Starter.exe"

if (-not (Test-Path $mainExe)) {
    Write-Host "  ERROR: Main executable not found at: $mainExe" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $starterExe)) {
    Write-Host "  ERROR: Starter executable not found at: $starterExe" -ForegroundColor Red
    exit 1
}

# Copy executables
Copy-Item -Path $mainExe -Destination "$installDir\PDF2PNG_Converter.exe" -Force
Write-Host "  Copied main executable" -ForegroundColor Green

Copy-Item -Path $starterExe -Destination "$installDir\PDF2PNG_Starter.exe" -Force
Write-Host "  Copied starter executable" -ForegroundColor Green

# Copy Poppler binaries
if (-not (Test-Path "$installDir\poppler-bin")) {
    New-Item -ItemType Directory -Force -Path "$installDir\poppler-bin" | Out-Null
}
Copy-Item -Path "$sourceDir\poppler-bin\*" -Destination "$installDir\poppler-bin\" -Recurse -Force
Write-Host "  Copied Poppler binaries" -ForegroundColor Green

# Copy support files
$supportFiles = @(
    "icon.ico",
    "Enhanced_Launcher.bat",
    "EULA.txt",
    "release_notes.md",
    "banner.txt",
    "verify_install.bat"
)

foreach ($file in $supportFiles) {
    if (Test-Path "$sourceDir\$file") {
        Copy-Item -Path "$sourceDir\$file" -Destination "$installDir\$file" -Force
        Write-Host "  Copied $file" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Support file not found: $file" -ForegroundColor Yellow
    }
}

# Step 5: Create shortcuts
Write-Host "Step 5: Creating shortcuts..." -ForegroundColor Yellow

# Create desktop shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\PDF2PNG Converter.lnk")
$Shortcut.TargetPath = "$installDir\PDF2PNG_Starter.exe"
$Shortcut.IconLocation = "$installDir\icon.ico"
$Shortcut.Save()
Write-Host "  Created desktop shortcut" -ForegroundColor Green

# Create Start Menu shortcut
$startMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\PDF2PNG Converter"
if (-not (Test-Path $startMenuDir)) {
    New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null
}

$Shortcut = $WshShell.CreateShortcut("$startMenuDir\PDF2PNG Converter.lnk")
$Shortcut.TargetPath = "$installDir\PDF2PNG_Starter.exe"
$Shortcut.IconLocation = "$installDir\icon.ico"
$Shortcut.Save()
Write-Host "  Created Start Menu shortcut" -ForegroundColor Green

$Shortcut = $WshShell.CreateShortcut("$startMenuDir\Uninstall PDF2PNG Converter.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -Command `"Remove-Item -Path '$installDir' -Recurse -Force; Remove-Item -Path '$startMenuDir' -Recurse -Force; Remove-Item -Path '$env:USERPROFILE\Desktop\PDF2PNG Converter.lnk' -Force`""
$Shortcut.Save()
Write-Host "  Created uninstall shortcut" -ForegroundColor Green

# Step 6: Verify installation
Write-Host "Step 6: Verifying installation..." -ForegroundColor Yellow

$mainExeInstalled = Test-Path "$installDir\PDF2PNG_Converter.exe"
$starterExeInstalled = Test-Path "$installDir\PDF2PNG_Starter.exe"
$pdfToPpmInstalled = Test-Path "$installDir\poppler-bin\pdftoppm.exe"

if ($mainExeInstalled -and $starterExeInstalled -and $pdfToPpmInstalled) {
    Write-Host "  All required files are installed correctly!" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Some files may be missing:" -ForegroundColor Yellow
    if (-not $mainExeInstalled) { Write-Host "    - Main executable is missing" -ForegroundColor Red }
    if (-not $starterExeInstalled) { Write-Host "    - Starter executable is missing" -ForegroundColor Red }
    if (-not $pdfToPpmInstalled) { Write-Host "    - Poppler binaries are missing" -ForegroundColor Red }
}

# Step 7: Launch application
Write-Host "`nInstallation complete!" -ForegroundColor Cyan
Write-Host "Would you like to launch PDF2PNG Converter now? (Y/N)" -ForegroundColor Cyan
$launchApp = Read-Host

if ($launchApp -eq "Y" -or $launchApp -eq "y") {
    Write-Host "Launching PDF2PNG Converter..." -ForegroundColor Yellow
    Start-Process -FilePath "$installDir\PDF2PNG_Starter.exe"
}

Write-Host "`nScript completed successfully!" -ForegroundColor Cyan
