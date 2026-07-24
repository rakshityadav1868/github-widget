const GRID_LEVELS = [
  1, 0, 2, 3, 1, 0, 4, 2, 1, 3, 2, 1, 0, 2, 4, 1, 0, 3, 2, 1, 0, 2, 1, 3, 4, 2,
  0, 1, 3, 2, 1, 4, 0, 2, 3, 1, 2, 0, 1, 3, 2, 4, 1, 0, 2, 3, 1, 0, 4, 2, 1, 3,
  0, 2, 1, 4, 3, 2, 0, 1,
];

const LEVEL_COLORS = ["#1b1f24", "#0e4429", "#196c2e", "#26a641", "#3fb950"];

const FEATURES = [
  {
    title: "Real GitHub data",
    body: "Sign in with GitHub and see your actual contributions, streak, and merged PRs — not a placeholder.",
  },
  {
    title: "Light and dark",
    body: "Pick the mode you want. The widget you add to your home screen matches your choice.",
  },
  {
    title: "Home screen widget",
    body: "A real widget that sits on your Android home screen and refreshes on its own.",
  },
  {
    title: "Free, no account fees",
    body: "No subscription, no paywall. Sign in with GitHub and you're set.",
  },
];

function WidgetCardMockup() {
  return (
    <div className="w-full rounded-[28px] bg-[#0d0d0d] p-4 shadow-[0_10px_24px_rgba(0,0,0,0.35)]">
      <div className="flex items-center gap-4">
        <div className="flex-shrink-0">
          <p className="text-3xl font-bold leading-none text-white">23</p>
          <p className="mt-1 text-xs text-zinc-400">day streak</p>
          <p className="mt-3 text-2xl font-bold leading-none text-[#3fb950]">
            148
          </p>
          <p className="mt-1 text-xs text-zinc-400">PRs merged</p>
        </div>
        <div className="grid flex-1 grid-cols-10 gap-1">
          {GRID_LEVELS.map((level, i) => (
            <div
              key={i}
              className="aspect-square rounded-[3px]"
              style={{ background: LEVEL_COLORS[level] }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

function PhoneMockup() {
  return (
    <div className="relative mx-auto h-[420px] w-[280px] rounded-[44px] border-[8px] border-zinc-800 bg-black shadow-2xl">
      <div className="absolute left-1/2 top-0 z-10 h-6 w-28 -translate-x-1/2 rounded-b-2xl bg-zinc-800" />
      <div className="flex h-full flex-col items-center justify-center gap-6 overflow-hidden rounded-[36px] bg-zinc-950 px-4">
        <WidgetCardMockup />
      </div>
    </div>
  );
}

export default function Home() {
  return (
    <div className="flex flex-1 flex-col items-center">
      <header className="flex w-full max-w-5xl items-center justify-between px-6 py-6">
        <div className="flex items-center gap-2">
          <span className="inline-block h-3 w-3 rounded-full bg-[#3fb950]" />
          <span className="text-sm font-medium tracking-wide text-zinc-200">
            Forge
          </span>
        </div>
        <a
          href="https://github.com/rakshityadav1868/github-widget"
          className="text-sm text-zinc-400 hover:text-zinc-200"
        >
          GitHub
        </a>
      </header>

      <main className="flex w-full max-w-5xl flex-1 flex-col items-center px-6">
        <section className="flex w-full flex-col items-center gap-10 py-12 text-center md:flex-row md:gap-16 md:py-24 md:text-left">
          <div className="flex flex-col items-center gap-6 md:items-start">
            <h1 className="max-w-md text-4xl font-semibold leading-tight tracking-tight text-zinc-50 md:text-5xl">
              Your GitHub stats, one glance away
            </h1>
            <p className="max-w-sm text-base leading-7 text-zinc-400">
              A home-screen widget that shows your real contributions,
              streak, and merged PRs — dark or light, always up to date.
            </p>
            <div className="flex flex-col gap-3 sm:flex-row">
              <a
                href="/downloads/forge.apk"
                download
                className="flex h-12 items-center justify-center rounded-full bg-zinc-50 px-6 text-sm font-medium text-zinc-900 transition-colors hover:bg-white"
              >
                Download for Android
              </a>
              <span className="flex h-12 cursor-not-allowed items-center justify-center rounded-full border border-zinc-700 px-6 text-sm font-medium text-zinc-500">
                Download for iOS — coming soon
              </span>
            </div>
            <p className="text-xs text-zinc-500">
              Free. No account fees. Sign in with GitHub.
            </p>
          </div>
          <div className="flex-shrink-0">
            <PhoneMockup />
          </div>
        </section>

        <section className="grid w-full grid-cols-1 gap-4 py-12 sm:grid-cols-2 md:py-20">
          {FEATURES.map((feature) => (
            <div
              key={feature.title}
              className="rounded-2xl border border-zinc-800 bg-zinc-900/40 p-6"
            >
              <h3 className="text-base font-medium text-zinc-100">
                {feature.title}
              </h3>
              <p className="mt-2 text-sm leading-6 text-zinc-400">
                {feature.body}
              </p>
            </div>
          ))}
        </section>
      </main>

      <footer className="w-full max-w-5xl px-6 py-8 text-center text-xs text-zinc-600 md:text-left">
        Forge is an independent project and isn&apos;t affiliated with GitHub.
      </footer>
    </div>
  );
}
