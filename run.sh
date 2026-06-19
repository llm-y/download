#!/bin/bash
# run.sh - Download and install rprompt for Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/llm-y/download/main/run.sh | bash
# Atau: bash <(curl -fsSL https://raw.githubusercontent.com/llm-y/download/main/run.sh)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Determine shell profile file
detect_profile() {
    local SHELL_NAME
    SHELL_NAME=$(basename "${SHELL:-/bin/bash}")
    case "$SHELL_NAME" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *)    echo "$HOME/.profile" ;;
    esac
}

PROFILE=$(detect_profile)

# Check if running interactively (not piped)
is_interactive() {
    # When piped via curl | bash, stdin is not a terminal
    [ -t 0 ]
}

# Prompt user with default value support (only works in interactive mode)
prompt_value() {
    local VARNAME="$1"
    local DESCRIPTION="$2"
    local HINT="$3"
    local REQUIRED="$4"
    local CURRENT_VAL="${!VARNAME}"

    if [ -n "$CURRENT_VAL" ]; then
        echo -e "${GREEN}[✓] $VARNAME sudah diset.${NC}"
        return 0
    fi

    if ! is_interactive; then
        if [ "$REQUIRED" = "yes" ]; then
            echo -e "${RED}[✗] $VARNAME belum diset (WAJIB).${NC}"
            return 1
        else
            echo -e "${YELLOW}[~] $VARNAME belum diset (opsional, akan digenerate).${NC}"
            return 0
        fi
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}$VARNAME${NC} ${DIM}($DESCRIPTION)${NC}"
    if [ -n "$HINT" ]; then
        echo -e "${CYAN}│${NC} ${DIM}$HINT${NC}"
    fi
    echo -e "${CYAN}└─────────────────────────────────────────────────────${NC}"

    local INPUT
    read -rp "  Masukkan nilai: " INPUT </dev/tty

    if [ -n "$INPUT" ]; then
        export "$VARNAME=$INPUT"
        echo -e "${GREEN}  [✓] $VARNAME diset.${NC}"
        return 0
    else
        if [ "$REQUIRED" = "yes" ]; then
            echo -e "${RED}  [✗] Nilai kosong. $VARNAME wajib diisi!${NC}"
            return 1
        fi
        return 0
    fi
}

# Save env var to shell profile
save_to_profile() {
    local VARNAME="$1"
    local VALUE="$2"

    if grep -q "^export $VARNAME=" "$PROFILE" 2>/dev/null; then
        # Update existing
        sed -i "s|^export $VARNAME=.*|export $VARNAME=\"$VALUE\"|" "$PROFILE"
    else
        echo "" >> "$PROFILE"
        echo "# rprompt: $VARNAME" >> "$PROFILE"
        echo "export $VARNAME=\"$VALUE\"" >> "$PROFILE"
    fi
}

# ============================================
# MAIN SCRIPT START
# ============================================

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   ${BOLD}Rprompt - Installer & Runner (Linux)${NC}${CYAN}   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Step 1: Detect Architecture ---
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  BINARY="rprompt-linux-amd64" ;;
    aarch64) BINARY="rprompt-linux-arm64" ;;
    arm64)   BINARY="rprompt-linux-arm64" ;;
    *)
        echo -e "${RED}[✗] Arsitektur tidak didukung: $ARCH${NC}"
        exit 1
        ;;
esac

BIN_URL="https://raw.githubusercontent.com/llm-y/download/main/bin/${BINARY}"
INSTALL_DIR="$HOME/.local/bin"
EXE_PATH="${INSTALL_DIR}/rprompt"

echo -e "${BLUE}[1/4]${NC} ${BOLD}Deteksi Sistem${NC}"
echo -e "      OS: $(uname -s) | Arch: $ARCH | Binary: $BINARY"
echo ""

# --- Step 2: Download Binary ---
echo -e "${BLUE}[2/4]${NC} ${BOLD}Download & Install${NC}"

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    echo -e "      Direktori dibuat: $INSTALL_DIR"
fi

echo -e "      Mengunduh dari GitHub..."
if command -v curl &> /dev/null; then
    curl -fsSL "$BIN_URL" -o "$EXE_PATH"
elif command -v wget &> /dev/null; then
    wget -q "$BIN_URL" -O "$EXE_PATH"
else
    echo -e "${RED}      [✗] curl atau wget tidak ditemukan!${NC}"
    exit 1
fi
chmod +x "$EXE_PATH"
echo -e "${GREEN}      [✓] Terinstal di: $EXE_PATH${NC}"

# Add to PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    if ! grep -q "$INSTALL_DIR" "$PROFILE" 2>/dev/null; then
        echo "" >> "$PROFILE"
        echo "# Added by rprompt installer" >> "$PROFILE"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$PROFILE"
        echo -e "${GREEN}      [✓] PATH ditambahkan ke $PROFILE${NC}"
    fi
    export PATH="$PATH:$INSTALL_DIR"
fi
echo ""

# --- Step 3: Environment Variables ---
echo -e "${BLUE}[3/4]${NC} ${BOLD}Konfigurasi Environment${NC}"

MISSING_REQUIRED=0

