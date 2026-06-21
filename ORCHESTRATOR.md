# tesseractR — Build Orchestrator

## Purpose

This is the **master orchestrator** for scaffolding and finishing the
`tesseractR` R package: four-dimensional tic-tac-toe on a `4×4×4×4`
hypercube, with a game engine, a heuristic AI opponent, ggplot2
visualization, and a Shiny app.

You (Claude Code) execute the build by running the **stack prompt
files** in dependency order, updating `STATE.md` after each, and
finishing with the audit-refine loop. Treat each stack file as a
self-contained work order. Do not skip ahead of the dependency graph.

------------------------------------------------------------------------

## Package Identity (single source of truth)

| Field | Value |
|----|----|
| Package | `tesseractR` |
| Prefix | `tsr_` |
| S3 class | `ttt_board` |
| Org/repo | `r-heller/tesseractR` |
| pkgdown | `https://r-heller.github.io/tesseractR/` |
| Author | Raban Heller · `raban.heller@charite.de` · ORCID `0000-0001-8006-9742` |
| License | `MIT + file LICENSE` |
| Target | CRAN · pure R · no compiled code · S3 only |

This package is an independent `r-heller` CRAN package — **not** part of
the analysis/visualization/bioinformatics suite. It shares the suite’s
engineering discipline but none of its domain dependencies.

------------------------------------------------------------------------

## Stack Files & Dependency Graph

                             ┌─────────────────────────┐
                             │  S0_FOUNDATION           │  package skeleton, DESCRIPTION,
                             │  (no deps)               │  zzz.R cache, package docs
                             └───────────┬─────────────┘
                                         │
                             ┌───────────▼─────────────┐
                             │  S1_GEOMETRY             │  index mapping, 272 win lines,
                             │  (needs S0)              │  caching
                             └───────────┬─────────────┘
                                         │
                             ┌───────────▼─────────────┐
                             │  S2_ENGINE               │  ttt_board class, moves, undo,
                             │  (needs S1)              │  legal moves, win/draw status
                             └─────┬──────────────┬────┘
                                   │              │
                  ┌────────────────▼───┐   ┌──────▼──────────────────┐
                  │  S3_AI + EVAL      │   │  S4_VISUALIZATION        │
                  │  (needs S2)        │   │  (needs S2)              │
                  │  negamax, eval,    │   │  tsr_plot, slice, cube   │
                  │  win_prob, rate    │   │  spec, print methods     │
                  └──┬──────────┬──────┘   └──────┬──────────────────┘
                     │          │                 │
          ┌──────────▼──┐  ┌────▼─────────┐       │
          │ S6_SIMULATE │  │ S7_ANALYSIS  │       │
          │ (needs S3)  │  │ (needs S3)   │       │
          │ self-play,  │  │ game analysis│       │
          │ opening stat│  │ behavior     │       │
          │ calibration │  │ analytics    │       │
          └──────────┬──┘  └────┬─────────┘       │
                     │          │                 │
                     └────┬─────┴─────────────────┘
                          │  (S5 needs S3, S4, S6, S7)
                  ┌───────▼─────────────────┐
                  │  S5_APP_SUBMISSION       │  Shiny app w/ real-time eval +
                  │  (needs S3,S4,S6,S7)     │  analysis panel, vignettes, README,
                  │                          │  pkgdown, NEWS
                  └───────────┬─────────────┘
                              │
                  ┌───────────▼─────────────┐
                  │  AUDIT_REFINE_LOOP       │  R CMD check --as-cran → 0/0/0
                  │  (needs all)             │  iterate until clean
                  └─────────────────────────┘

### Runnable set logic

A stack is **runnable** when every stack it depends on has status `DONE`
in `STATE.md`.

- Start: only `S0_FOUNDATION` is runnable.
- After S0 DONE → `S1_GEOMETRY`.
- After S1 DONE → `S2_ENGINE`.
- After S2 DONE → **both** `S3_AI` and `S4_VISUALIZATION` become
  runnable (independent).
- After S3 DONE → **both** `S6_SIMULATION` and `S7_ANALYSIS` become
  runnable (both need the eval core; independent of each other and of
  S4).
- After S3, S4, S6, **and** S7 DONE → `S5_APP_SUBMISSION` (the app’s
  real-time eval needs S3, its views need S4, its analysis panel needs
  S6+S7).
- After S5 DONE → `AUDIT_REFINE_LOOP`.
- Loop exits clean → package is submission-ready.

Parallelization: after S2, S4 can run alongside S3. After S3, S6 and S7
can run alongside S4 and each other — up to three independent sessions
in flight (S4, S6, S7).

------------------------------------------------------------------------

## Execution Protocol

For each stack, in dependency order:

1.  **Read** `STATE.md`. Identify the runnable set. Pick the next stack.
2.  **Read** the stack’s md file completely before writing any code.
3.  **Execute** every task in the stack file. Implement real working
    code — no stubs, no `TODO`.
4.  **Self-check** against the stack’s “Done when” criteria at the
    bottom of its file.
