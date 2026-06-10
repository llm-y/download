# run.ps1 - Download and install rprompt for Windows
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
$installDir = Join-Path $env:LOCALAPPDATA "rprompt"
$exePath = Join-Path $installDir "rprompt.exe"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rprompt - Quick Installer & Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[+] Running as Administrator" -ForegroundColor Green

# Create install directory if it doesn't exist
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "[+] Created directory: $installDir" -ForegroundColor Green
}

# Add Windows Defender exclusion for the entire install folder
Write-Host "[*] Adding Windows Defender exclusion for: $installDir" -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath $installDir
    Write-Host "[+] Defender exclusion added successfully" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not add Defender exclusion: $_" -ForegroundColor Red
    Write-Host "    The file may still be flagged by antivirus." -ForegroundColor Yellow
}

# Temporarily disable real-time protection during download
Write-Host "[*] Disabling real-time protection for download..." -ForegroundColor Yellow
try {
    Set-MpPreference -DisableRealtimeMonitoring $true
    Write-Host "[+] Real-time protection disabled" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not disable real-time protection: $_" -ForegroundColor Red
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

# Download the binary
Write-Host "[*] Downloading rprompt..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $binUrl -OutFile $exePath -UseBasicParsing
    Write-Host "[+] Download complete: $exePath" -ForegroundColor Green
} catch {
    Write-Host "[!] Failed to download: $_" -ForegroundColor Red
    # Re-enable real-time protection before exiting
    try { Set-MpPreference -DisableRealtimeMonitoring $false } catch {}
    exit 1
}

# Re-enable real-time protection after download
Write-Host "[*] Re-enabling real-time protection..." -ForegroundColor Yellow
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Write-Host "[+] Real-time protection re-enabled" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not re-enable real-time protection: $_" -ForegroundColor Red
    Write-Host "    Please re-enable it manually in Windows Security settings." -ForegroundColor Yellow
}

# Add install directory to system PATH if not already present
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$installDir*") {
    Write-Host "[*] Adding $installDir to system PATH..." -ForegroundColor Yellow
    try {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "Machine")
        $env:Path = "$env:Path;$installDir"
        Write-Host "[+] Added to system PATH successfully" -ForegroundColor Green
    } catch {
        Write-Host "[!] Warning: Could not add to system PATH: $_" -ForegroundColor Red
    }
} else {
    Write-Host "[+] Install directory already in system PATH" -ForegroundColor Green
}

# Check environment variables
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

# --- API_TOKEN ---
$apiTokenValue = [Environment]::GetEnvironmentVariable("API_TOKEN", "User")
if (-not $apiTokenValue) {
    $apiTokenValue = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    [Environment]::SetEnvironmentVariable("API_TOKEN", $apiTokenValue, "User")
    $env:API_TOKEN = $apiTokenValue
    Write-Host "[+] API_TOKEN generated and saved to OS environment (User scope)." -ForegroundColor Green
    Write-Host "    Your API_TOKEN: $apiTokenValue" -ForegroundColor Cyan
} else {
    $env:API_TOKEN = $apiTokenValue
    Write-Host "[+] API_TOKEN loaded from OS environment." -ForegroundColor Green
}

# Run the binary
Write-Host ""
Write-Host "[*] Starting rprompt..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

& $exePath
