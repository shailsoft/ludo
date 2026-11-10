# Release checklist

## Automated local gates

1. `flutter pub get`
2. `dart format --set-exit-if-changed lib test integration_test`
3. `flutter analyze`
4. `flutter test`
5. `flutter build appbundle --release`

## Publisher-owned steps

- Select bundle IDs, legal publisher name, support URL/email, privacy policy, and project license.
- Create and securely store Android upload/signing keys; configure Play App Signing.
- Enroll in Apple Developer Program; configure signing, capabilities, App Store Connect, privacy nutrition labels, and TestFlight.
- Verify current Google Play target SDK, data safety, families/ads, and Apple review requirements at submission time.
- Test on representative physical Android and iOS devices and complete accessibility review.

No signed artifact or store submission can be claimed without these credentials and external account actions.

