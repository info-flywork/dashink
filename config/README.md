# Ortam dosyaları (`--dart-define-from-file`)

Varsayılan `BASE_URL` (dart-define olmadan): `https://dashink.fly-work.com`.
RevenueCat public SDK anahtarları uygulamada sabittir; secret/webhook backend'dedir.

| Dosya | Ne için |
|---|---|
| `prod.json` | Canlı: `https://dashink.fly-work.com` |
| `local_simulator.json` | Simülatör → Mac'teki yerel backend (`http://127.0.0.1:4130`) |
| `local_device.json` | Fiziksel cihaz → Mac'teki yerel backend (`http://<Mac LAN IP>:4130`). IP değişirse güncelleyin (`ipconfig getifaddr en0`). Backend `HOST=0.0.0.0` ile başlatılmalı. |
