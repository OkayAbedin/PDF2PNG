# PDF2PNG Converter - Enhanced Troubleshooter
# This script helps diagnose and fix common issues with the PDF2PNG Converter

# Define colors for output
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorWarning = "Yellow"
$ColorInfo = "Cyan"

function Write-StatusMessage {
    param(
        [string]$Message,
        [string]$Status,
        [string]$Color
    )
    
    Write-Host "[$Status] $Message" -ForegroundColor $Color
}

function Test-FileExists {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-StatusMessage -Message "$Description found at: $Path" -Status "✓" -Color $ColorSuccess
        return $true
    } else {
        Write-StatusMessage -Message "$Description missing: $Path" -Status "✗" -Color $ColorError
        return $false
    }
}

# Print header
Write-Host "PDF2PNG Converter - Enhanced Troubleshooter" -ForegroundColor $ColorInfo
Write-Host "=========================================" -ForegroundColor $ColorInfo
Write-Host

# Detect installation location
$possibleLocations = @(
    "$env:ProgramFiles\PDF2PNG Converter",
    "$env:LOCALAPPDATA\PDF2PNG Converter"
)

$installDir = $null
foreach ($location in $possibleLocations) {
    if (Test-Path "$location\PDF2PNG_Converter.exe") {
        $installDir = $location
        Write-StatusMessage -Message "Installation found at: $installDir" -Status "✓" -Color $ColorSuccess
        break
    }
}

if (-not $installDir) {
    Write-StatusMessage -Message "Installation not found in standard locations" -Status "✗" -Color $ColorError
    
    # Ask for custom location
    $customPath = Read-Host "Enter the installation path (or press Enter to install to AppData)"
    
    if ([string]::IsNullOrWhiteSpace($customPath)) {
        $installDir = "$env:LOCALAPPDATA\PDF2PNG Converter"
        Write-Host "Will install to: $installDir" -ForegroundColor $ColorInfo
    } else {
        if (Test-Path $customPath) {
            $installDir = $customPath
        } else {
            Write-StatusMessage -Message "Path does not exist: $customPath" -Status "✗" -Color $ColorError
            $installDir = "$env:LOCALAPPDATA\PDF2PNG Converter"
            Write-Host "Will install to: $installDir instead" -ForegroundColor $ColorInfo
        }
    }
}

# Check executables
Write-Host "`nChecking executables:" -ForegroundColor $ColorInfo
$mainExe = Join-Path $installDir "PDF2PNG_Converter.exe"
$starterExe = Join-Path $installDir "PDF2PNG_Starter.exe"

$mainExeExists = Test-FileExists -Path $mainExe -Description "Main executable"
$starterExeExists = Test-FileExists -Path $starterExe -Description "Starter executable"

# Check poppler
Write-Host "`nChecking Poppler:" -ForegroundColor $ColorInfo
$popplerDir = Join-Path $installDir "poppler-bin"
$pdfToPpm = Join-Path $popplerDir "pdftoppm.exe"

$popplerExists = Test-FileExists -Path $popplerDir -Description "Poppler directory"
if ($popplerExists) {
    $pdfToPpmExists = Test-FileExists -Path $pdfToPpm -Description "pdftoppm.exe"
} else {
    $pdfToPpmExists = $false
}

# Check registry settings
Write-Host "`nChecking registry settings:" -ForegroundColor $ColorInfo
$regAppPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\PDF2PNG_Converter.exe"
$regUninstall = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\PDF2PNG Converter"

try {
    $regAppPathValue = Get-ItemProperty -Path $regAppPath -ErrorAction SilentlyContinue
    if ($regAppPathValue) {
        Write-StatusMessage -Message "Registry app path: $($regAppPathValue.'(default)')" -Status "✓" -Color $ColorSuccess
    } else {
        Write-StatusMessage -Message "Registry app path not found" -Status "✗" -Color $ColorWarning
    }
} catch {
    Write-StatusMessage -Message "Error checking registry app path" -Status "✗" -Color $ColorError
}

try {
    $regUninstallValue = Get-ItemProperty -Path $regUninstall -ErrorAction SilentlyContinue
    if ($regUninstallValue) {
        Write-StatusMessage -Message "Registry uninstall entry exists" -Status "✓" -Color $ColorSuccess
    } else {
        Write-StatusMessage -Message "Registry uninstall entry not found" -Status "✗" -Color $ColorWarning
    }
} catch {
    Write-StatusMessage -Message "Error checking registry uninstall entry" -Status "✗" -Color $ColorError
}

# Check if any issues were found
$issuesFound = -not ($mainExeExists -and $starterExeExists -and $popplerExists -and $pdfToPpmExists)

