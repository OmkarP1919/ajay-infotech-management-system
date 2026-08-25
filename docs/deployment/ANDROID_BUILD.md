# Android Build & Release Guide

This guide details building production-ready APKs and App Bundles (`.aab`) for the Student Mobile App.

---

## 1. Prerequisites & Versioning

Update `student-app/pubspec.yaml` with the target version and build number:
```yaml
version: 1.0.0+1
```

---

## 2. Release Keystore Generation

If generating a new release signing keystore:
```bash
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ajayinfotech
```

Configure `android/key.properties` (ensure this file remains in `.gitignore`):
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=ajayinfotech
storeFile=/absolute/path/to/release-key.jks
```

---

## 3. Building Release Artifacts

### Build Split APKs (Optimized size)
```bash
cd student-app
flutter build apk --release --split-per-abi
```

### Build Universal APK
```bash
cd student-app
flutter build apk --release
```

### Build Android App Bundle (Google Play Store)
```bash
cd student-app
flutter build appbundle --release
```

Output binaries will be located at:
`student-app/build/app/outputs/flutter-apk/` and `student-app/build/app/outputs/bundle/release/`.
