# Simple cleanup script for PDF2PNG project

# Set paths
$rootDir = "D:\AutomationScripts\PDF2PNG"
$backupDir = Join-Path $rootDir "backup_old_files"

# Create backup directory
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    Write-Host "Created backup directory: $backupDir"
}

# Essential files and directories to keep
$essentialItems = @(
    "README.md",
    "cleanup.ps1",
    "verify_structure.ps1",
    "src",
    "resources",
    "bin",
    "docs",
    "build",
    "backup_old_files"
)

# Get items to move
$itemsToMove = Get-ChildItem -Path $rootDir | Where-Object { 
    $essentialItems -notcontains $_.Name 
}

# Move items
foreach ($item in $itemsToMove) {
    Write-Host "Moving: $($item.Name)"
    Move-Item -Path $item.FullName -Destination $backupDir -Force
}

Write-Host "Cleanup complete. Moved items to: $backupDir"
