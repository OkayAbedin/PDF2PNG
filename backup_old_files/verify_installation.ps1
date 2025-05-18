# Install Verification Script for PDF2PNG Converter
# This script verifies that all components are correctly installed

# Define colors for output
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorInfo = "Cyan"

$installDir = "$env:LOCALAPPDATA\PDF2PNG Converter"
Write-Host "PDF2PNG Converter Installation Verification" -ForegroundColor $ColorInfo
Write-Host "=========================================" -ForegroundColor $ColorInfo
Write-Host "Installation Directory: $installDir" -ForegroundColor $ColorInfo
Write-Host

# Check for main components
$mainExe = Join-Path $installDir "PDF2PNG_Converter.exe"
$starterExe = Join-Path $installDir "PDF2PNG_Starter.exe"
$launcherBat = Join-Path $installDir "Enhanced_Launcher.bat"
$popplerDir = Join-Path $installDir "poppler-bin"
$pdfToPpm = Join-Path $popplerDir "pdftoppm.exe"

# Display file sizes for verification
if (Test-Path $mainExe) {
    $mainSize = (Get-Item $mainExe).Length
    Write-Host "Main EXE exists, size: $([math]::Round($mainSize/1MB, 2)) MB" -ForegroundColor $ColorSuccess
} else {
    Write-Host "Main EXE is MISSING" -ForegroundColor $ColorError
}

if (Test-Path $starterExe) {
    $starterSize = (Get-Item $starterExe).Length
    Write-Host "Starter EXE exists, size: $([math]::Round($starterSize/1MB, 2)) MB" -ForegroundColor $ColorSuccess
} else {
    Write-Host "Starter EXE is MISSING" -ForegroundColor $ColorError
}

if (Test-Path $launcherBat) {
    Write-Host "Launcher batch file exists" -ForegroundColor $ColorSuccess
} else {
    Write-Host "Launcher batch file is MISSING" -ForegroundColor $ColorError
}

if (Test-Path $popplerDir) {
    Write-Host "Poppler directory exists" -ForegroundColor $ColorSuccess
    if (Test-Path $pdfToPpm) {
        Write-Host "   pdftoppm.exe exists" -ForegroundColor $ColorSuccess
    } else {
        Write-Host "   pdftoppm.exe is MISSING" -ForegroundColor $ColorError
    }
} else {
    Write-Host "Poppler directory is MISSING" -ForegroundColor $ColorError
}

# Try launching the app
Write-Host "`nWould you like to test launching the application? (Y/N)" -ForegroundColor $ColorInfo
$testApp = Read-Host

if ($testApp -eq "Y" -or $testApp -eq "y") {
    Write-Host "Launching from Enhanced_Launcher.bat..." -ForegroundColor $ColorInfo
    Start-Process -FilePath $launcherBat -Wait
    
    # Check if process was started
    $pdfProcess = Get-Process -Name "PDF2PNG_Converter" -ErrorAction SilentlyContinue
    if ($pdfProcess) {
        Write-Host "Application successfully launched!" -ForegroundColor $ColorSuccess
    } else {
        Write-Host "Could not detect if application was launched." -ForegroundColor $ColorError
        
        # Try direct launch
        Write-Host "Trying to launch starter executable directly..." -ForegroundColor $ColorInfo
        Start-Process -FilePath $starterExe
    }
}

Write-Host "`nVerification complete!" -ForegroundColor $ColorInfo