5.  **Run**
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
    then
    [`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html)
    to confirm the package still loads.
6.  **Update** `STATE.md`: set the stack to `DONE`, record date, note
    any deviations or known issues, recompute the runnable set.
7.  **Commit & push** (see Git Workflow below): stage the stack’s files,
    commit under Raban’s identity with the `<stack-id>:` message format,
    push `build/tesseractR` to `origin`.
8.  **Stop and report** which stack finished, the commit hash, and what
    is now runnable, then proceed to the next runnable stack.

Do **not** run the full `R CMD check` after every stack — that is the
job of the final audit-refine loop. After each stack, `load_all()` + the
stack’s own tests is enough.

------------------------------------------------------------------------

## Git Workflow & Authorship (apply after every stack)

### Authorship — non-negotiable

Every commit is authored **solely by Raban Heller**. Derive the identity
from `DESCRIPTION`: - `user.name = "Raban Heller"`,
`user.email = "raban.heller@charite.de"`. - **No**
`Co-Authored-By: Claude` (or any AI) trailer. **No** “Generated with
Claude Code” line. **No** AI attribution anywhere in commit messages,
code comments, `DESCRIPTION`, `NEWS.md`, or `man/` pages. The author of
this package is Raban, full stop. - Before the first commit, set
identity explicitly:
`bash git config user.name "Raban Heller" git config user.email "raban.heller@charite.de"` -
If any commit template or hook injects an AI trailer, strip it. Verify
with `git log --format='%an <%ae>%n%b'` that no AI co-author appears.

### Branch & push policy

The suite rule is **branch-only — no direct commits to `main`, no
force-push.** This roadmap honors it while still committing and pushing
after every stack:

- Work on a dedicated branch **`build/tesseractR`** (create it off
  `main` at the start of S0).
- **After each stack completes** (tests green, `load_all()` clean,
  STATE.md updated):
  1.  Stage the stack’s files.
  2.  Commit with a clear message (format below).
  3.  **Push** `build/tesseractR` to `origin`. This means every step is
      committed and pushed — nothing is lost, CI runs on each push — but
      `main` stays clean and always-buildable.
- **`main` is updated only once**, at the very end: after
  `AUDIT_REFINE_LOOP` reports `R CMD check --as-cran` = 0/0/0, open a PR
  from `build/tesseractR` → `main`. The merge to `main` requires
  **Raban’s explicit approval** — do not self-merge. Never force-push.

### Commit message format (per stack)

    <stack-id>: <concise summary>

    <1–3 lines on what was implemented/changed>

Example:

    S2: implement ttt_board class, moves, undo, and status accessors

    Immutable board operations, type-stable legal-move generation,
    win/draw detection over the cached 272-line table.

No issue-closing magic words unless Raban asks. No AI references.

### If a push or merge is blocked

If `origin` is unreachable, the branch is protected in a way that blocks
the push, or auth fails: **stop and report** rather than working around
it. Do not switch to `main`, do not force-push, do not rewrite history.
Surface the blocker and wait.

------------------------------------------------------------------------

## Suite Conventions (apply in every stack)

1.  **S3 only.** Class `ttt_board`. Constructor/validator/helper
    pattern.
2.  **Plot functions return `ggplot` objects.** Never render in place.
3.  **`cli` + `rlang`** for all messaging; propagate
    `call = rlang::caller_env()`.
4.  **`vapply`** over `sapply`; **`TRUE`/`FALSE`** never `T`/`F`.
5.  **No
    [`library()`](https://rdrr.io/r/base/library.html)/[`require()`](https://rdrr.io/r/base/library.html)**
    anywhere, including `app.R`.
6.  **No writes outside
    [`tempdir()`](https://rdrr.io/r/base/tempfile.html)**; no
    [`setwd()`](https://rdrr.io/r/base/getwd.html), no hardcoded paths.
7.  **`seq_along`/`seq_len`**,
    **[`inherits()`](https://rdrr.io/r/base/class.html)**.
8.  **Type stability** — empty results are typed-empty (length-0 vector
    / 0-row tibble), never `NULL`.
9.  **Immutable board** —
    [`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md)
    returns a new board, never mutates.
10. **Win lines cached in an internal environment, never on disk.**
11. Never hand-edit `NAMESPACE` or `man/*.Rd`.
12. Definition of done = `R CMD check --as-cran` → 0 errors / 0 warnings
    / 0 notes (modulo “New submission”).

------------------------------------------------------------------------

## Files in this workflow

    .claude/workflows/
      ORCHESTRATOR.md          ← this file
      STATE.md                 ← live progress tracker (update after every stack)
      S0_FOUNDATION.md
      S1_GEOMETRY.md
      S2_ENGINE.md
      S3_AI.md                 ← AI + evaluation/win-prob/rate-moves core
      S4_VISUALIZATION.md
      S6_SIMULATION.md         ← self-play, opening stats, calibration data
      S7_ANALYSIS.md           ← game analysis + play-behavior analytics
      S5_APP_SUBMISSION.md     ← runs after S3/S4/S6/S7
      AUDIT_REFINE_LOOP.md

Begin by reading `STATE.md`, then execute `S0_FOUNDATION.md`.
