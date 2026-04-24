# Dua Hifz - Setup Script for Windows
# This script helps you copy your model files to the correct location

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Dua Hifz - Model Files Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Define source and destination paths
$sourceBase = "C:\USERS\SALEXT\PRV\APPSR\DIKR\PRJ\DUAHIFZ_MVP\DUAHIFZ\ASSETS"
$destBase = ".\assets"

Write-Host "Source: $sourceBase" -ForegroundColor Cyan
Write-Host "Destination: $destBase" -ForegroundColor Cyan
Write-Host ""

# Check if source directory exists
if (-Not (Test-Path $sourceBase)) {
    Write-Host "ERROR: Source directory not found!" -ForegroundColor Red
    Write-Host "Please update the source path in this script if your files are in a different location." -ForegroundColor Yellow
    exit 1
}

# Create destination directories if they don't exist
Write-Host "Creating destination directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$destBase\fonts" | Out-Null
New-Item -ItemType Directory -Force -Path "$destBase\models" | Out-Null
Write-Host "✓ Directories created" -ForegroundColor Green
Write-Host ""

# Copy font files
Write-Host "Copying font files..." -ForegroundColor Yellow
$fontFiles = @("Amiri-Regular.ttf", "NotoSansArabic-Regular.ttf")
foreach ($file in $fontFiles) {
    $sourcePath = Join-Path "$sourceBase\fonts" $file
    $destPath = Join-Path "$destBase\fonts" $file
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ Copied: $file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Not found: $file" -ForegroundColor Yellow
    }
}
Write-Host ""

# Copy model files
Write-Host "Copying model files..." -ForegroundColor Yellow
$modelFiles = @(
    "silero_vad.onnx",
    "tiny-ar-quran-decoder.int8.onnx",
    "tiny-ar-quran-encoder.int8.onnx",
    "tokens.txt"
)
foreach ($file in $modelFiles) {
    $sourcePath = Join-Path "$sourceBase\models" $file
    $destPath = Join-Path "$destBase\models" $file
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ Copied: $file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Not found: $file" -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter pub get' to install dependencies" -ForegroundColor White
Write-Host "2. Run 'flutter run' to start the app" -ForegroundColor White
Write-Host ""
Write-Host "Note: Make sure you have Flutter installed and configured on your system." -ForegroundColor Yellow
