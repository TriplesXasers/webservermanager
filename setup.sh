#!/bin/bash

clear
echo ""
echo "====================================================="
echo "     WEB SERVER MANAGER - KURULUM & BAŞLATMA"
echo "====================================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Python3 kontrolü
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}[UYARI] Python3 bulunamadı!${NC}"
    read -p "Python3 kurulsun mu? [E/H]: " choice
    if [[ $choice =~ ^[Ee]$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install python@3.12
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y python3 python3-pip python3-venv
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip
        fi
    else
        exit 1
    fi
fi

# Python sürüm kontrolü
PYVER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
echo "Python sürümü: $PYVER"
if [[ $(echo "$PYVER < 3.0.0" | bc -l 2>/dev/null || echo 1) -eq 1 ]]; then
    echo -e "${RED}[HATA] Python 3.0.0+ gerekli!${NC}"
    exit 1
fi

# venv oluştur
if [ ! -d "venv" ]; then
    echo "Sanal ortam (venv) oluşturuluyor..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}[HATA] venv oluşturulamadı!${NC}"
        exit 1
    fi
fi

# venv aktif et
source venv/bin/activate

# Gerekli paketler
packages=("requests" "pyperclip" "psutil")
for pkg in "${packages[@]}"; do
    python -c "import $pkg" 2>/dev/null
    if [ $? -ne 0 ]; then
        while true; do
            echo -e "${YELLOW}[EKLENTİ] $pkg eksik!${NC}"
            read -p "$pkg kurulsun mu? [E/H]: " choice
            if [[ $choice =~ ^[Ee]$ ]]; then
                pip install $pkg --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}$pkg kuruldu.${NC}"
                    break
                else
                    echo -e "${RED}[HATA] Yeniden deneniyor...${NC}"
                fi
            else
                exit 1
            fi
        done
    fi
done

# Node.js ve localtunnel
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}[UYARI] Node.js eksik!${NC}"
    read -p "Node.js kurulsun mu? [E/H]: " choice
    if [[ $choice =~ ^[Ee]$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install node
        elif command -v apt &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt install -y nodejs
        fi
    fi
fi

if command -v npm &> /dev/null && ! npm list -g localtunnel &> /dev/null; then
    read -p "localtunnel kurulsun mu? [E/H]: " choice
    if [[ $choice =~ ^[Ee]$ ]]; then
        npm install -g localtunnel --silent
    fi
fi

# sites klasörü
mkdir -p sites

echo ""
echo "====================================================="
echo "           KURULUM TAMAMLANDI! BAŞLATIYOR..."
echo "====================================================="
echo ""
python main.py