if is_interactive; then
    # === INTERACTIVE MODE ===
    echo -e "      Mode: ${GREEN}Interaktif${NC} - Anda akan dipandu mengisi konfigurasi."
    echo ""

    # TELEGRAM_BOT_TOKEN
    prompt_value "TELEGRAM_BOT_TOKEN" \
        "Token bot Telegram dari @BotFather" \
        "Buka @BotFather di Telegram → /newbot → copy token" \
        "yes" || MISSING_REQUIRED=1

    # ALLOWED_CHAT_IDS
    prompt_value "ALLOWED_CHAT_IDS" \
        "Chat ID yang diizinkan (pisahkan dengan koma)" \
        "Kirim /start ke @userinfobot untuk mendapatkan chat ID Anda" \
        "yes" || MISSING_REQUIRED=1

    # AGY_TRUST_WORKSPACE
    if [ -z "$AGY_TRUST_WORKSPACE" ]; then
        export AGY_TRUST_WORKSPACE="true"
    fi
    echo ""
    echo -e "${GREEN}[✓] AGY_TRUST_WORKSPACE = true${NC}"

    # API_TOKEN
    if [ -z "$API_TOKEN" ]; then
        API_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        export API_TOKEN
        echo -e "${GREEN}[✓] API_TOKEN digenerate: ${CYAN}$API_TOKEN${NC}"
    else
        echo -e "${GREEN}[✓] API_TOKEN sudah diset.${NC}"
    fi

    # Offer to save to profile
    if [ "$MISSING_REQUIRED" -eq 0 ]; then
        echo ""
        echo -e "${CYAN}┌─────────────────────────────────────────────────────${NC}"
        echo -e "${CYAN}│${NC} Simpan konfigurasi ke ${BOLD}$PROFILE${NC} agar permanen?"
        echo -e "${CYAN}│${NC} (Anda tidak perlu memasukkan ulang saat berikutnya)"
        echo -e "${CYAN}└─────────────────────────────────────────────────────${NC}"
        read -rp "  Simpan? [Y/n]: " SAVE_CHOICE </dev/tty
        SAVE_CHOICE="${SAVE_CHOICE:-Y}"

        if [[ "$SAVE_CHOICE" =~ ^[Yy]$ ]]; then
            save_to_profile "TELEGRAM_BOT_TOKEN" "$TELEGRAM_BOT_TOKEN"
            save_to_profile "ALLOWED_CHAT_IDS" "$ALLOWED_CHAT_IDS"
            save_to_profile "AGY_TRUST_WORKSPACE" "$AGY_TRUST_WORKSPACE"
            save_to_profile "API_TOKEN" "$API_TOKEN"
            echo -e "${GREEN}      [✓] Konfigurasi disimpan ke $PROFILE${NC}"
            echo -e "${DIM}      (Berlaku otomatis di terminal baru)${NC}"
        else
            echo -e "${YELLOW}      [~] Tidak disimpan. Env vars hanya berlaku untuk sesi ini.${NC}"
        fi
    fi

else
    # === NON-INTERACTIVE MODE (piped via curl | bash) ===
    echo -e "      Mode: ${YELLOW}Non-Interaktif${NC} (dijalankan via pipe)"
    echo ""

    # Check existing env vars
    if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
        echo -e "${GREEN}      [✓] TELEGRAM_BOT_TOKEN sudah diset.${NC}"
    else
        echo -e "${RED}      [✗] TELEGRAM_BOT_TOKEN belum diset (WAJIB).${NC}"
        MISSING_REQUIRED=1
    fi

    if [ -n "$ALLOWED_CHAT_IDS" ]; then
        echo -e "${GREEN}      [✓] ALLOWED_CHAT_IDS sudah diset.${NC}"
    else
        echo -e "${RED}      [✗] ALLOWED_CHAT_IDS belum diset (WAJIB).${NC}"
        MISSING_REQUIRED=1
    fi

    if [ -z "$AGY_TRUST_WORKSPACE" ]; then
        export AGY_TRUST_WORKSPACE="true"
    fi
    echo -e "${GREEN}      [✓] AGY_TRUST_WORKSPACE = true${NC}"

    if [ -z "$API_TOKEN" ]; then
        API_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        export API_TOKEN
    fi
    echo -e "${GREEN}      [✓] API_TOKEN = $API_TOKEN${NC}"
fi

echo ""

# --- Step 4: Run or show help ---
echo -e "${BLUE}[4/4]${NC} ${BOLD}Menjalankan rprompt${NC}"

if [ "$MISSING_REQUIRED" -ne 0 ]; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  Tidak bisa menjalankan rprompt - ada env var yang kosong!   ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Cara mengatasi:${NC}"
    echo ""
    echo -e "${CYAN}  Opsi 1: Set env vars dulu, lalu jalankan ulang${NC}"
    echo -e "${DIM}  ─────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}# 1. Dapatkan token dari @BotFather di Telegram${NC}"
    echo -e "  export TELEGRAM_BOT_TOKEN=\"your_bot_token_here\""
    echo ""
    echo -e "  ${BOLD}# 2. Dapatkan chat ID dari @userinfobot di Telegram${NC}"
    echo -e "  export ALLOWED_CHAT_IDS=\"123456789\""
    echo ""
    echo -e "  ${BOLD}# 3. Jalankan ulang installer${NC}"
    echo -e "  curl -fsSL https://raw.githubusercontent.com/llm-y/download/main/run.sh | bash"
    echo ""
    echo -e "${CYAN}  Opsi 2: Jalankan secara interaktif (guided setup)${NC}"
    echo -e "${DIM}  ─────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  bash <(curl -fsSL https://raw.githubusercontent.com/llm-y/download/main/run.sh)"
    echo ""
    echo -e "${CYAN}  Opsi 3: Langsung jalankan rprompt (jika env sudah diset)${NC}"
    echo -e "${DIM}  ─────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  rprompt"
    echo ""
    echo -e "${DIM}  Panduan lengkap: https://llm-y.github.io/download${NC}"
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}      Semua konfigurasi lengkap! Menjalankan rprompt...${NC}"
echo -e "${DIM}──────────────────────────────────────────────────────────${NC}"
echo ""

exec "$EXE_PATH"
