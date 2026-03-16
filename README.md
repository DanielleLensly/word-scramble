# Kids Scramble Quest 🌟

A fun, interactive, and beautifully designed Flutter application designed to help children learn spelling and recognize letter patterns through word scrambling! This app takes an innovative approach by allowing teachers and parents to instantly import and generate scrambled spelling lists from almost any source.

## Features ✨

*   **Interactive Scrambling**: Watch spelling words instantly shuffle their letters to create engaging puzzles.
*   **Smart Importing**: Say goodbye to manual typing!
    *   **Camera OCR (Optical Character Recognition)**: Snap a photo of a physical spelling list to automatically import the words!
    *   **File Support**: Extract words directly from `.pdf`, `.docx`, `.xlsx`, and `.txt` files in a flash.
    *   **Gallery Import**: Upload saved workbook screenshots or photos straight from your gallery.
*   **Printable Worksheets**: With the click of a single button, generate a beautifully formatted, print-ready PDF worksheet featuring your scrambled words above a "Your Answer" line, and a handy parent/teacher answer key at the bottom.
*   **Case Toggling**: Includes a top-level switch to easily toggle scrambled words between UPPERCASE and lowercase to suit different reading levels.
*   **Review & Edit Flow**: Features an intuitive dialogue allowing parents/teachers to review and fine-tune imported OCR/Document words before they are added to the live list.
*   **Dynamic Reshuffling**: Not happy with the current letter arrangement? Just tap the reshuffle button next to any word to instantly scramble it again!
*   **Import History**: Automatically saves your successfully imported word lists so you can quickly restore past sessions without having to re-scan or re-upload files.

## Getting Started For Developers 🛠️

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You will need the following installed:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [Android Studio](https://developer.android.com/studio) (for Android emulation & deployment) or Visual Studio (for Windows Desktop)

### Running Locally

1. Clone or download this project.
2. Open the project folder in your preferred IDE (VS Code or Android Studio).
3. If you encounter plugin or symlink issues on Windows, ensure **Developer Mode** is turned on in your Windows Settings, and direct your Pub Cache to the same drive as your project (e.g. `setx PUB_CACHE "D:\PubCache"`).
4. Run standard flutter setup commands:
   ```bash
   flutter clean
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

### Preparing for Google Play Store Release (App Bundle)

This project has already been configured to build an `.aab` file!

1. Ensure your `android/app/upload-keystore.jks` and `android/key.properties` variables exist.
2. Run the release build command:
   ```bash
   flutter build appbundle
   ```
3. Locate your file in: `build\app\outputs\bundle\release\app-release.aab`
4. Upload directly to the Google Play Console!

---
*Built with ❤️ in Flutter!*
