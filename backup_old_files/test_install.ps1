# Test script for PDF2PNG Converter installation issues
Write-Host "PDF2PNG Converter Test Script" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# Check executable files
$mainExe = "D:\AutomationScripts\PDF2PNG\dist\PDF2PNG_Converter.exe"
$starterExe = "D:\AutomationScripts\PDF2PNG\dist\PDF2PNG_Starter.exe"

if (Test-Path $mainExe) {
    Write-Host "Main executable exists at: $mainExe" -ForegroundColor Green
} else {
    Write-Host "Main executable MISSING at: $mainExe" -ForegroundColor Red
}

if (Test-Path $starterExe) {
    Write-Host "Starter executable exists at: $starterExe" -ForegroundColor Green
} else {
    Write-Host "Starter executable MISSING at: $starterExe" -ForegroundColor Red
}

# Check Poppler
$popplerDir = "D:\AutomationScripts\PDF2PNG\poppler-bin"
if (Test-Path $popplerDir) {
    $pdfToPpm = Join-Path $popplerDir "pdftoppm.exe"
    if (Test-Path $pdfToPpm) {
        Write-Host "Poppler binaries found and include pdftoppm.exe" -ForegroundColor Green
    } else {
        Write-Host "Poppler directory exists but missing pdftoppm.exe" -ForegroundColor Red
    }
} else {
    Write-Host "Poppler directory MISSING" -ForegroundColor Red
}

# Test file associations
Write-Host "`nChecking file associations..." -ForegroundColor Cyan
$pdfConvertPath = (Get-ItemProperty -Path "HKCU:\Software\Classes\.pdf\shell\ConvertToPNG\command" -ErrorAction SilentlyContinue).'(default)'
if ($pdfConvertPath) {
    Write-Host "PDF file association exists: $pdfConvertPath" -ForegroundColor Green
} else {
    Write-Host "PDF file association NOT found" -ForegroundColor Yellow
}

# Test install registry entries
Write-Host "`nChecking registry entries..." -ForegroundColor Cyan
$appPath = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\PDF2PNG_Converter.exe" -ErrorAction SilentlyContinue).'(default)'
if ($appPath) {
    Write-Host "Application path registered: $appPath" -ForegroundColor Green
} else {
    Write-Host "Application path NOT registered in registry" -ForegroundColor Yellow
}

# Test installation with installer
Write-Host "`nWould you like to test installation with the installer? (Y/N)" -ForegroundColor Cyan
$testInstall = Read-Host

if ($testInstall -eq "Y" -or $testInstall -eq "y") {
    $installPath = Join-Path $env:LOCALAPPDATA "PDF2PNG"
    
    Write-Host "Installing to $installPath..." -ForegroundColor Cyan
    Start-Process -FilePath "D:\AutomationScripts\PDF2PNG\PDF2PNG_Converter_Setup.exe" -Wait
    
    # Check if installation created files
    if (Test-Path (Join-Path $installPath "PDF2PNG_Converter.exe")) {
        Write-Host "Installation successful!" -ForegroundColor Green
        
        # Try running the application
        Write-Host "Would you like to test running the application? (Y/N)" -ForegroundColor Cyan
        $testRun = Read-Host
        
        if ($testRun -eq "Y" -or $testRun -eq "y") {
            Write-Host "Running starter executable..." -ForegroundColor Cyan
            Start-Process -FilePath (Join-Path $installPath "PDF2PNG_Starter.exe")
        }
    } else {
        Write-Host "Installation failed - executable not found in $installPath" -ForegroundColor Red
    }
}

Write-Host "`nTest complete!" -ForegroundColor Cyan
