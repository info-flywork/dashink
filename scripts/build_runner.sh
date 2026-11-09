#!/usr/bin/env bash
# Kod üretimi: json_serializable + flutter_gen + easy_localization anahtarları
set -euo pipefail
cd "$(dirname "$0")/.."
dart run build_runner build
dart run easy_localization:generate \
  -S assets/translations -f keys -o locale_keys.g.dart -O lib/generated
