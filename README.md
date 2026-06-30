# Night Shift — Gece Vardiyası Temalı SDDM Giriş Teması

Korku hayatta kalma oyunlarındaki "gece başlama ekranı" estetiğinden ilham
alan, güvenlik kamerası / CRT statik görünümlü bir SDDM (Qt6) giriş teması.

> Not: Bu tema gerçek oyun görselleri, logoları veya marka varlıkları
> içermez — telif hakkı nedeniyle bunları birebir kopyalayamam. Bunun yerine
> aynı atmosferi (statik parazit, taranma çizgileri, "NIGHT X" açılış
> animasyonu, kamera çerçevesi, mor/siyah palet) orijinal kodla yeniden
> yarattım. Açılışta `theme.conf` içinden gece numarasını, klasik logoya en
> yakın görünüm için de `fonts/` klasörüne istediğiniz bir piksel fontu
> ekleyerek dilediğiniz gibi özelleştirebilirsiniz (şu an açık kaynaklı
> "Press Start 2P" fontu hazır geliyor).

## İçerik

```
night-shift/
├── Main.qml              # Ana ekran: açılış animasyonu + giriş formu
├── components/
│   ├── StaticNoise.qml    # TV parazit/statik efekti (Canvas)
│   ├── ScanLines.qml      # CRT tarama çizgileri + vignette
│   └── FlickerText.qml    # Titreşen (flicker) metin bileşeni
├── fonts/
│   ├── PressStart2P-Regular.ttf  # Açık kaynak (OFL) piksel font
│   └── OFL.txt                    # Font lisansı
├── theme.conf             # Renkler, gece numarası, süreler vs.
├── metadata.desktop        # SDDM tema tanım dosyası (QtVersion=6)
├── install.sh              # Otomatik kurulum scripti
└── README.md
```

## Nasıl çalışıyor

