export default function Logo({
  className = "h-8 w-8",
  tile = false,
}: {
  className?: string;
  /** Render on a solid dark tile (for app-icon contexts). Off by default so the
   * mark sits directly on the page background instead of a near-invisible square. */
  tile?: boolean;
}) {
  return (
    <svg
      viewBox="0 0 1024 1024"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      role="img"
      aria-label="Forge"
    >
      {tile && <rect width="1024" height="1024" rx="220" fill="#0D0D0D" />}
      <path
        d="M512,713 C338.5,629.3 322.8,461.7 448.8,310.9 C472.6,405.9 575.2,405.9 559.3,310.9 C701.2,444.9 669.7,612.6 512,713 Z"
        fill="#F5F5F5"
      />
      <circle cx="512" cy="283" r="50" fill="#3FB950" />
    </svg>
  );
}
