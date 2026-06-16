#!/bin/bash
# run.sh - Download and install rprompt for Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/llm-y/download/main/run.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Rprompt - Quick Installer & Runner${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  BINARY="rprompt-linux-amd64" ;;
    aarch64) BINARY="rprompt-linux-arm64" ;;
    arm64)   BINARY="rprompt-linux-arm64" ;;
    *)
        echo -e "${RED}[!] Arsitektur tidak didukung: $ARCH${NC}"
        exit 1
        ;;
esac

BIN_URL="https://raw.githubusercontent.com/llm-y/download/main/bin/${BINARY}"
INSTALL_DIR="$HOME/.local/bin"
EXE_PATH="${INSTALL_DIR}/rprompt"

echo -e "${GREEN}[+] Arsitektur terdeteksi: $ARCH -> $BINARY${NC}"

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    echo -e "${GREEN}[+] Direktori dibuat: $INSTALL_DIR${NC}"
fi

# Download the binary
echo -e "${YELLOW}[*] Mengunduh rprompt...${NC}"
if command -v curl &> /dev/null; then
    curl -fsSL "$BIN_URL" -o "$EXE_PATH"
elif command -v wget &> /dev/null; then
    wget -q "$BIN_URL" -O "$EXE_PATH"
else
    echo -e "${RED}[!] curl atau wget tidak ditemukan. Silakan instal salah satunya.${NC}"
    exit 1
fi
chmod +x "$EXE_PATH"
echo -e "${GREEN}[+] Download selesai: $EXE_PATH${NC}"

# Add to PATH if not already present
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}[*] Menambahkan $INSTALL_DIR ke PATH...${NC}"

    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        zsh)  PROFILE="$HOME/.zshrc" ;;
        bash) PROFILE="$HOME/.bashrc" ;;
        *)    PROFILE="$HOME/.profile" ;;
    esac

    if ! grep -q "$INSTALL_DIR" "$PROFILE" 2>/dev/null; then
        echo "" >> "$PROFILE"
        echo "# Added by rprompt installer" >> "$PROFILE"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$PROFILE"
        echo -e "${GREEN}[+] PATH ditambahkan ke $PROFILE${NC}"
    fi

    export PATH="$PATH:$INSTALL_DIR"
fi

# --- Environment Variables ---
echo ""

# TELEGRAM_BOT_TOKEN
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo -e "${RED}[!] TELEGRAM_BOT_TOKEN belum diset.${NC}"
    read -rp "    Masukkan TELEGRAM_BOT_TOKEN Anda: " TOKEN_INPUT
    if [ -n "$TOKEN_INPUT" ]; then
        export TELEGRAM_BOT_TOKEN="$TOKEN_INPUT"
        echo -e "${GREEN}[+] TELEGRAM_BOT_TOKEN diset untuk sesi ini.${NC}"
        echo -e "${YELLOW}    Tip: Tambahkan ke ~/.bashrc atau ~/.zshrc agar permanen:${NC}"
        echo -e "${GRAY}    export TELEGRAM_BOT_TOKEN=\"$TOKEN_INPUT\"${NC}"
    else
        echo -e "${YELLOW}[!] Tidak ada nilai. TELEGRAM_BOT_TOKEN tetap kosong.${NC}"
    fi
else
    echo -e "${GREEN}[+] TELEGRAM_BOT_TOKEN dimuat dari environment.${NC}"
fi

# ALLOWED_CHAT_IDS
if [ -z "$ALLOWED_CHAT_IDS" ]; then
    echo -e "${RED}[!] ALLOWED_CHAT_IDS belum diset.${NC}"
    read -rp "    Masukkan ALLOWED_CHAT_IDS Anda: " CHAT_INPUT
    if [ -n "$CHAT_INPUT" ]; then
        export ALLOWED_CHAT_IDS="$CHAT_INPUT"
        echo -e "${GREEN}[+] ALLOWED_CHAT_IDS diset untuk sesi ini.${NC}"
        echo -e "${YELLOW}    Tip: Tambahkan ke ~/.bashrc atau ~/.zshrc agar permanen:${NC}"
        echo -e "${GRAY}    export ALLOWED_CHAT_IDS=\"$CHAT_INPUT\"${NC}"
    else
        echo -e "${YELLOW}[!] Tidak ada nilai. ALLOWED_CHAT_IDS tetap kosong.${NC}"
    fi
else
    echo -e "${GREEN}[+] ALLOWED_CHAT_IDS dimuat dari environment.${NC}"
fi

# GEMINI_CLI_TRUST_WORKSPACE
if [ -z "$GEMINI_CLI_TRUST_WORKSPACE" ]; then
    export GEMINI_CLI_TRUST_WORKSPACE="true"
    echo -e "${GREEN}[+] GEMINI_CLI_TRUST_WORKSPACE diset ke 'true'.${NC}"
else
    echo -e "${GREEN}[+] GEMINI_CLI_TRUST_WORKSPACE dimuat dari environment.${NC}"
fi

# API_TOKEN
if [ -z "$API_TOKEN" ]; then
    API_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    export API_TOKEN
    echo -e "${GREEN}[+] API_TOKEN digenerate untuk sesi ini.${NC}"
    echo -e "${CYAN}    API_TOKEN Anda: $API_TOKEN${NC}"
    echo -e "${YELLOW}    Tip: Tambahkan ke ~/.bashrc atau ~/.zshrc agar permanen:${NC}"
    echo -e "${GRAY}    export API_TOKEN=\"$API_TOKEN\"${NC}"
else
    echo -e "${GREEN}[+] API_TOKEN dimuat dari environment.${NC}"
fi

# Run the binary
echo ""
echo -e "${YELLOW}[*] Menjalankan rprompt...${NC}"
echo -e "${GRAY}----------------------------------------${NC}"
echo ""

exec "$EXE_PATH"
