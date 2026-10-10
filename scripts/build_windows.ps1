# Build Windows (PowerShell) — À EXÉCUTER SUR WINDOWS AVEC VISUAL STUDIO 2022
# (ou via Codemagic : workflow `windows-desktop`, voir codemagic.yaml).
# Ce script n'a PAS été exécuté dans l'environnement de développement (Linux) :
# aucun exécutable n'est livré ni prétendu.
#
# Prérequis :
#  - Flutter SDK >= 3.24 dans le PATH
#  - Visual Studio 2022 avec charge "Développement Desktop en C++"

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\apps\desktop"

if (-not (Test-Path "windows")) {
    flutter create --platforms=windows --project-name msn_desktop .
}

flutter pub get

Push-Location ..\..\packages\core
dart run build_runner build --delete-conflicting-outputs
Pop-Location

flutter build windows --release

New-Item -ItemType Directory -Force -Path dist | Out-Null
Compress-Archive -Path build\windows\x64\runner\Release\* `
    -DestinationPath dist\MSN_Manager_Windows.zip -Force

Write-Host "Exécutable : apps\desktop\build\windows\x64\runner\Release\msn_desktop.exe"
Write-Host "Archive livrable : apps\desktop\dist\MSN_Manager_Windows.zip (exe + DLL)."
