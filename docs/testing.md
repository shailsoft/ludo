# Testing strategy

Pure Dart engine tests cover the mandatory rules matrix, serialization, determinism, and bots. Widget tests cover navigation, game setup, legal input phases, localization, settings, and multiple viewport sizes. Integration tests cover save/resume and one scripted match. Android release build is the final local Phase 4 gate.

Commands and results are recorded in `IMPLEMENTATION_STATUS.md`; a checkbox is marked only after the corresponding command succeeds in this environment.

## Latest run — 2026-11-09

- Static analysis: no issues.
- Automated tests: 20 passed. Coverage includes canonical rotation, entry, shared track, home lane, exact finish, Classic/Quick victory, captures, safety, stacking, extra rolls, third-six penalty, invalid turns/actions, optional bonuses, JSON round trips, schema rejection, all bot levels, two viewport sizes, 52 unique rendered track cells, and critical English/Hindi strings.
- Android release: Gradle and Flutter bundle verification passed after the premium UI, audio, and haptics work. The lobby, setup, and live match were visually checked on the `medium_phone` Android emulator at 1080×2400. The generated AAB is for local verification only; the publisher must configure production upload signing.
- Not yet run: physical-device UI/accessibility checks, app-kill lifecycle integration, iOS build, full scripted match completion.

