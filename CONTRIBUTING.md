# Contributing to Forge

Thanks for wanting to help build Forge — a home-screen widget app that shows
your live GitHub stats. This repo has three parts, and you'll usually only
need to touch one of them:

| Part | Path | Stack |
|---|---|---|
| Mobile app | `lib/`, `android/`, `ios/` | Flutter (Android Glance + iOS WidgetKit for the native widgets) |
| Auth backend | `server/` | Cloudflare Worker (exchanges GitHub OAuth code for a token) |
| Download website | `website/` | Next.js (App Router) + Tailwind, deployed to Vercel |

See [ROADMAP.md](ROADMAP.md) for architecture and planned work, and each
folder's own `README.md` for part-specific setup and deploy instructions.

## Getting set up

```bash
git clone https://github.com/rakshityadav1868/github-widget.git
cd github-widget
flutter pub get
```

Run the app on a connected Android device (USB debugging on):

```bash
flutter run
```

For the website:

```bash
cd website
npm install
npm run dev
```

For the auth backend, see [server/README.md](server/README.md) — you'll need
your own GitHub OAuth App and Cloudflare account to run it end to end, but
most contributions won't need to touch it.

## Before you open a PR

- `flutter analyze` and `flutter test` for Dart/Flutter changes.
- `npm run lint` and `npm run build` inside `website/` for website changes.
- Keep PRs focused — one feature or fix per PR is easier to review than a
  bundle of unrelated changes.
- Match the existing style: no unnecessary comments, no premature
  abstractions, straightforward code over clever code.
- If you're changing UI, include a screenshot or short screen recording in
  the PR description.

## Branching and commits

- Branch off `main`; open your PR against `main`.
- Write commit messages that explain *why*, not just *what*.
- Squash-merge is fine — a clean, descriptive PR title is enough.

## Reporting bugs / proposing features

Open a GitHub issue with:
- What you expected vs. what happened (for bugs), including device/OS if
  relevant.
- For feature proposals, a short description of the problem it solves —
  check [ROADMAP.md](ROADMAP.md) first in case it's already planned.

## License

By contributing, you agree your contributions will be licensed under the
project's [MIT License](LICENSE).
