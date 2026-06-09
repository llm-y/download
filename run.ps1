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

# Check and set environment variables
Write-Host ""
$token = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User")
if (-not $token) {
    Write-Host "[!] TELEGRAM_BOT_TOKEN is not set in the environment." -ForegroundColor Red
    $token = Read-Host "    Enter your Telegram Bot Token"
    if ($token) {
        [Environment]::SetEnvironmentVariable("TELEGRAM_BOT_TOKEN", $token, "User")
        $env:TELEGRAM_BOT_TOKEN = $token
        Write-Host "[+] TELEGRAM_BOT_TOKEN saved permanently." -ForegroundColor Green
    } else {
        Write-Host "[!] No value entered. Skipping TELEGRAM_BOT_TOKEN setup." -ForegroundColor Yellow
    }
} else {
    $env:TELEGRAM_BOT_TOKEN = $token
    Write-Host "[+] TELEGRAM_BOT_TOKEN is already set." -ForegroundColor Green
}

$chatIds = [Environment]::GetEnvironmentVariable("ALLOWED_CHAT_IDS", "User")
if (-not $chatIds) {
    Write-Host "[!] ALLOWED_CHAT_IDS is not set in the environment." -ForegroundColor Red
    $chatIds = Read-Host "    Enter your Allowed Chat IDs"
    if ($chatIds) {
        [Environment]::SetEnvironmentVariable("ALLOWED_CHAT_IDS", $chatIds, "User")
        $env:ALLOWED_CHAT_IDS = $chatIds
        Write-Host "[+] ALLOWED_CHAT_IDS saved permanently." -ForegroundColor Green
    } else {
        Write-Host "[!] No value entered. Skipping ALLOWED_CHAT_IDS setup." -ForegroundColor Yellow
    }
} else {
    $env:ALLOWED_CHAT_IDS = $chatIds
    Write-Host "[+] ALLOWED_CHAT_IDS is already set." -ForegroundColor Green
}

# Run the binary
Write-Host ""
Write-Host "[*] Starting rprompt..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

& $exePath
