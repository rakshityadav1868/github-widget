"use client";

import { motion } from "framer-motion";
import PhoneMockup from "./components/PhoneMockup";
import Logo from "./components/Logo";

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

export default function Home() {
  return (
    <div className="flex flex-1 flex-col items-center">
      <motion.header
        initial={{ opacity: 0, y: -12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="flex w-full max-w-5xl items-center justify-between px-6 py-6"
      >
        <Logo className="h-9 w-9" />
        <a
          href="https://github.com/rakshityadav1868/github-widget"
          className="text-sm text-zinc-400 hover:text-zinc-200"
        >
          GitHub
        </a>
      </motion.header>

      <main className="flex w-full max-w-5xl flex-1 flex-col items-center px-6">
        <section className="flex w-full flex-col items-center gap-10 py-12 text-center md:flex-row md:gap-16 md:py-24 md:text-left">
          <motion.div
            className="flex flex-col items-center gap-6 md:items-start"
            initial="hidden"
            animate="show"
            variants={{
              hidden: {},
              show: { transition: { staggerChildren: 0.12 } },
            }}
          >
            <motion.h1
              variants={{
                hidden: { opacity: 0, y: 20 },
                show: { opacity: 1, y: 0 },
              }}
              transition={{ duration: 0.5, ease: "easeOut" }}
              className="max-w-md text-4xl font-semibold leading-tight tracking-tight text-zinc-50 md:text-5xl"
            >
              Your GitHub stats, one glance away
            </motion.h1>
            <motion.p
              variants={{
                hidden: { opacity: 0, y: 20 },
                show: { opacity: 1, y: 0 },
              }}
              transition={{ duration: 0.5, ease: "easeOut" }}
              className="max-w-sm text-base leading-7 text-zinc-400"
            >
              A home-screen widget that shows your real contributions,
              streak, and merged PRs — dark or light, always up to date.
            </motion.p>
            <motion.div
              variants={{
                hidden: { opacity: 0, y: 20 },
                show: { opacity: 1, y: 0 },
              }}
              transition={{ duration: 0.5, ease: "easeOut" }}
              className="flex flex-col gap-3 sm:flex-row"
            >
              <motion.a
                href="/downloads/forge.apk"
                download
                whileHover={{ scale: 1.04 }}
                whileTap={{ scale: 0.97 }}
                className="flex h-12 items-center justify-center rounded-full bg-zinc-50 px-6 text-sm font-medium text-zinc-900"
              >
                Download for Android
              </motion.a>
              <span className="flex h-12 cursor-not-allowed items-center justify-center rounded-full border border-zinc-700 px-6 text-sm font-medium text-zinc-500">
                Download for iOS — coming soon
              </span>
            </motion.div>
            <motion.p
              variants={{
                hidden: { opacity: 0, y: 20 },
                show: { opacity: 1, y: 0 },
              }}
              transition={{ duration: 0.5, ease: "easeOut" }}
              className="text-xs text-zinc-500"
            >
              Free. No account fees. Sign in with GitHub.
            </motion.p>
          </motion.div>
          <div className="flex-shrink-0">
            <PhoneMockup />
          </div>
        </section>

        <section className="grid w-full grid-cols-1 gap-4 py-12 sm:grid-cols-2 md:py-20">
          {FEATURES.map((feature, i) => (
            <motion.div
              key={feature.title}
              className="rounded-2xl border border-zinc-800 bg-zinc-900/40 p-6"
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-80px" }}
              transition={{ duration: 0.5, delay: i * 0.08, ease: "easeOut" }}
              whileHover={{ y: -4, borderColor: "#3f3f46" }}
            >
              <h3 className="text-base font-medium text-zinc-100">
                {feature.title}
              </h3>
              <p className="mt-2 text-sm leading-6 text-zinc-400">
                {feature.body}
              </p>
            </motion.div>
          ))}
        </section>
      </main>

      <footer className="w-full max-w-5xl px-6 py-8 text-center text-xs text-zinc-600 md:text-left">
        Forge is an independent project and isn&apos;t affiliated with GitHub.
      </footer>
    </div>
  );
}
