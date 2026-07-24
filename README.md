# Forge

A real home-screen widget app for **Android and iOS** that shows your live GitHub
stats - contribution grid, day streak, PRs merged, followers, stars - in a clean
dark/light design.

Built with Flutter (shared app) + native widget layers (Android Glance, iOS
WidgetKit). Sign in with GitHub for real, private-aware stats.

> Status: in active development. See [ROADMAP.md](ROADMAP.md) for the plan,
> architecture, and folder structure.

## Quick start (Android, free)

```bash
flutter pub get
flutter run   # with your Android phone connected over USB (USB debugging on)
```

## Release signing (Android)

Release APKs are signed with a dedicated release key, not the shared Flutter
debug key — debug-signed APKs get flagged by Chrome/Play Protect as
untrustworthy since every Flutter install shares the same debug certificate.

To build a signed release locally:

```bash
keytool -genkeypair -v -keystore android/forge-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias forge
```

Then create `android/key.properties` (gitignored, never commit it):

```
storePassword=<your store password>
keyPassword=<your key password>
keyAlias=forge
storeFile=forge-release.jks
```

Without `key.properties`, `flutter build apk --release` falls back to debug
signing so the build still works — you just won't get a trusted release
artifact. **Back up the keystore and `key.properties` somewhere safe** (e.g.
a password manager); losing them means you can never sign an update with the
same identity again.

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for setup,
project structure, and PR guidelines.

## License

MIT - see [LICENSE](LICENSE).
