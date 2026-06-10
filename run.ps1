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

# --- TELEGRAM_BOT_TOKEN ---
$tokenValue = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User")
if (-not $tokenValue) {
    Write-Host "[!] TELEGRAM_BOT_TOKEN is not set in OS environment." -ForegroundColor Red
    $tokenValue = Read-Host "    Enter your TELEGRAM_BOT_TOKEN"
    if ($tokenValue) {
        [Environment]::SetEnvironmentVariable("TELEGRAM_BOT_TOKEN", $tokenValue, "User")
        $env:TELEGRAM_BOT_TOKEN = $tokenValue
        Write-Host "[+] TELEGRAM_BOT_TOKEN saved to OS environment (User scope)." -ForegroundColor Green
    } else {
        Write-Host "[!] No value entered. TELEGRAM_BOT_TOKEN remains unset." -ForegroundColor Yellow
    }
} else {
    $env:TELEGRAM_BOT_TOKEN = $tokenValue
    Write-Host "[+] TELEGRAM_BOT_TOKEN loaded from OS environment." -ForegroundColor Green
}

# --- ALLOWED_CHAT_IDS ---
$chatValue = [Environment]::GetEnvironmentVariable("ALLOWED_CHAT_IDS", "User")
if (-not $chatValue) {
    Write-Host "[!] ALLOWED_CHAT_IDS is not set in OS environment." -ForegroundColor Red
    $chatValue = Read-Host "    Enter your ALLOWED_CHAT_IDS"
    if ($chatValue) {
        [Environment]::SetEnvironmentVariable("ALLOWED_CHAT_IDS", $chatValue, "User")
        $env:ALLOWED_CHAT_IDS = $chatValue
        Write-Host "[+] ALLOWED_CHAT_IDS saved to OS environment (User scope)." -ForegroundColor Green
    } else {
        Write-Host "[!] No value entered. ALLOWED_CHAT_IDS remains unset." -ForegroundColor Yellow
    }
} else {
    $env:ALLOWED_CHAT_IDS = $chatValue
    Write-Host "[+] ALLOWED_CHAT_IDS loaded from OS environment." -ForegroundColor Green
}

# --- GEMINI_CLI_TRUST_WORKSPACE ---
$geminiValue = [Environment]::GetEnvironmentVariable("GEMINI_CLI_TRUST_WORKSPACE", "User")
if (-not $geminiValue) {
    [Environment]::SetEnvironmentVariable("GEMINI_CLI_TRUST_WORKSPACE", "true", "User")
    $env:GEMINI_CLI_TRUST_WORKSPACE = "true"
    Write-Host "[+] GEMINI_CLI_TRUST_WORKSPACE set to 'true' in OS environment (User scope)." -ForegroundColor Green
} else {
    $env:GEMINI_CLI_TRUST_WORKSPACE = $geminiValue
    Write-Host "[+] GEMINI_CLI_TRUST_WORKSPACE loaded from OS environment." -ForegroundColor Green
}

# Run the binary
Write-Host ""
Write-Host "[*] Starting rprompt..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

& $exePath