1. **Açılış / splash animasyonu**: Ekran kararıyor, "NIGHT" yazısı büyüyerek
   beliriyor, ardından gece numarası (`theme.conf` içinde `NightNumber`)
   titreşerek (flicker) sahneye giriyor, kısa bir alt yazı ("SECURITY SHIFT
   INITIATED") görünüyor, birkaç saniye bekleniyor, ardından kısa bir beyaz
   "statik patlaması" ile sahne giriş ekranına geçiyor (FNAF serisindeki
   gece başlama ekranlarının klasik akışı: karartı → "NIGHT" → numara →
   bekleme → kesinti/geçiş).
2. **Giriş ekranı**: Kamera çerçevesi köşe işaretleri, sol üstte "CAM 07 —
   OFFICE" yazısı, sağ üstte yanıp sönen "REC" noktası, ortada kullanıcı/
   şifre/oturum seçimli giriş paneli, sağ altta güç düğmeleri. Arka planda
   sürekli hafif statik parazit ve tarama çizgileri devam ediyor.
3. Yanlış şifre girilirse "ACCESS DENIED" yazısı kırmızı titreşerek
   görünüyor.

## Arka plan videosu ekleme

1. Sahip olduğun video dosyasını temanın `media/` klasörüne **kendin**
   kopyala ve `menu-theme.webm` olarak adlandır (veya `theme.conf` içindeki
   `VideoSource` yolunu kendi dosya adına göre değiştir):
   ```bash
   cp ~/Downloads/senin-videon.webm night-shift/media/menu-theme.webm
   ```
2. Gerekli paketlerin kurulu olduğundan emin ol:
   ```bash
   sudo pacman -S qt6-multimedia qt6-multimedia-gstreamer
   ```
3. `theme.conf` içinde:
   - `VideoSource=media/menu-theme.webm`
   - `VideoMuted=false` / `VideoVolume=0.6` — videonun kendi içindeki sesi
     çalar (ayrı bir mp3'e gerek yok, webm dosyasında ses varsa otomatik
     gelir).
4. Login paneli ekranın **sol yarısında, dikey ortada** duracak şekilde
   konumlandırıldı — böylece video arka planının sağ tarafındaki karakter
   görseli (varsa) panel tarafından kapatılmıyor.

**Önemli — ses hakkında**: SDDM greeter, senin masaüstü oturumundan ayrı bir
sistem oturumunda (genelde `sddm` kullanıcısıyla) çalışır. Bu yüzden bazı
sistemlerde ses çıkışı (PipeWire/PulseAudio) greeter'a hiç ulaşmayabilir —
test modunda dene, gerçek girişte sesin gelmemesi normal olabilir ve
düzeltmesi SDDM/PipeWire sistem yapılandırmasına bağlı, temanın kendisiyle
ilgili değil. Sorun yaşarsan `VideoMuted=true` yaparak en azından videoyu
sessiz oynatabilirsin.



```bash
sudo pacman -S sddm   # zaten kurulu değilse
cd night-shift
sudo ./install.sh
```

Script temayı `/usr/share/sddm/themes/night-shift` dizinine kopyalar ve
`/etc/sddm.conf.d/10-theme.conf` içine `Current=night-shift` satırını yazar.

### Manuel kurulum isterseniz

```bash
sudo cp -r night-shift /usr/share/sddm/themes/
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=night-shift" | sudo tee /etc/sddm.conf.d/10-theme.conf
```

## Test etme (oturum kapatmadan önizleme)

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/night-shift
```

Arch'ta `sddm` artık varsayılan olarak Qt6 derlemesini kullanıyor
(`sddm-greeter-qt6`). Eğer sisteminizde hâlâ Qt5 greeter varsa, bu komutu
`sddm-greeter` olarak deneyin ve `metadata.desktop` içindeki `QtVersion=6`
satırını silin.

Test modunda güç düğmeleri (kapat/yeniden başlat) ve gerçek giriş işlevsiz
çalışır; bu normaldir.

## Özelleştirme (`theme.conf`)

| Anahtar | Açıklama |
|---|---|
| `NightNumber` | Açılışta gösterilen gece sayısı |
| `AccentColor` | Ana vurgu rengi (mor varsayılan) |
| `DangerColor` | Hata/uyarı rengi |
| `BackgroundColor` | Taban arka plan rengi |
| `ShowCameraFrame` | Kamera çerçevesi köşelerini göster/gizle |
| `IntroDuration` | Açılış animasyonunun toplam süresi (saniye) |
| `FontFamily` | Tercih edilen yazı tipi adı |

Değiştirdikten sonra tekrar `--test-mode` ile önizleyebilirsiniz; sistemi
yeniden başlatmaya gerek yok.

## Gerçek görünümü FNAF 3'e daha da yaklaştırmak isterseniz

- `components/StaticNoise.qml` içindeki `noiseOpacity` değerini artırarak
  paraziti güçlendirebilirsiniz.
- Kendi telif hakkına sahip olduğunuz veya kullanım izniniz olan bir arka
  plan görseli varsa, `Main.qml` içindeki arka plan `Rectangle`'ı bir
  `Image { source: "background.png"; fillMode: Image.PreserveAspectCrop }`
  ile değiştirip görseli tema klasörüne ekleyebilirsiniz. Ben telif hakkı
  nedeniyle oyunun gerçek görsellerini buraya koyamadım.

## Sorun giderme

- Ekran siyah kalıyorsa veya tema yüklenmiyorsa: `journalctl -u sddm -b`
  veya `--test-mode` çıktısındaki hata satırlarına bakın; genelde eksik bir
  QML modülü (`qt6-declarative`, `qt6-svg` gibi) kurulu değildir.
- `sddm` bağlam özellikleri (`sddm`, `userModel`, `sessionModel`) SDDM
  sürümleri arasında küçük farklılıklar gösterebilir; `--test-mode`
  çıktısında "is not a function" gibi bir hata görürseniz `Main.qml`
  içindeki ilgili satırı (örn. `sddm.canSuspend`) sisteminizdeki diğer
  temaların (`/usr/share/sddm/themes/*/Main.qml`) kullandığı isimle
  karşılaştırıp düzeltebilirsiniz.
