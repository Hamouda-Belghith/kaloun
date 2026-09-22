#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.4"
curl -fsSL -o /tmp/flutter.tar.xz \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
tar xf /tmp/flutter.tar.xz -C /tmp
export PATH="$PATH:/tmp/flutter/bin"
git config --global --add safe.directory /tmp/flutter

flutter config --enable-web --no-analytics
flutter build web --release --base-href /
