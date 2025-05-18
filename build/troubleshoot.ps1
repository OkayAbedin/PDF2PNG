# Troubleshooter script for PDF2PNG Converter DLL issues
# This script helps identify and fix common DLL loading issues

Write-Host "PDF2PNG Converter Troubleshooter" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host

# Check Python installation
try {
    $pythonVersion = python --version
    Write-Host "✓ Found $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "  Please install Python 3.8+ from https://www.python.org/downloads/" -ForegroundColor Yellow
    exit
}

# Check if we're running from the installer directory
$installDir = Get-Location
$exePath = Join-Path $installDir "PDF2PNG_Converter.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "✗ Could not find PDF2PNG_Converter.exe in current directory" -ForegroundColor Red
    $exePath = Read-Host "Please enter the full path to PDF2PNG_Converter.exe"
    
    if (-not (Test-Path $exePath)) {
        Write-Host "✗ Invalid path provided" -ForegroundColor Red
        exit
    }
    
    $installDir = Split-Path -Path $exePath -Parent
}

Write-Host "✓ Found executable at: $exePath" -ForegroundColor Green

# Check for Python DLLs in the installation directory
$pythonDlls = Get-ChildItem -Path $installDir -Filter "python*.dll" -ErrorAction SilentlyContinue
if ($pythonDlls.Count -eq 0) {
    Write-Host "✗ No Python DLLs found in the installation directory" -ForegroundColor Red
    
    # Try to locate Python DLLs from current Python installation
    $pythonPath = (Get-Command python).Source
    $pythonDir = Split-Path -Path $pythonPath -Parent
    $sourcePythonDlls = Get-ChildItem -Path $pythonDir -Filter "python*.dll" -ErrorAction SilentlyContinue
    
    if ($sourcePythonDlls.Count -gt 0) {
        Write-Host "  Found Python DLLs in Python installation: $pythonDir" -ForegroundColor Yellow
        Write-Host "  Would you like to copy these DLLs to the application directory? (Y/N)" -ForegroundColor Yellow
        $copyDlls = Read-Host
        
        if ($copyDlls -eq "Y" -or $copyDlls -eq "y") {
            foreach ($dll in $sourcePythonDlls) {
                Copy-Item -Path $dll.FullName -Destination $installDir -Force
                Write-Host "  Copied $($dll.Name) to $installDir" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "✗ Could not locate Python DLLs in Python installation" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Found Python DLLs in the installation directory:" -ForegroundColor Green
    foreach ($dll in $pythonDlls) {
        Write-Host "  - $($dll.Name)" -ForegroundColor Green
    }
}

# Check for Poppler
$popplerPath = Join-Path $installDir "poppler-bin"
if (-not (Test-Path $popplerPath)) {
    Write-Host "✗ Poppler directory not found" -ForegroundColor Red
    
    # Create poppler directory
    New-Item -ItemType Directory -Force -Path $popplerPath | Out-Null
    
    # Try to download poppler
    Write-Host "  Downloading Poppler for Windows..." -ForegroundColor Yellow
    
    $tempDir = New-Item -ItemType Directory -Force -Path (Join-Path $installDir "temp")
    $popplerZip = Join-Path $tempDir.FullName "poppler-windows.zip"
    
    try {
        Invoke-WebRequest -Uri "https://github.com/oschwartz10612/poppler-windows/releases/download/v23.08.0-0/Release-23.08.0-0.zip" -OutFile $popplerZip
        
        # Extract poppler
        Write-Host "  Extracting Poppler..." -ForegroundColor Yellow
        Expand-Archive -Path $popplerZip -DestinationPath $tempDir -Force
        
        # Move to proper location
        $sourcePopplerBin = Join-Path $tempDir "poppler-23.08.0\Library\bin"
        if (Test-Path $sourcePopplerBin) {
            Copy-Item -Path "$sourcePopplerBin\*" -Destination $popplerPath -Recurse -Force
            Write-Host "✓ Poppler binaries installed successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Could not find Poppler binaries in the downloaded package" -ForegroundColor Red
        }
        
        # Clean up
        Remove-Item -Path $tempDir -Recurse -Force
    } catch {
        Write-Host "✗ Failed to download or extract Poppler: $_" -ForegroundColor Red
    }
} else {
    $popplerDlls = Get-ChildItem -Path $popplerPath -Filter "*.dll" -ErrorAction SilentlyContinue
    if ($popplerDlls.Count -eq 0) {
        Write-Host "✗ Poppler directory exists but contains no DLLs" -ForegroundColor Red
    } else {
        Write-Host "✓ Found Poppler binaries" -ForegroundColor Green
    }
}

# Create batch file to run the application with correct paths
$batchPath = Join-Path $installDir "Run_PDF2PNG_Converter.bat"
$batchContent = @"
@echo off
set PATH=%PATH%;%~dp0;%~dp0poppler-bin
"%~dp0PDF2PNG_Converter.exe"
"@

Set-Content -Path $batchPath -Value $batchContent
Write-Host "✓ Created launcher batch file: $batchPath" -ForegroundColor Green
Write-Host "  Try running this batch file instead of the .exe directly" -ForegroundColor Yellow

Write-Host
Write-Host "Troubleshooting complete!" -ForegroundColor Cyan
Write-Host "Please try running the application with the batch file" -ForegroundColor Cyan
Write-Host "If problems persist, please check the logs or contact support" -ForegroundColor Cyan
Write-Host

# Ask if the user wants to run the batch file
$runBatch = Read-Host "Would you like to run the application now? (Y/N)"
if ($runBatch -eq "Y" -or $runBatch -eq "y") {
    Write-Host "Running PDF2PNG Converter..." -ForegroundColor Cyan
    & $batchPath
}
