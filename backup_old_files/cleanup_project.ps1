param (
    [switch]$Force
)

# Set console encoding to UTF-8 for better output
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== PDF2PNG Converter - Project Cleanup ===" -ForegroundColor Cyan
Write-Host "This script will move redundant files to a backup directory" -ForegroundColor Yellow

# Set paths
$rootDir = "D:\AutomationScripts\PDF2PNG"
$backupDir = Join-Path $rootDir "backup_old_files"

# Create backup directory
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    Write-Host "Created backup directory: $backupDir" -ForegroundColor Green
}

# List of files that should remain in the root directory
$essentialFiles = @(
    "README.md",
    "LICENSE",
    "cleanup.ps1",
    "verify_structure.ps1",
    ".git",
    ".gitignore"
)

# List of directories that should remain in the root directory
$essentialDirs = @(
    "src",
    "resources",
    "bin",
    "docs",
    "build"
)

# Show what will be moved
Write-Host "`nThe following files and directories will be moved to backup:" -ForegroundColor Yellow

$itemsToMove = Get-ChildItem -Path $rootDir -Force | Where-Object {
    $_.Name -ne "backup_old_files" -and 
    $essentialFiles -notcontains $_.Name -and 
    $essentialDirs -notcontains $_.Name
}

foreach ($item in $itemsToMove) {
    Write-Host " - $($item.Name)" -ForegroundColor DarkYellow
}

# Ask for confirmation unless -Force is used
if (-not $Force) {
    Write-Host "`nDo you want to proceed with moving these files? (Y/N): " -ForegroundColor Cyan -NoNewline
    $confirmation = Read-Host
    if ($confirmation -ne "Y" -and $confirmation -ne "y") {
        Write-Host "Operation cancelled." -ForegroundColor Red
        exit
    }
}

# Move files to backup directory
Write-Host "`nMoving files to backup directory..." -ForegroundColor Cyan
$successCount = 0
$failureCount = 0

foreach ($item in $itemsToMove) {
    try {
        Write-Host "Moving: $($item.Name)" -ForegroundColor Yellow
        Move-Item -Path $item.FullName -Destination $backupDir -Force -ErrorAction Stop
        Write-Host "  ✓ Success" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "  ✗ Failed: $_" -ForegroundColor Red
        $failureCount++
    }
}

# Summary
Write-Host "`nCleanup Summary:" -ForegroundColor Cyan
Write-Host "Successfully moved: $successCount items" -ForegroundColor Green
if ($failureCount -gt 0) {
    Write-Host "Failed to move: $failureCount items" -ForegroundColor Red
}

Write-Host "`nBackup location: $backupDir" -ForegroundColor Yellow
Write-Host "You can delete the backup directory once you've verified everything works." -ForegroundColor Yellow
