export default function Home() {
  return (
    <div className="flex min-h-[100dvh] flex-col items-center justify-center bg-zinc-50 font-sans dark:bg-zinc-950">
      <main className="flex w-full max-w-3xl flex-1 flex-col items-center justify-center gap-12 px-6 py-24 sm:items-start">
        <div className="flex flex-col items-center gap-6 text-center sm:items-start sm:text-left">
          <h1 className="max-w-sm text-4xl font-semibold leading-tight tracking-tight text-zinc-950 dark:text-zinc-50 md:text-5xl">
            Starter ready.
          </h1>
          <p className="max-w-[65ch] text-base leading-[1.7] text-zinc-600 dark:text-zinc-400">
            Fill out{" "}
            <code className="rounded bg-zinc-100 px-1.5 py-0.5 text-sm font-medium text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
              PROJECT_BRIEF.md
            </code>{" "}
            then open Claude Code and start building. This page is meant to be
            replaced.
          </p>
        </div>
        <div className="flex flex-col gap-4 text-base font-medium sm:flex-row">
          <a
            className="flex h-12 w-full items-center justify-center gap-2 rounded-full bg-zinc-900 px-6 text-white transition-colors hover:bg-zinc-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-500 focus-visible:ring-offset-2 active:scale-[0.98] dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-300 dark:focus-visible:ring-zinc-400 sm:w-auto"
            href="https://nextjs.org/docs"
            target="_blank"
            rel="noopener noreferrer"
          >
            Read the docs
          </a>
          <a
            className="flex h-12 w-full items-center justify-center rounded-full border border-zinc-200 px-6 text-zinc-700 transition-colors hover:border-zinc-300 hover:bg-zinc-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-500 focus-visible:ring-offset-2 active:scale-[0.98] dark:border-zinc-700 dark:text-zinc-300 dark:hover:border-zinc-600 dark:hover:bg-zinc-800 dark:focus-visible:ring-zinc-400 sm:w-auto"
            href="https://github.com/mpcstudios/nextjs-starter"
            target="_blank"
            rel="noopener noreferrer"
          >
            View on GitHub
          </a>
        </div>
      </main>
    </div>
  );
}
