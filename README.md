# FNAF3-SDDM

> An SDDM (Qt6) login theme inspired by the **Five Nights at Freddy's 3** main menu aesthetic. 
---

## Preview

<video width="100%" controls autoplay loop>
  <source src="https://raw.githubusercontent.com/redbith/fnaf3-sddm/main/assets/preview.mp4" type="video/mp4">
</video>
*Boot sequence: fade to black → "NIGHT" scales in → night number flickers → "SECURITY SHIFT INITIATED" → white static burst → login screen.*

---

## Features

| Feature | Description |
|---|---|
| **FNAF 3 Boot Sequence** | Authentic "NIGHT X" intro with flicker, scan lines, and static burst transition |
| **CRT Monitor Effects** | Real-time Canvas-based static noise + CRT scan-line overlay |
| **Surveillance HUD** | Camera frame corners, "CAM 07 — OFFICE" label, blinking REC indicator |
| **Video Background** | Native `assets/menu-theme.webm` support with Qt6 Multimedia |
| **Access Denied** | Red flicker animation on failed authentication |
| **Fully Customizable** | Night number, colors, timings, and fonts via `theme.conf` |

---

## Repository Structure

```
fnaf3-sddm/
├── Main.qml              # Main screen: boot animation + login form
├── components/
│   ├── StaticNoise.qml    # TV static / noise effect (Canvas)
│   ├── ScanLines.qml      # CRT scan lines + vignette
│   └── FlickerText.qml    # Flickering text component
├── assets/
│   └── menu-theme.webm    # Background video (add your own)
├── fonts/
│   ├── PressStart2P-Regular.ttf  # Open source (OFL) pixel font
│   └── OFL.txt                    # Font license
├── theme.conf             # Colors, night number, timings, etc.
├── metadata.desktop        # SDDM theme definition (QtVersion=6)
├── install.sh              # Automated installation script
└── README.md
```

---

## Dependencies

```bash
sudo pacman -S sddm qt6-declarative qt6-svg qt6-multimedia qt6-multimedia-gstreamer
```

---

## Installation

### Quick Install (Recommended)

```bash
git clone https://github.com/YOUR_USERNAME/fnaf3-sddm.git
cd fnaf3-sddm
sudo ./install.sh
```

### Manual Install

```bash
git clone https://github.com/YOUR_USERNAME/fnaf3-sddm.git
cd fnaf3-sddm
sudo mkdir -p /usr/share/sddm/themes/fnaf3-sddm
sudo cp -r ./* /usr/share/sddm/themes/fnaf3-sddm/
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=fnaf3-sddm" | sudo tee /etc/sddm.conf.d/10-theme.conf
```

---

## Testing (Preview Without Logging Out)

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/fnaf3-sddm
```

> **Note:** On systems with Qt5 greeter, use `sddm-greeter` and remove `QtVersion=6` from `metadata.desktop`. Power buttons are inactive in test mode.

---

## Background Video

The theme expects a video file at `assets/menu-theme.webm`. Add your own:

```bash
cp ~/Downloads/your-video.webm fnaf3-sddm/assets/menu-theme.webm
```

Then ensure `theme.conf` contains:
```ini
VideoSource=assets/menu-theme.webm
VideoMuted=false
VideoVolume=0.6
```

> **Audio Notice:** SDDM runs in a separate session. PipeWire/PulseAudio may not route audio to the greeter. Set `VideoMuted=true` if you experience issues.

---

## Customization (`theme.conf`)

| Key | Default | Description |
|---|---|---|
| `NightNumber` | `1` | Night number displayed during boot |
| `AccentColor` | `#8b5cf6` | Primary HUD accent (purple) |
| `DangerColor` | `#ff2a2a` | Error / access denied color |
| `BackgroundColor` | `#000000` | Base background |
| `ShowCameraFrame` | `true` | Toggle camera corner brackets |
| `IntroDuration` | `6` | Boot animation duration (seconds) |
| `FontFamily` | `Press Start 2P` | Primary pixel font |

After editing, test immediately with `--test-mode`. No reboot required.

---

## Design Specifications

### Color Palette
- **Deep Black:** `#000000` — Background
- **Surveillance Purple:** `#8b5cf6` — HUD accents
- **Alert Red:** `#ff2a2a` — Warnings / access denied
- **CRT Green:** `#50fa7b` — Verified states (optional)

### Typography
- **Press Start 2P** (included, OFL licensed) — Pixel font for boot sequence and HUD
- Drop custom `.ttf` files into `fonts/` and update `FontFamily` in `theme.conf`

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Black screen / theme not loading | Check `journalctl -u sddm -b` for missing QML modules (`qt6-declarative`, `qt6-svg`) |
| No audio from video | SDDM runs as `sddm` user — audio routing depends on PipeWire/PulseAudio config. Set `VideoMuted=true` |
| `sddm` property errors | Compare `Main.qml` properties with other themes in `/usr/share/sddm/themes/*/Main.qml` |

---

## `install.sh`

```bash
#!/bin/bash
set -e

THEME_NAME="fnaf3-sddm"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
CONFIG_DIR="/etc/sddm.conf.d"

echo "[*] FNAF3-SDDM Theme Installer"

# Root check
if [ "$EUID" -ne 0 ]; then
    echo "[!] Run as root: sudo ./install.sh"
    exit 1
fi

# Dependency check
echo "[*] Checking SDDM..."
if ! command -v sddm &>/dev/null; then
    echo "[!] SDDM not found. Install with: sudo pacman -S sddm"
    exit 1
fi

# Install theme
echo "[*] Copying theme to ${THEME_DIR}..."
mkdir -p "${THEME_DIR}"
cp -r ./* "${THEME_DIR}/"

# Permissions
chmod 644 "${THEME_DIR}"/theme.conf 2>/dev/null || true
chmod 644 "${THEME_DIR}"/metadata.desktop 2>/dev/null || true
chmod -R 755 "${THEME_DIR}"/components 2>/dev/null || true
chmod -R 755 "${THEME_DIR}"/assets 2>/dev/null || true

# Configure SDDM
echo "[*] Setting SDDM theme..."
mkdir -p "${CONFIG_DIR}"
cat > "${CONFIG_DIR}/10-theme.conf" <<EOF
[Theme]
Current=${THEME_NAME}
EOF

echo "[*] Done."
echo "[*] Preview: sddm-greeter-qt6 --test-mode --theme ${THEME_DIR}"
echo "[*] Reboot to activate at the login screen."
```

---

## License

- **Press Start 2P Font:** [SIL Open Font License 1.1](fonts/OFL.txt)
- **Theme Code & Assets:** MIT License (see `LICENSE` file)
