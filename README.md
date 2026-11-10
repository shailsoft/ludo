# Ludo Arena

An offline-first, family-friendly Ludo game for Android and iOS. The current implementation target is the Phase 0–3 offline MVP: pass-and-play, bots, Quick and Classic rules, saved matches, tutorial, settings, statistics, and English/Hindi UI.

## Local setup

This repository keeps a project-local Flutter SDK in `.tools/flutter` (ignored by Git).

```sh
cd mobile
../.tools/flutter/bin/flutter pub get
../.tools/flutter/bin/flutter test
../.tools/flutter/bin/flutter run
```

Android release builds use `../.tools/flutter/bin/flutter build appbundle`. Publisher signing is deliberately not stored in the repository. See `docs/release.md`.

## Architecture

`mobile/lib/game_core` is pure Dart and contains the canonical rules. UI, bots, and persistence consume the same legal-move API. Flutter-specific code never determines whether a move is legal. See `docs/architecture.md` and `docs/rules.md`.

Online play, advertising, purchases, and cash/redeemable rewards are not part of the offline MVP and are feature-gated off.

