# Dashink API Sözleşmesi

Flutter uygulaması (`dashink`) ile Node.js backend'i (`dashink-backend`) arasındaki
sözleşme. Uygulama `USE_MOCK=false` iken bu uçları çağırır; mock modunda aynı
şekiller `assets/mock/` altından gelir.

## Genel

- Base URL: `BASE_URL` (canlı: `https://dashink.fly-work.com`, yerel: `http://<ip>:4130`).
  Uçlar `/api` öneki OLMADAN kökten sunulur.
- JSON alan adları **snake_case**. Tarihler ISO-8601 UTC (`2026-11-05T00:00:00.000Z`),
  gün anahtarları `YYYY-MM-DD` (UTC).
- Zarf:
  ```json
  { "status": "success", "message": "ok", "data": { ... } }
  { "status": "error", "message": "insufficient_coins", "data": null }
  ```
  Hata kodları (`message`): `invalid_request` 400, `unauthorized` 401, `not_found` 404,
  `insufficient_coins` / `already_owned` / `item_locked` / `not_owned` /
  `task_not_complete` / `already_claimed` 409, `invalid_score` 422, `server_error` 500.
- Kimlik: `Authorization: Bearer <access_token>` (JWT HS256, 1 saat). Refresh token 90 gün,
  DB'de sha256 hash, rotasyonlu.
- Gün/hafta sınırları **UTC**: gün 00:00 UTC'de, hafta pazartesi 00:00 UTC'de yenilenir.

## Kimlik

### `POST /auth/device` (kimliksiz)
```json
// istek
{ "device_id": "uuid", "platform": "ios", "app_version": "1.0.0" }
// data
{ "access_token": "...", "refresh_token": "...",
  "user": { "id": "uuid-v4", "name": "Oyuncu 4821" } }
```
Aynı `device_id` → aynı kullanıcı. Yeni kullanıcıya `"Oyuncu " + 4 haneli sayı` adı verilir.
`user.id` RevenueCat `app_user_id`'dir.

### `POST /auth/refresh` (kimliksiz)
`{ "refresh_token": "..." }` → `{ "access_token": "...", "refresh_token": "..." }`. Geçersiz → 401.

## Oyuncu

### `PlayerProgress` nesnesi
```json
{
  "user": { "id": "uuid", "name": "Oyuncu 4821" },
  "coins": 1240,
  "best_score": 312,
  "games_played": 41,
  "tutorial_seen": true,
  "premium": false,
  "owned_items": ["ball_klasik", "ink_lacivert", "theme_kagit", "ball_karpuz"],
  "equipped": { "ball": "ball_klasik", "ink": "ink_lacivert", "theme": "theme_kagit" },
  "rewards": [ { "type": "daily_rank", "date": "2026-11-04", "rank": 12, "coins": 100 } ]
}
```
- Yeni kullanıcı: `coins` 0, varsayılan öğeler (`ball_klasik`, `ink_lacivert`, `theme_kagit`) sahip ve kuşanılı.
- `rewards`: bu istekte **yeni** yüklenen ödüller (bir kez döner). Şimdilik yalnızca
  günlük meydan okuma ödülü: geçmiş (son 7 gün) bir günde ilk `reward_top` (100) içindeyse
  `reward` (100) altın. `daily_rewards (user_id, date)` UNIQUE ile bir kez verilir.

### `GET /player/progress` (Bearer) → `PlayerProgress`
### `POST /player/tutorial-complete` (Bearer) → `PlayerProgress`
### `POST /player/name` (Bearer) → `PlayerProgress`
```json
// istek
{ "name": "Zeynep" }
```
- `name`: trim + iç boşluklar tek boşluğa iner; 2..32 karakter; unicode harf/rakam, boşluk, `_ - . '`.
  Geçersizse 400 `invalid_request`. Ad benzersiz olmak zorunda değildir.

## Oyun

### `POST /games` (Bearer)
Bir oyunun sonucu. `client_event_id` ile idempotent (aynı id → ilk cevap aynen döner).
```json
// istek
{ "client_event_id": "uuid", "mode": "normal", "seed": 918273, "daily_date": null,
  "score": 128, "coins_collected": 14, "duration_ms": 42000 }
// data
{ "score": 128, "previous_best": 112, "best_score": 128, "new_record": true,
  "record_reward": 50, "coins_credited": 64, "coins": 1304,
  "daily": null, "completed_tasks": ["daily_score_100"] }
```
- `mode`: `normal` | `daily`. `daily` iken `daily_date` bugünün UTC günü olmalı (değilse 400)
  ve `seed` o günün seed'i olmalı (değilse 400).
- Doğrulama (aşılırsa 422 `invalid_score`): `score <= ceil(duration_ms / 1000 * 15) + 5`,
  `coins_collected <= floor(score / 2) + 5`, `duration_ms` 1 .. 3 600 000.
