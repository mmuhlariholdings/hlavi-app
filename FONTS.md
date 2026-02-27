# Font Setup Instructions

This app uses the **Space Grotesk** font family (matching the web application).

## Download Instructions

1. Go to [Google Fonts - Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk)
2. Click the "Download family" button
3. Extract the downloaded ZIP file
4. Locate the following font files in the extracted folder (usually in a `static/` subdirectory):
   - `SpaceGrotesk-Regular.ttf` (weight 400)
   - `SpaceGrotesk-Medium.ttf` (weight 500)
   - `SpaceGrotesk-SemiBold.ttf` (weight 600)
   - `SpaceGrotesk-Bold.ttf` (weight 700)

## Installation

1. Create the fonts directory if it doesn't exist:
   ```bash
   mkdir -p assets/fonts
   ```

2. Copy the four font files to the `assets/fonts/` directory:
   ```bash
   cp path/to/SpaceGrotesk-Regular.ttf assets/fonts/
   cp path/to/SpaceGrotesk-Medium.ttf assets/fonts/
   cp path/to/SpaceGrotesk-SemiBold.ttf assets/fonts/
   cp path/to/SpaceGrotesk-Bold.ttf assets/fonts/
   ```

3. Verify the files are in place:
   ```bash
   ls -la assets/fonts/
   ```

   You should see:
   ```
   SpaceGrotesk-Regular.ttf
   SpaceGrotesk-Medium.ttf
   SpaceGrotesk-SemiBold.ttf
   SpaceGrotesk-Bold.ttf
   ```

4. The fonts are already configured in `pubspec.yaml`, so no additional configuration is needed.

5. Run the app to verify fonts are loading correctly:
   ```bash
   flutter run
   ```

## Troubleshooting

If the fonts are not displaying:

1. Ensure the font files are in the correct location: `assets/fonts/`
2. Check that the file names match exactly (case-sensitive)
3. Run `flutter clean` and then `flutter pub get`
4. Restart the app

## Alternative: Using Google Fonts Package

If you prefer to use the `google_fonts` package instead of bundling fonts:

1. The fonts will download automatically on first use
2. However, this requires an internet connection
3. For offline-first functionality, bundled fonts (as configured) are recommended
