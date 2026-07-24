# Forge — download website

The marketing/download page for Forge. Next.js (App Router) + Tailwind.

## Run locally

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
```

## Deploy

Free on [Vercel](https://vercel.com) — it's built for Next.js:

```bash
npx vercel
```

## Updating the Android download

The APK lives at `public/downloads/forge.apk` and is served as a direct
download from the "Download for Android" button. To ship a new build:

```bash
cd ..
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk website/public/downloads/forge.apk
```

Use `--release`, not `--debug` — debug builds are much larger (150MB+) and
risk exceeding GitHub's 100MB file-size limit. The release build here is
~46MB.

> Committing the APK to git means every new build adds to repo history. If
> that becomes a problem, switch to hosting the APK as a GitHub Release asset
> (or any static file host) and point the button's `href` there instead.

## iOS

The iOS button is a disabled "coming soon" placeholder — real iOS
distribution needs a paid Apple Developer account (TestFlight or the App
Store). Once that's set up, swap the placeholder for a real link.
