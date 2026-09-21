# mobile_app

## Google Maps setup

The location picker uses `google_maps_flutter`. Provide the same restricted API
key for the Maps SDK before running the app:

- Android: add `GOOGLE_MAPS_API_KEY=your-key` to `android/gradle.properties`.
- Flutter: run with `--dart-define=GOOGLE_MAPS_API_KEY=your-key` as well. The
	picker intentionally stays on a configuration message when this define is
	missing, preventing the Android Maps SDK from crashing the app.
- iOS: add `GOOGLE_MAPS_API_KEY` as a user-defined build setting in the Runner
	Xcode project.

The key should have the Android Maps SDK and iOS Maps SDK enabled, with app
restrictions configured for the package/bundle identifiers.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
