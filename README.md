# GreenLeaf — Updated Flutter Android test build

This project packages **the exact updated HTML file you supplied** (`greenleaf_mobile_lime_delivery_tick.html`) inside a real Flutter Android application using `webview_flutter`.

The entire HTML prototype is included unmodified in `assets/index.html`, with all styles, SVGs, interactive JavaScript, campaigns, contacts, conversations, Billing, green header, lime delivery indicators, and Android-appropriate UI. No internet connection is needed to display the prototype, although GitHub needs internet access to download Flutter and build dependencies.

## What this IS (and isn't)

- **Is:** A Flutter app that you can compile into a standard Android debug APK and install on a Samsung Galaxy S25.
- **Is:** Your original HTML/CSS/JavaScript UI, rendered by Android System WebView inside Flutter. No redesign or missing tabs.
- **Isn't:** A rewrite of every screen into native Flutter widgets. A full native rewrite would be a separate project.
- **Isn't:** Connected to live GreenLeaf WhatsApp, Meta Ads, payment processing, PHP/MySQL API, or your customer records. Your HTML uses sample data; chat replies are preview-only.
- **Isn't:** An APK inside this ZIP. GitHub Actions builds the actual `app-debug.apk`.

## Upload to your existing GitHub repository

Your existing repo is `Lasar456/android` and already has a working GitHub Actions workflow. Follow these steps:

1. Download and extract this ZIP on Windows.
2. In GitHub, open `https://github.com/Lasar456/android` and choose **Code** → **Add file** → **Upload files**.
3. Upload the **extracted** folders `assets` and `lib`, the file `pubspec.yaml`, and optionally `branding`. Allow replacement of any existing files of the same names.
4. For this updated build workflow, update `.github/workflows/main.yml` through GitHub's editor by replacing its contents with the same file in this ZIP. **The old working workflow can also compile the new app without this step.** The hidden dot folder `.github` may be hard to find in some Windows dialogs; you do not need to upload it to update the app design.
5. Click **Commit changes** on the `main` branch.
6. Open the **Actions** tab → select **Build GreenLeaf Android APK** → open the latest successful green run.
7. Scroll to **Artifacts** and download **GreenLeaf-Android-APK** (a ZIP of compiled output).
8. Extract that artifact, then transfer `app-debug.apk` to the Samsung Galaxy S25 and install it.

### On a brand-new empty repo

Upload **all** extracted source files and folders including `.github`. If GitHub won't upload the hidden `.github` folder, manually create `.github/workflows/main.yml` via GitHub's web editor and paste in the contents from this project.

## Project structure

```
assets/index.html             Your unchanged 103 KB UI source
lib/main.dart                 Flutter Android shell and Android Back integration
pubspec.yaml                 Flutter SDK/dependencies/assets
.github/workflows/main.yml   Automatic debug APK build
branding/android/            Optional app launcher icon in five densities
```

## Requirements

- GitHub Actions runner with internet during build (Flutter downloaded by CI)
- Stable Flutter SDK
- Java 17
- `webview_flutter` as defined in pubspec.yaml

## Android Back handling

Back closes the preview modal, closes a conversation, returns from Billing to More, and from other pages to Home. At Home, Back exits. This Android behavior does not change any of the HTML's own click handlers.