# If issues found, offer to fix
if ($issuesFound) {
    Write-Host "`nIssues were found with your installation." -ForegroundColor $ColorError
    $fixIssues = Read-Host "Would you like to attempt to fix these issues? (Y/N)"
    
    if ($fixIssues -eq "Y" -or $fixIssues -eq "y") {
        Write-Host "`nAttempting to fix installation issues..." -ForegroundColor $ColorInfo
        
        # Create directories
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Force -Path $installDir | Out-Null
            Write-StatusMessage -Message "Created installation directory" -Status "✓" -Color $ColorSuccess
        }
        
        # Fix executables
        $sourceDir = "D:\AutomationScripts\PDF2PNG\dist"
        if (Test-Path $sourceDir) {
            if (-not $mainExeExists -and (Test-Path "$sourceDir\PDF2PNG_Converter.exe")) {
                Copy-Item -Path "$sourceDir\PDF2PNG_Converter.exe" -Destination $mainExe -Force
                Write-StatusMessage -Message "Copied main executable" -Status "✓" -Color $ColorSuccess
            }
            
            if (-not $starterExeExists -and (Test-Path "$sourceDir\PDF2PNG_Starter.exe")) {
                Copy-Item -Path "$sourceDir\PDF2PNG_Starter.exe" -Destination $starterExe -Force
                Write-StatusMessage -Message "Copied starter executable" -Status "✓" -Color $ColorSuccess
            }
        } else {
            Write-StatusMessage -Message "Source directory not found: $sourceDir" -Status "✗" -Color $ColorError
        }
        
        # Fix Poppler
        $sourcePopplerDir = "D:\AutomationScripts\PDF2PNG\poppler-bin"
        if (-not $popplerExists -and (Test-Path $sourcePopplerDir)) {
            if (-not (Test-Path $popplerDir)) {
                New-Item -ItemType Directory -Force -Path $popplerDir | Out-Null
            }
            
            Copy-Item -Path "$sourcePopplerDir\*" -Destination $popplerDir -Recurse -Force
            Write-StatusMessage -Message "Copied Poppler binaries" -Status "✓" -Color $ColorSuccess
        }
        
        # Create batch file for launching
        $batchPath = Join-Path $installDir "Run_PDF2PNG.bat"
        $batchContent = @"
@echo off
set PATH=%PATH%;%~dp0;%~dp0poppler-bin
start "" "%~dp0PDF2PNG_Starter.exe"
"@
        Set-Content -Path $batchPath -Value $batchContent -Force
        Write-StatusMessage -Message "Created launcher batch file" -Status "✓" -Color $ColorSuccess
        
        # Fix registry entries
        if (-not $regAppPathValue) {
            try {
                New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths" -Name "PDF2PNG_Converter.exe" -Force | Out-Null
                New-ItemProperty -Path $regAppPath -Name "(Default)" -Value $mainExe -PropertyType String -Force | Out-Null
                Write-StatusMessage -Message "Created registry app path" -Status "✓" -Color $ColorSuccess
            } catch {
                Write-StatusMessage -Message "Failed to create registry app path: $_" -Status "✗" -Color $ColorError
            }
        }
        
        # Create desktop shortcut
        $desktopPath = [System.Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "PDF2PNG Converter.lnk"
        
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $batchPath
        $Shortcut.IconLocation = Join-Path $installDir "icon.ico"
        $Shortcut.Save()
        Write-StatusMessage -Message "Created desktop shortcut" -Status "✓" -Color $ColorSuccess
    }
}

# Offer to test the application
Write-Host "`nWould you like to test the application? (Y/N)" -ForegroundColor $ColorInfo
$testApp = Read-Host

if ($testApp -eq "Y" -or $testApp -eq "y") {
    Write-Host "`nLaunching PDF2PNG Converter..." -ForegroundColor $ColorInfo
    
    # Try various methods of launching
    $success = $false
    
    # Method 1: Try starter executable directly
    if (Test-Path $starterExe) {
        try {
            Start-Process -FilePath $starterExe -NoNewWindow
            Write-StatusMessage -Message "Application launched with starter executable" -Status "✓" -Color $ColorSuccess
            $success = $true
        } catch {
            Write-StatusMessage -Message "Failed to launch with starter executable: $_" -Status "✗" -Color $ColorError
        }
    }
    
    # Method 2: Try batch file if Method 1 failed
    if (-not $success) {
        $batchPath = Join-Path $installDir "Run_PDF2PNG.bat"
        if (Test-Path $batchPath) {
            try {
                Start-Process -FilePath $batchPath -NoNewWindow
                Write-StatusMessage -Message "Application launched with batch file" -Status "✓" -Color $ColorSuccess
                $success = $true
            } catch {
                Write-StatusMessage -Message "Failed to launch with batch file: $_" -Status "✗" -Color $ColorError
            }
        }
    }
    
    # Method 3: Try main executable directly if all else failed
    if (-not $success -and (Test-Path $mainExe)) {
        try {
            $env:PATH = "$env:PATH;$installDir;$popplerDir"
            Start-Process -FilePath $mainExe -NoNewWindow
            Write-StatusMessage -Message "Application launched with main executable" -Status "✓" -Color $ColorSuccess
            $success = $true
        } catch {
            Write-StatusMessage -Message "Failed to launch with main executable: $_" -Status "✗" -Color $ColorError
        }
    }
    
    if (-not $success) {
        Write-StatusMessage -Message "All launch methods failed" -Status "✗" -Color $ColorError
    }
}

Write-Host "`nTroubleshooting complete!" -ForegroundColor $ColorInfo
