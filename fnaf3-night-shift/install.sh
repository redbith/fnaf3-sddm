#!/usr/bin/env bash
# Night Shift SDDM theme installer for Arch Linux
set -e

THEME_NAME="night-shift"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="/usr/share/sddm/themes/${THEME_NAME}"
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF_FILE="${SDDM_CONF_DIR}/10-theme.conf"

if [[ $EUID -ne 0 ]]; then
    echo "Bu script root yetkisi gerektirir. Lütfen 'sudo ./install.sh' ile çalıştırın."
    exit 1
fi

echo ">> Tema /usr/share/sddm/themes/${THEME_NAME} konumuna kopyalanıyor..."
mkdir -p "${DEST_DIR}"
cp -r "${SRC_DIR}"/* "${DEST_DIR}/"
rm -f "${DEST_DIR}/install.sh"

echo ">> sddm gerekli paketler kontrol ediliyor..."
if ! pacman -Qi sddm >/dev/null 2>&1; then
    echo "UYARI: 'sddm' paketi kurulu görünmüyor. Önce 'sudo pacman -S sddm' çalıştırın."
fi

echo ">> ${SDDM_CONF_FILE} dosyasına tema ayarlanıyor..."
mkdir -p "${SDDM_CONF_DIR}"
cat > "${SDDM_CONF_FILE}" <<EOF
[Theme]
Current=${THEME_NAME}
EOF

echo ">> Kurulum tamamlandı."
echo ""
echo "Test etmek için (oturumu kapatmadan önizleme):"
echo "  sddm-greeter-qt6 --test-mode --theme ${DEST_DIR}"
echo ""
echo "(Eğer 'sddm-greeter-qt6' bulunamazsa, sisteminiz Qt5 sddm-greeter kullanıyor olabilir;"
echo " bu durumda 'sddm-greeter --test-mode --theme ${DEST_DIR}' deneyin ve"
echo " metadata.desktop içindeki QtVersion=6 satırını kaldırın/5 yapın.)"
echo ""
echo "Gerçek giriş ekranında görmek için sistemi yeniden başlatın veya:"
echo "  sudo systemctl restart sddm"