- `new_record`: `score > previous_best` VE `previous_best > 0` (ilk oyun rekor sayılmaz ama
  `best_score` güncellenir). Rekor ödülü `record_reward` = 50.
- `coins_credited = coins_collected + record_reward`; `coins_ledger`'a yazılır.
- `daily` (yalnızca `mode: daily`): `{ "date": "2026-11-05", "best": 140, "rank": 37 }`.
- `completed_tasks`: bu oyunla tamamlanabilir hâle gelen görev id'leri (claim edilmemiş).

### `POST /events/share` (Bearer)
`{ "client_event_id": "uuid" }` → `{ "ok": true }`. Klip/skor paylaşımı (görevler için). İdempotent.

## Mağaza

### `GET /shop/catalog` (kimlik isteğe bağlı)
```json
{
  "items": [
    { "id": "ball_klasik", "category": "ball", "price": 0, "unlock": "default" },
    { "id": "ball_karpuz", "category": "ball", "price": 200, "unlock": "coins" },
    { "id": "ball_disko", "category": "ball", "price": 0, "unlock": "task", "task_id": "ach_score_500" },
    { "id": "ball_yildiz", "category": "ball", "price": 3000, "unlock": "premium" },
    { "id": "ink_kirmizi", "category": "ink", "price": 150, "unlock": "coins", "color": "#F45D35" },
    { "id": "theme_gece", "category": "theme", "price": 3000, "unlock": "premium", "color": "#2B3260" }
  ],
  "premium": { "product_id": "dashink_premium", "entitlement": "premium", "bonus_coins": 1000 },
  "coin_packs": [
    { "product_id": "dashink_coins_500", "coins": 500 },
    { "product_id": "dashink_coins_1200", "coins": 1200 },
    { "product_id": "dashink_coins_3000", "coins": 3000 }
  ]
}
```
- `category`: `ball` | `ink` | `theme`. `unlock`: `default` | `coins` | `task` | `premium`.
- Ad/açıklama istemcide `id` ile yerelleştirilir. Top görseli istemcide `id`'den (`top_<ad>.png`).
- Katalog (sıra önemli):
  - Toplar: `ball_klasik` (default), `ball_karpuz` 200, `ball_basket` 250, `ball_tenis` 300,
    `ball_plaj` 400, `ball_gezegen` 500, `ball_ay` 600, `ball_bilardo` 700, `ball_goz` 800,
    `ball_buz` 900, `ball_lav` 1000, `ball_gokkusagi` 1500, `ball_disko` (task `ach_score_500`),
    `ball_yildiz` (premium, 3000)
  - Mürekkep: `ink_lacivert` (default, `#1D2550`), `ink_kirmizi` 150 (`#F45D35`),
    `ink_nane` 150 (`#2BBF98`), `ink_turuncu` 150 (`#FF8A1F`), `ink_pembe` 200 (`#F25C9A`),
    `ink_mavi` 200 (`#2F6FEB`), `ink_turkuaz` 200 (`#17A7B8`), `ink_yesil` 250 (`#3A9D23`),
    `ink_mor` 300 (`#7B4FD6`), `ink_kahve` 300 (`#7A4A2A`), `ink_bordo` 350 (`#8E1B3A`),
    `ink_gumus` 500 (`#9AA3B5`), `ink_altin` (premium 3000, `#F6B830`)
  - Temalar: `theme_kagit` (default, `#F7F0E1`), `theme_nane` 400 (`#E3F4EC`),
    `theme_gunbatimi` 400 (`#FBE3D6`), `theme_lavanta` 400 (`#ECE4FA`), `theme_gokyuzu` 400 (`#E1EEFB`),
    `theme_limon` 450 (`#FBF5D2`), `theme_seker` 450 (`#FBE4EE`), `theme_orman` 700 (koyu, `#1F3B2D`),
    `theme_uzay` 900 (koyu, `#14142B`), `theme_gece` (premium 3000, koyu, `#2B3260`)
  - Coin paketleri (RevenueCat consumable): `dashink_coins_500/1200/3000`

### `POST /shop/buy` (Bearer)
`{ "item_id": "ball_karpuz" }` → `PlayerProgress` (satın alır **ve kuşanır**).
409: `insufficient_coins`, `already_owned`, `item_locked` (task/default öğe coin ile alınamaz; premium öğeler 3000 altınla alınabilir).

### `POST /shop/equip` (Bearer)
`{ "item_id": "ball_karpuz" }` → `PlayerProgress`. 409 `not_owned`.

## Satın alma (RevenueCat, reklam yok)

- `dashink_premium` (non-consumable), entitlement `premium`: premium öğeleri
  (`ball_yildiz`, `ink_altin`, `theme_gece`) açar + bir kez `bonus_coins` (1000).
- Coin paketleri (consumable): `dashink_coins_500` / `_1200` / `_3000` → ilgili altın.
  Idempotency `iap_coin_grants.transaction_id` UNIQUE.

