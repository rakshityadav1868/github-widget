"use client";

import { motion } from "framer-motion";
import Logo from "./Logo";

const GRID_LEVELS = [
  1, 0, 2, 3, 1, 0, 4, 2, 1, 3, 2, 1, 0, 2, 4, 1, 0, 3, 2, 1, 0, 2, 1, 3, 4, 2,
  0, 1, 3, 2, 1, 4, 0, 2, 3, 1, 2, 0, 1, 3, 2, 4, 1, 0, 2, 3, 1, 0, 4, 2, 1, 3,
  0, 2, 1, 4, 3, 2, 0, 1,
];

const LEVEL_COLORS = ["#1b1f24", "#0e4429", "#196c2e", "#26a641", "#3fb950"];
const COLUMNS = 10;

function AnimatedGrid() {
  return (
    <div className="grid flex-1 grid-cols-10 gap-1">
      {GRID_LEVELS.map((level, i) => {
        const col = i % COLUMNS;
        const row = Math.floor(i / COLUMNS);
        return (
          <motion.div
            key={i}
            className="aspect-square rounded-[3px]"
            style={{ background: LEVEL_COLORS[level] }}
            initial={{ opacity: 0, scale: 0.3 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{
              duration: 0.35,
              delay: 0.5 + col * 0.05 + row * 0.02,
              ease: [0.34, 1.56, 0.64, 1],
            }}
          />
        );
      })}
    </div>
  );
}

function WidgetCard() {
  return (
    <motion.div
      className="w-full rounded-[28px] bg-[#0d0d0d] p-4 shadow-[0_10px_24px_rgba(0,0,0,0.45)]"
      initial={{ opacity: 0, y: 16, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ duration: 0.5, delay: 0.2, ease: "easeOut" }}
    >
      <div className="mb-3 flex items-center gap-2">
        <Logo className="h-5 w-5" />
      </div>
      <div className="flex items-center gap-4">
        <div className="flex-shrink-0">
          <p className="text-3xl font-bold leading-none text-white">23</p>
          <p className="mt-1 text-xs text-zinc-400">day streak</p>
          <p className="mt-3 text-2xl font-bold leading-none text-[#3fb950]">
            148
          </p>
          <p className="mt-1 text-xs text-zinc-400">PRs merged</p>
        </div>
        <AnimatedGrid />
      </div>
    </motion.div>
  );
}

function StatusBar() {
  return (
    <div className="flex w-full items-center justify-between px-7 pt-3 text-[13px] font-medium text-zinc-200">
      <span>9:41</span>
      <div className="flex items-center gap-1">
        <svg width="16" height="11" viewBox="0 0 16 11" fill="none">
          <rect x="0" y="7" width="2.5" height="4" rx="0.5" fill="currentColor" />
          <rect x="4" y="5" width="2.5" height="6" rx="0.5" fill="currentColor" />
          <rect x="8" y="3" width="2.5" height="8" rx="0.5" fill="currentColor" />
          <rect x="12" y="0" width="2.5" height="11" rx="0.5" fill="currentColor" />
        </svg>
        <svg width="15" height="11" viewBox="0 0 15 11" fill="none">
          <path
            d="M7.5 10.5C4.7 10.5 2.2 9.3 0.4 7.4C0.1 7.1 0.1 6.6 0.4 6.3C2.5 4.1 5.3 2.8 7.5 2.8C9.7 2.8 12.5 4.1 14.6 6.3C14.9 6.6 14.9 7.1 14.6 7.4C12.8 9.3 10.3 10.5 7.5 10.5Z"
            fill="currentColor"
          />
        </svg>
        <div className="ml-0.5 h-[11px] w-[24px] rounded-[3px] border border-zinc-200 p-[1.5px]">
          <div className="h-full w-4/5 rounded-[1.5px] bg-zinc-200" />
        </div>
      </div>
    </div>
  );
}

export default function PhoneMockup() {
  return (
    <motion.div
      className="relative mx-auto h-[420px] w-[280px]"
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, ease: "easeOut" }}
    >
      <motion.div
        className="h-full w-full rounded-[44px] border-[8px] border-zinc-800 bg-black shadow-2xl"
        animate={{ y: [0, -10, 0] }}
        transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
      >
        <div className="absolute left-1/2 top-0 z-10 h-6 w-28 -translate-x-1/2 rounded-b-2xl bg-zinc-800" />
        <div
          className="flex h-full flex-col items-center gap-8 overflow-hidden rounded-[36px] px-4 pb-10"
          style={{
            background:
              "radial-gradient(120% 90% at 50% 0%, #1c2b22 0%, #0a0c0a 55%, #050505 100%)",
          }}
        >
          <StatusBar />
          <WidgetCard />
        </div>
      </motion.div>
    </motion.div>
  );
}
