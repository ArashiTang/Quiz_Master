# Quiz Master

A Flutter quiz application.

## Prerequisites
- Flutter 3.22 or newer
- Dart SDK 3.9 or newer (included with Flutter)

## Native assets configuration (required)
This project depends on packages that ship native assets (for example `objective_c` pulled in by the database stack). Flutter requires the native assets feature to be enabled for these dependencies to build. If you see an error like:


```
Error: Package(s) objective_c require the native assets feature to be enabled.
Enable using `flutter config --enable-native-assets`.
```

Run the following once on your machine:

```
flutter config --enable-native-assets
flutter clean
flutter pub get
```

After enabling native assets, rebuild with `flutter run` or your usual build command.

## Running
1. Ensure a device or emulator is available.
2. Fetch dependencies: `flutter pub get`.
3. Launch the app: `flutter run`.
