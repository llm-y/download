# run.ps1 - Download and run rprompt for Windows
# Usage: iex (irm https://raw.githubusercontent.com/llm-y/download/main/run.ps1)

$ErrorActionPreference = "Stop"

$binUrl = "https://raw.githubusercontent.com/llm-y/download/main/bin/rprompt-windows-amd64.exe"
$tempDir = Join-Path $env:TEMP "rprompt"
$exePath = Join-Path $tempDir "rprompt-windows-amd64.exe"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rprompt - Quick Installer & Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create temp directory if it doesn't exist
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "[+] Created directory: $tempDir" -ForegroundColor Green
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
