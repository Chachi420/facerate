# Mirror - Release Build Script
# Usage: .\release.ps1
# Bumps version code, builds signed AAB, opens the output folder.

$pubspec = "app\pubspec.yaml"
$content = Get-Content $pubspec -Raw

# Extract current version string e.g. "1.0.0+2"
if ($content -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    $semver = $Matches[1]
    $code = [int]$Matches[2] + 1
    $newVersion = "version: $semver+$code"
    $content = $content -replace "version:\s*\d+\.\d+\.\d+\+\d+", $newVersion
    Set-Content $pubspec $content -NoNewline
    Write-Host "Version bumped to $semver+$code" -ForegroundColor Green
} else {
    Write-Host "ERROR: Could not parse version from pubspec.yaml" -ForegroundColor Red
    exit 1
}

# Build
# Real AdMob ids are baked into the release build automatically
# (app_constants.dart + android/app/build.gradle switch on kReleaseMode /
# the release build type), so no extra flags are needed here.
Set-Location app
Write-Host "Building release AAB..." -ForegroundColor Cyan
flutter build appbundle --release --no-tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

$aab = "build\app\outputs\bundle\release\app-release.aab"
Write-Host ""
Write-Host "SUCCESS: $aab" -ForegroundColor Green
Write-Host "Upload this to Play Console -> Create new release" -ForegroundColor Yellow
Invoke-Item "build\app\outputs\bundle\release\"
