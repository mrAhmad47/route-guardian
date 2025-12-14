# Flutter Auto-Installer Script
# This script downloads Flutter, extracts it to C:\flutter, and adds it to your User PATH.

$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
$zipPath = "$env:TEMP\flutter_windows.zip"
$installDir = "$env:USERPROFILE"
$flutterBin = "$env:USERPROFILE\flutter\bin"

Write-Host "Downloading Flutter SDK... (This may take a few minutes)" -ForegroundColor Cyan
Invoke-WebRequest -Uri $flutterUrl -OutFile $zipPath

Write-Host "Download complete. Extracting to $installDir..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force

Write-Host "Extraction complete. Adding to PATH..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBin", "User")
    Write-Host "Flutter added to User PATH." -ForegroundColor Green
}
else {
    Write-Host "Flutter is already in PATH." -ForegroundColor Yellow
}

Write-Host "Installation Finished! Please close this terminal and open a new one to use 'flutter'." -ForegroundColor Green
Write-Host "You can then run: flutter doctor" -ForegroundColor Green
