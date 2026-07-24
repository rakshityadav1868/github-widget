# Forge — Roadmap

A real home-screen widget app for **Android and iOS** that shows your live GitHub
stats — contribution grid, day streak, PRs merged, followers, stars — in a clean
dark/light design, with the contribution grid animating in.

## What it is

- A small **Flutter app** you install on your phone. Inside it you sign in with
  GitHub, pick dark/light, and choose what to show.
- A real **home-screen widget** (like the clock/weather widget) that shows your
  stats and refreshes on its own.
- An **in-app animated preview** screen where the green contribution grid pops in
  with a staggered animation.

Home-screen widgets must be written natively per platform (Android Glance,
iOS WidgetKit), so the app is Flutter and the widget faces are thin native
layers bridged by the `home_widget` package.

## Design

Two themes, matching the reference:

- **Dark** — near-black card (`#0d0d0d`), green contribution grid on dark-slate
  empty cells (`#1b1f24`).
- **Light** — white card, green grid on `#ebedf0` empty cells.

Stat column on the left: a big number + label (e.g. `23 / day streak`), then a
second number in GitHub green (e.g. `148 / PRs merged`). Grid on the right.
The grid animates in with a staggered pop **inside the app**; on the actual home
screen the OS limits animation, so the widget shows the finished grid.

## Data

Real data from GitHub's official API (GraphQL `contributionsCollection` for the
grid + streak, REST for followers/stars). User signs in with GitHub (OAuth) so we
can show private contributions and real streaks. Data is cached on the phone and
refreshed every ~30–60 min (the OS controls widget refresh timing).

## Tech stack

| Layer | Choice |
|-------|--------|
| App | Flutter (one codebase → Android + iOS) |
| iOS widget | WidgetKit + SwiftUI |
| Android widget | Glance / RemoteViews |
| App ↔ widget bridge | `home_widget` package |
| Auth | GitHub OAuth |
| GitHub data | GraphQL + REST |

## Folder structure

```
lib/
  main.dart              app entry
  core/                  theme, constants, colors, utils
  data/
    models/              GitHubUser, ContributionDay, Stats
    services/            github_api, auth, cache
  features/
    onboarding/          sign in with GitHub
    preview/             in-app animated widget preview
    settings/            theme, which stats to show
  widgets/               shared UI pieces (contribution_grid, stat_tile)
android/                 native Android + home-screen widget (Glance)
ios/                     native iOS + WidgetKit extension
website/                 Next.js download page (Android APK, iOS coming soon)
```

## Milestones & PRs

Each feature ships as its own PR, merged into `main`.

- **PR #1** — Scaffold Flutter project, clean structure, docs *(this PR)*
- **PR #2** — GitHub data models + API service (real stats)
- **PR #3** — Sign in with GitHub (OAuth)
- **PR #4** — In-app animated widget preview (dark/light)
- **PR #5** — Android home-screen widget (Glance) — run on a real phone
- Later — iOS WidgetKit widget; optional free "Download APK" website (GitHub Pages)

## Cost

Building and running on your own Android phone is **free** — no store accounts.
Publishing later is optional (Play Store $25 one-time, App Store $99/yr).

## Running on a real Android phone (free)

1. Enable **Developer options** + **USB debugging** on the phone.
2. Connect via USB, accept the "allow debugging" prompt.
3. `flutter run` — the app installs and launches on the phone.
