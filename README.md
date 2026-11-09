# Dashink

Topun önüne mürekkeple çizip onu uçurumlardan geçirdiğin sonsuz koşu oyunu.
Figma: `v0EqS820RVzmPhzGeBQn4m` (Dashink, 15 ekran). Backend: `../dashink-backend`
(Express + MySQL). Sözleşme: `docs/API_CONTRACT.md`.

Yapı `arrow_shift` ile aynı: BLoC + GetIt + GoRouter + Dio (`NetworkManager`,
`{status, message, data}` zarfı) + easy_localization (tr, en) + flutter_gen.

```
lib/
  core/        di, dialogs (AppDialogs), network (+mock), router, theme, widgets,
               sound (efekt + müzik + titreşim), clip (son 8 sn GIF), managers
  data/model/  json_serializable modelleri
  domain/      repository'ler + oyun motoru (domain/game/game_world.dart, saf Dart)
  presentation/<ekran>/{bloc, view/{mixin, widgets}}
```

## Figma → uygulama

| Figma | Uygulamada |
|---|---|
| 01-01 splash (typewriter) | `splash` — harf harf "flywork" (Figma motion: 166 ms) |
| egitim | `tutorial` — 3 adım (Figma'da 1; diğerleri aynı düzende) |
| ana-ekran | `home` (alt sekmeli kabuk: Oyna / Mağaza / Görevler / Ayarlar) |
| top-dustu | `game` — oyun ekranı bu karenin diliyle tasarlandı (Figma'da yoktu) |
| oyun-bitti, rekor-rozeti, oyuncu-secimi, klip-paylas | `AppDialogs.showGameOver / showRecord / showChoice / showClipShare` |
| siralama, gunluk-meydan-okuma | Oyna sekmesinin alt sayfaları |
| magaza, satin-al-kusan, altin-yetersiz | `shop` + `AppDialogs.showBuyConfirm / showNotEnoughCoins` |
| gorevler, ayarlar | `tasks`, `settings` |

Tasarımda olmayıp eklenenler: duraklatma, görevle açılan öğe ve premium
diyalogları, dil seçimi, mürekkep/tema kartlarının görselleri.

## Oyun

- Top kendiliğinden yuvarlanır ve zamanla hızlanır; parmakla çizilen mürekkep
  zemine dönüşür, **her nokta 1 saniyede silinir**. Mürekkep haznesi çizdikçe
  azalır, bırakınca dolar.
- Boşluğa düşmek veya sivriye değmek oyunu bitirir. Skor = mesafe / 40.
- Parkur tohumludur (seed): günlük meydan okumada herkese aynı parkur.
- Ayarlar: `GameRules` (`lib/domain/game/game_world.dart`).
- Son ~5 saniye 20 fps / 360 px kaydedilir; paylaşımda MP4 (+ Bunny CDN linki)
  üretilir, galeriye de video kaydedilir.

## Kararlar

- Reklam yok. Tek satın alma: `dashink_premium` (RevenueCat, non-consumable) →
  yıldız top, altın mürekkep, gece teması + 1000 altın. Premium'u sunucu verir.
- Altın, rekor ödülü, görev ödülü ve sıralama sunucuda doğrulanır; oyun sonucu
  çevrimdışıyken kuyruğa alınır (`client_event_id` ile idempotent).

## Çalıştırma

```bash
dart run build_runner build --delete-conflicting-outputs
flutter run                                                    # canlı backend (dashink.fly-work.com)
flutter run --dart-define-from-file=config/local_simulator.json # yerel backend (127.0.0.1:4130)
flutter run --dart-define=USE_MOCK=true                        # backend'siz (assets/mock)
flutter build ipa --dart-define-from-file=config/prod.json
```

RevenueCat public SDK anahtarları kodda (`StringConstants`); secret key ve
webhook auth yalnızca backend `.env` içindedir. Coin / premium kredisi
`POST /webhooks/revenuecat` ile sunucuda verilir.

## Testler

```bash
flutter test   # oyun motoru (seed, köprü, mürekkep), oyuncu kuralları
```
