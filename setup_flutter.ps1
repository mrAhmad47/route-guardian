$source = "$env:USERPROFILE\Desktop\flutter"
$dest = "$env:USERPROFILE\flutter"
$flutterBin = "$dest\bin"

if (Test-Path $dest) {
    Write-Host "Destination $dest already exists. Please verify." -ForegroundColor Yellow
} else {
    Write-Host "Moving Flutter from Desktop to $dest..."
    Move-Item -Path $source -Destination $dest
}

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$flutterBin*") {
    Write-Host "Adding $flutterBin to PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBin", "User")
    Write-Host "Done."
} else {
    Write-Host "Already in PATH."
}
