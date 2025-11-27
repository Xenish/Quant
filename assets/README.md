# Assets Setup

Place your branding files here before running the launcher icon or splash generators:

- `assets/icons/app_icon.png`: square PNG (512x512 recommended) used by `flutter_launcher_icons`.
- `assets/splash/splash_icon.png`: centered logo for the splash screen (transparent background preferred).

After adding the files, run:

```
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

Update the file names in `pubspec.yaml` if you choose different paths.