### `POST /purchases/sync` (Bearer) → `PlayerProgress`
`GET {REVENUECAT_API_BASE}/subscribers/{user.id}` ile entitlement + non_subscriptions
kontrol edilir; aktif premium ve eksik coin paketleri yüklenir.
"Satın alımları geri yükle" bunu çağırır.

### `POST /webhooks/revenuecat` (`Authorization: <REVENUECAT_WEBHOOK_AUTH>`)
`INITIAL_PURCHASE` / `NON_RENEWING_PURCHASE`:
- premium ürün → premium ver (+ bonus bir kez)
- coin paketi → altın yükle (`iap_coins`)
`TRANSFER` → hedef kullanıcıyı REST ile senkronla.
`CANCELLATION` / `REFUND`:
- premium → geri al (bonus geri alınmaz)
- coin paketi → mümkünse bakiyeden düş (`iap_coins_refund`)
Bilinmeyen kullanıcı → 200.

## Görevler

### `GET /tasks?period=daily|weekly|achievement` (Bearer)
```json
{ "period": "daily", "resets_at": "2026-11-06T00:00:00.000Z",
  "tasks": [
    { "id": "daily_play_3", "icon": "play", "target": 3, "progress": 3, "reward": 30,
      "status": "claimable", "unlocks_item": null }
  ] }
```
- `status`: `in_progress` | `claimable` | `claimed`. `resets_at` başarımlarda `null`.
- İlerleme `games` / `share_events` tablolarından pencere içinde hesaplanır.
- Görevler (`icon`, hedef, ödül):
  - Günlük: `daily_play_3` (play, 3 oyun, 30), `daily_coins_50` (trophy, tek oyunda 50 altın, 50),
    `daily_share_1` (share, 1 paylaşım, 40), `daily_challenge_1` (calendar, günlük parkurda 1 oyun, 30),
    `daily_score_100` (crown, tek oyunda 100 puan, 30)
  - Haftalık: `weekly_play_20` (play, 20 oyun, 150), `weekly_challenge_3` (calendar, 3 farklı gün
    günlük parkur, 120), `weekly_coins_300` (coin, toplam 300 altın, 100),
    `weekly_score_300` (crown, tek oyunda 300 puan, 150)
  - Başarım (kolaydan zora): `ach_games_10` (play, 10 oyun, 50),
    `ach_score_500` (crown, 500 tek oyunda puan, 100, `unlocks_item: "ball_disko"`),
    `ach_games_50` (play, 50 oyun, 200),
    `ach_coins_1000` (coin, 1000 toplam altın, 200),
    `ach_run_coins_100` (trophy, 100 tek oyunda altın, 150),
    `ach_share_5` (share, 5 paylaşım, 100),
    `ach_daily_7` (calendar, 7 farklı gün günlük parkur, 200),
    `ach_score_1000` (crown, 1000 tek oyunda puan, 300),
    `ach_games_200` (play, 200 oyun, 400),
    `ach_coins_5000` (coin, 5000 toplam altın, 500),
    `ach_share_20` (share, 20 paylaşım, 300),
    `ach_daily_30` (calendar, 30 farklı gün günlük parkur, 600)
  - Metrikler: `games` (oyun sayısı), `max_score`, `max_coins` (tek oyunda), `sum_coins`
    (toplanan altın, rekor ödülü hariç), `shares`, `daily_games` (mode=daily oyun sayısı),
    `daily_days` (mode=daily oynanan farklı gün).

### `POST /tasks/:id/claim` (Bearer)
→ `{ "task": { ...güncel görev... }, "coins": 1270, "unlocked_item": "ball_disko" | null }`.
409 `task_not_complete` / `already_claimed`. `task_claims (user_id, task_id, period_key)` UNIQUE;
`period_key` günlükte `YYYY-MM-DD`, haftalıkta haftanın pazartesisi, başarımda `all`.

## Sıralama

### `GET /leaderboard?period=daily|weekly|all&limit=50` (Bearer)
```json
{ "period": "daily",
  "entries": [ { "rank": 1, "user_id": "uuid", "name": "Zeynep", "score": 1024, "is_me": false } ],
  "me": { "rank": 24, "name": "Oyuncu 4821", "score": 312 } }
```
Pencere içindeki her kullanıcının en iyi skoru (tüm modlar). Eşitlikte önce ulaşan üstte.
`me` pencerede oyunu yoksa `null`. `limit` 1..100 (varsayılan 50).

## Günlük meydan okuma

### `GET /daily` (Bearer)
```json
{ "date": "2026-11-05", "seed": 51234987, "participants": 12480, "my_best": null,
  "my_rank": null, "ends_at": "2026-11-06T00:00:00.000Z", "reward": 100, "reward_top": 100 }
```
`seed` = `DAILY_SEED_SECRET` + tarih HMAC'inin ilk 31 biti (herkese aynı parkur).
`participants` o gün `mode=daily` oynayan farklı kullanıcı sayısı.
