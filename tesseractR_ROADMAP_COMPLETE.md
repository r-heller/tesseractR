# tesseractR — Complete Build Roadmap

> **Single-file bundle** of the full Claude Code workflow for the
> `tesseractR` package: four-dimensional tic-tac-toe on a 4x4x4x4
> hypercube. A game engine, heuristic AI opponent, an exported
> evaluation core (position scoring, calibrated win probability,
> best-next-move ratings), self-play simulation with opening statistics,
> game analysis and play-behavior analytics, ggplot2 + 3D plotly
> visualization, and a Shiny app with real-time move evaluation and an
> analysis panel.
>
> Independent `r-heller` CRAN package - pure R, S3 only, no compiled
> code. Not part of the analysis/visualization/bioinformatics suite.
>
> Git: commit + push per stack on `build/tesseractR`; main only via
> approved PR after a clean audit loop. Every commit authored by Raban
> Heller - no AI attribution anywhere.
>
> **How to use:** This is the assembled reference. For actual Claude
> Code execution, split the sections back into `.claude/workflows/` as
> separate files (the orchestrator reads `STATE.md` and runs each stack
> file). The bundle is for reading the whole plan top-to-bottom.

## Build order & contents

1.  **ORCHESTRATOR** - identity, dependency graph, runnable-set logic,
    execution protocol, git/authorship
2.  **STATE** - live progress tracker, function registry, decisions on
    file
3.  **S0 - Foundation** - skeleton, DESCRIPTION, cache env, package
    docs, git branch setup
4.  **S1 - Geometry** - index mapping, 272 win lines, caching (needs S0)
5.  **S2 - Engine** - ttt_board class, moves, undo, win/draw status
    (needs S1)
6.  **S3 - AI & Evaluation** - negamax + alpha-beta; exported
    tsr_evaluate / tsr_win_prob / tsr_rate_moves (needs S2)
7.  **S4 - Visualization** - tsr_plot full board, tsr_plot_slice 2D, 3D
    plotly cube spec, print methods (needs S2)
8.  **S6 - Simulation** - self-play, opening stats, win-prob calibration
    data (needs S3)
9.  **S7 - Analysis** - move-by-move game analysis, turning points,
    play-behavior analytics (needs S3)
10. **S5 - App & Submission** - Shiny app (real-time eval + analysis
    panel), 2 vignettes, README, pkgdown, NEWS (needs S3+S4+S6+S7)
11. **AUDIT - Refine Loop** - R CMD check –as-cran to 0/0/0, authorship
    audit, PR to main (needs all)

Dependency forks: after **S2**, S3 and S4 run independently. After
**S3**, S6 and S7 become runnable and join S4 - up to three parallel
sessions (S4, S6, S7). All of S3/S4/S6/S7 must finish before **S5**.

The evaluation core (S3) is the single source of truth: AI, simulation,
analysis, and the app’s real-time rating all call the same tsr_evaluate
/ tsr_win_prob / tsr_rate_moves.

Visualization layers: static ggplot is the exported CRAN surface; the
rotatable 3D plotly cube is app-only. 3D is inspect-only - moves are
always made in the 2D full board.

------------------------------------------------------------------------

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

------------------------------------------------------------------------

# tesseractR — Build State

> Live progress tracker. Update after **every** stack: set status, date,
> notes, and recompute the runnable set. The orchestrator reads this
> file first.

Last updated: *(not started)*

------------------------------------------------------------------------

## Stack Status

| Stack | Depends on | Status | Date | Notes |
|----|----|----|----|----|
| S0_FOUNDATION | — | TODO |  |  |
| S1_GEOMETRY | S0 | BLOCKED |  |  |
| S2_ENGINE | S1 | BLOCKED |  |  |
| S3_AI | S2 | BLOCKED |  | AI + evaluation/win-prob/rate core |
| S4_VISUALIZATION | S2 | BLOCKED |  |  |
| S6_SIMULATION | S3 | BLOCKED |  | self-play, opening stats, calibration |
| S7_ANALYSIS | S3 | BLOCKED |  | game analysis + behavior analytics |
| S5_APP_SUBMISSION | S3, S4, S6, S7 | BLOCKED |  | real-time eval + analysis panel |
| AUDIT_REFINE_LOOP | all | BLOCKED |  |  |

Status values: `TODO` (runnable now) · `BLOCKED` (deps not done) ·
`IN_PROGRESS` · `DONE`

------------------------------------------------------------------------

## Runnable Set (recompute after each update)

**Currently runnable:** `S0_FOUNDATION`

Rule: a stack becomes runnable when all stacks in its “Depends on”
column are `DONE`. - S0 done → S1 runnable - S1 done → S2 runnable - S2
done → S3 **and** S4 runnable (independent) - S3 done → S6 **and** S7
runnable (both need the eval core; independent) - S3 + S4 + S6 + S7 done
→ S5 runnable - S5 done → AUDIT_REFINE_LOOP runnable

Up to three parallel sessions possible after S3: S4, S6, S7 in flight
together.

------------------------------------------------------------------------

## Exported Function Registry (fill in as stacks complete)

Track every exported function here so the audit loop can verify pkgdown
coverage and NEWS completeness. Internal helpers (`.tsr_*`) are not
listed.

| Function | Stack | Class/kind | Tested | Documented |
|----|----|----|----|----|
| [`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md) | S2 | constructor helper |  |  |
| [`is_ttt_board()`](https://r-heller.github.io/tesseractR/reference/is_ttt_board.md) | S2 | predicate |  |  |
| [`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md) | S2 | engine |  |  |
| [`tsr_undo()`](https://r-heller.github.io/tesseractR/reference/tsr_undo.md) | S2 | engine |  |  |
| [`tsr_legal_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_legal_moves.md) | S2 | engine |  |  |
| [`tsr_check_win()`](https://r-heller.github.io/tesseractR/reference/tsr_check_win.md) | S2 | status |  |  |
| [`tsr_winning_line()`](https://r-heller.github.io/tesseractR/reference/tsr_winning_line.md) | S2 | status |  |  |
| [`tsr_is_full()`](https://r-heller.github.io/tesseractR/reference/tsr_is_full.md) | S2 | status |  |  |
| [`tsr_status()`](https://r-heller.github.io/tesseractR/reference/tsr_status.md) | S2 | status |  |  |
| [`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md) | S3 | AI |  |  |
| [`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md) | S3 | evaluation |  |  |
| [`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md) | S3 | evaluation |  |  |
| [`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md) | S3 | evaluation |  |  |
| [`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md) | S6 | simulation |  |  |
| [`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md) | S6 | simulation |  |  |
| [`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md) | S6 | simulation |  |  |
| [`print.tsr_game()`](https://r-heller.github.io/tesseractR/reference/print.tsr_game.md) | S6 | S3 method |  |  |
| [`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md) | S7 | analysis |  |  |
| [`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md) | S7 | analysis |  |  |
| [`tsr_game_summary()`](https://r-heller.github.io/tesseractR/reference/tsr_game_summary.md) | S7 | analysis |  |  |
| [`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md) | S7 | analysis |  |  |
| [`tsr_compare_profiles()`](https://r-heller.github.io/tesseractR/reference/tsr_compare_profiles.md) | S7 | analysis |  |  |
| [`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md) | S7 | analysis (viz) |  |  |
| [`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md) | S4 | viz |  |  |
| [`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md) | S4 | viz |  |  |
| [`autoplot.ttt_board()`](https://r-heller.github.io/tesseractR/reference/autoplot.ttt_board.md) | S4 | viz (S3 method) |  |  |
| [`print.ttt_board()`](https://r-heller.github.io/tesseractR/reference/ttt_board-methods.md) | S4 | S3 method |  |  |
| [`format.ttt_board()`](https://r-heller.github.io/tesseractR/reference/ttt_board-methods.md) | S4 | S3 method |  |  |
| [`summary.ttt_board()`](https://r-heller.github.io/tesseractR/reference/ttt_board-methods.md) | S4 | S3 method |  |  |
| [`tsr_run_app()`](https://r-heller.github.io/tesseractR/reference/tsr_run_app.md) | S5 | app launcher |  |  |

------------------------------------------------------------------------

## Known Issues / Deviations Log

*(Record anything that deviates from the stack spec, any deferred work,
or any performance limitation discovered during the build. The audit
loop reads this.)*

- *(none yet)*

------------------------------------------------------------------------

## Decisions on file

- Variant: **simple 4D** (static `4×4×4×4`, 256 cells, 4-in-a-row). NOT
  the 5D multiverse variant.
- AI: **in scope** (negamax + alpha-beta, depth = difficulty).
- Evaluation core: **exported** (`tsr_evaluate`, `tsr_win_prob`,
  `tsr_rate_moves`) as single source of truth feeding AI, simulation,
  analysis, and the app’s real-time rating.
- Win probability: **A+B** — calibrated heuristic (logistic, default,
  real-time) AND optional Monte-Carlo rollout (offline accuracy).
  Calibration coefficients fitted in S6, stored as internal data,
  consumed by S3 with provisional fallback.
- Simulation + game analysis + play-behavior analytics: **in scope**
  (S6, S7) — positions `tesseractR` as an analysis tool, not just a
  playable board.
- Compiled code: **out of scope** (pure R; Rcpp is a future option,
  flagged as a perf ceiling on the simulation/search hot paths).
- Codecov + hex sticker: handled by **separate suite prompts**, not this
  roadmap.
- Git: commit + push **per stack** on branch `build/tesseractR`; **main
  only via approved PR** after the audit loop is clean (honors the suite
  branch-only / no-force-push policy).
- Authorship: every commit by **Raban Heller**
  (`raban.heller@charite.de`, ORCID 0000-0001-8006-9742). **No AI
  co-author trailers or attribution** anywhere — commits, code, docs,
  DESCRIPTION, NEWS.

------------------------------------------------------------------------

# S0 — Foundation

**Depends on:** nothing · **Unlocks:** S1_GEOMETRY

Lay down the package skeleton so every later stack has a place to write
code. No game logic yet — just the scaffold, metadata, the internal
cache environment, and package-level documentation.

------------------------------------------------------------------------

## Tasks

### 0.1 — Create the package skeleton

Initialize the package in the current working directory with this
structure (create empty files where a later stack fills them):

    tesseractR/
      DESCRIPTION
      NAMESPACE              # generated — leave roxygen to create it
      LICENSE
      LICENSE.md
      R/
        tesseractR-package.R
        zzz.R
      tests/
        testthat.R
        testthat/
          helper.R
      .Rbuildignore
      .gitignore

Use
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
if convenient, but the DESCRIPTION below overrides any generated one.

### 0.1b — Git identity & build branch

Set authorship and create the working branch **before the first commit**
(full policy in the orchestrator’s Git Workflow section):

``` bash
git config user.name  "Raban Heller"
git config user.email "raban.heller@charite.de"
git checkout -b build/tesseractR    # branch off main; never commit to main directly
```

All stack commits land on `build/tesseractR`. No AI co-author trailers,
ever. `main` is touched only at the end via an approved PR after the
audit loop is clean.

### 0.2 — DESCRIPTION

Write exactly:

    Package: tesseractR
    Title: Four-Dimensional Tic-Tac-Toe with a Heuristic AI Opponent
    Version: 0.1.0
    Authors@R:
        person("Raban", "Heller", email = "raban.heller@charite.de",
               role = c("aut", "cre"), comment = c(ORCID = "0000-0001-8006-9742"))
    Description: Play four-dimensional tic-tac-toe on a four-by-four-by-four-by-four
        hypercube, where the first player to align four marks along any straight line
        in four-dimensional space wins. Provides a game engine with legal-move
        generation and win detection across all 272 winning lines, a depth-limited
        negamax artificial-intelligence opponent with adjustable difficulty, 'ggplot2'
        visualization of the hypercube as a grid of boards, and an interactive 'shiny'
        application for play.
    License: MIT + file LICENSE
    URL: https://github.com/r-heller/tesseractR, https://r-heller.github.io/tesseractR/
    BugReports: https://github.com/r-heller/tesseractR/issues
    Encoding: UTF-8
    Roxygen: list(markdown = TRUE)
    RoxygenNote: 7.3.2
    Depends: R (>= 4.1.0)
    Imports:
        cli,
        ggplot2,
        rlang,
        tibble
    Suggests:
        shiny,
        bslib,
        plotly,
        knitr,
        rmarkdown,
        testthat (>= 3.0.0),
        withr,
        covr,
        pkgdown
    Config/testthat/edition: 3
    VignetteBuilder: knitr

`shiny`/`bslib`/`plotly` stay in **Suggests** — the engine must load and
run with none of them installed.

### 0.3 — License files

- `LICENSE` (the two-line MIT CRAN form):

      YEAR: 2026
      COPYRIGHT HOLDER: Raban Heller

- `LICENSE.md` — full MIT text.

### 0.4 — Package-level docs (`R/tesseractR-package.R`)

``` r

#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data %||%
NULL
```

### 0.5 — Internal cache environment (`R/zzz.R`)

Create a package-level internal environment for caching the win-line
table (filled lazily in S1). Do **not** populate it on load.

``` r

# Internal cache for computed win lines. Populated lazily by .tsr_win_lines().
.tsr_cache <- new.env(parent = emptyenv())
```

No `.onLoad`/`.onAttach` message — keep startup silent. (An empty
`.onLoad` is fine if a later stack needs it, but add nothing
user-facing.)

### 0.6 — testthat plumbing

- `tests/testthat.R`:

  ``` r

  library(testthat)
  library(tesseractR)
  test_check("tesseractR")
  ```

- `tests/testthat/helper.R` — leave a header comment; S2 fills in
  `example_board()`.

### 0.7 — Ignore files

- `.Rbuildignore` (escaped regex, one per line):

      ^tesseractR\.Rproj$
      ^\.Rproj\.user$
      ^_pkgdown\.ya?ml$
      ^docs$
      ^pkgdown$
      ^README\.Rmd$
      ^\.github$
      ^LICENSE\.md$
      ^.*\.svg$
      ^_build\.R$
      ^cran-comments\.md$
      ^\.claude$
      ^codecov\.yml$

- `.gitignore`:

      .Rproj.user
      .Rhistory
      .RData
      .Ruserdata
      .DS_Store
      docs/
      inst/doc/
      _build.R
      .claude/

### 0.8 — Verify

Run
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
then
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html).
The package must load with no errors and no exported functions yet
(NAMESPACE will be near-empty — fine).

------------------------------------------------------------------------

## Done when

Package loads via
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html)
with zero errors.

`DESCRIPTION` matches the spec exactly; `Imports` = cli, ggplot2, rlang,
tibble.

`LICENSE` + `LICENSE.md` both present.

`.tsr_cache` environment exists and is empty.

`R/tesseractR-package.R` has the `_PACKAGE` sentinel and rlang imports.

testthat scaffolding in place.

## On completion

Update `STATE.md`: S0 → `DONE`, S1 → `TODO`. Report that S1_GEOMETRY is
now runnable.

------------------------------------------------------------------------

# S1 — Geometry & Win Lines

**Depends on:** S0_FOUNDATION · **Unlocks:** S2_ENGINE

The mathematical core: the coordinate↔︎index mapping and the canonical
set of **272 winning lines** for the `4×4×4×4` board, computed once and
cached. Everything downstream (win detection, AI evaluation,
winning-line highlighting) consumes this. Get it exactly right — an
off-by-one here corrupts the whole engine.

All functions in this stack are **internal** (`.tsr_` prefix, no
`@export`). Document with `#' @noRd` or `#' @keywords internal`.

File: `R/tsr_lines.R`

------------------------------------------------------------------------

## Background (the maths — implement to match)

- The board is `4×4×4×4`. A cell has coordinates `(i, j, k, l)`, each in
  `0:3`.
- **Linear index:** `idx = 1 + i + 4*j + 16*k + 64*l`, so `idx ∈ 1:256`.
  This is column-major flattening; keep it consistent everywhere.
- **Line directions:** a direction is a vector `d ∈ {-1,0,1}^4`,
  excluding the zero vector. Normalize so the **first non-zero component
  is positive** (this dedups `d` and `-d`). Count: `(3^4 - 1) / 2 = 40`
  direction classes.
- **Lines:** for each direction `d` and each valid start cell `s` such
  that `s + 3*d` stays within `0:3` on every axis, the four cells
  `s, s+d, s+2d, s+3d` form a line.
- Deduplicate lines (a line and its reverse are the same set). The
  canonical total is **exactly 272 lines** for `4×4×4×4`. Assert this.

------------------------------------------------------------------------

## Tasks

### 1.1 — Coordinate ↔︎ index helpers

``` r

.tsr_coord_to_idx <- function(i, j, k, l) {
  # vectorized; inputs in 0:3; returns integer in 1:256
  as.integer(1L + i + 4L * j + 16L * k + 64L * l)
}

.tsr_idx_to_coord <- function(idx) {
  # inverse; returns a matrix or data structure with columns i, j, k, l in 0:3
  z <- idx - 1L
  i <- z %% 4L
  j <- (z %/% 4L) %% 4L
  k <- (z %/% 16L) %% 4L
  l <- (z %/% 64L) %% 4L
  cbind(i = i, j = j, k = k, l = l)
}
```

Both fully vectorized. Use integer arithmetic throughout.

### 1.2 — Direction enumeration

Internal `.tsr_directions()` returning the 40 normalized direction
vectors as a `40 × 4` integer matrix. Algorithm: expand the grid
`{-1,0,1}^4`, drop the all-zero row, keep only rows whose first non-zero
entry is `+1`. Assert `nrow == 40`.

### 1.3 — Win-line generation

`.tsr_compute_win_lines()` — for each direction and each in-bounds start
cell, build the four linear indices; collect into a `272 × 4` integer
matrix. Sort each row ascending and deduplicate rows (defensive — the
start/direction scheme shouldn’t double-count, but verify). Internal
`stopifnot(nrow(lines) == 272L)`.

### 1.4 — Cached accessor

`.tsr_win_lines()` — the only function the rest of the package calls:

``` r

.tsr_win_lines <- function() {
  if (is.null(.tsr_cache[["win_lines"]])) {
    .tsr_cache[["win_lines"]] <- .tsr_compute_win_lines()
  }
  .tsr_cache[["win_lines"]]
}
```

Cache via the `.tsr_cache` environment from S0. **Never** write to disk.
**Never** use `<<-`.

------------------------------------------------------------------------

## Tests (`tests/testthat/test-lines.R`)

- **Round-trip identity:** for all `idx in 1:256`, `.tsr_coord_to_idx`
  applied to `.tsr_idx_to_coord(idx)` returns `idx`. (Vectorize the
  assertion.)
- **Direction count:** `.tsr_directions()` has exactly 40 rows; no zero
  row; first non-zero component of every row is `+1`.
- **Line count:** `.tsr_win_lines()` returns a `272 × 4` integer matrix.
- **All indices valid:** every entry is in `1:256`.
- **Lines are collinear:** spot-check several lines — convert each of
  the 4 indices back to coordinates, confirm successive differences
  equal a constant direction vector.
- **Caching:** two calls to `.tsr_win_lines()` return identical objects
  (and the cache key is populated after the first call).
- **Known lines present:** assert that the axis-aligned line
  `c(1,2,3,4)` (the i-axis row at `j=k=l=0`) is among the lines, and
  that a main hyperdiagonal (`(0,0,0,0)→(1,1,1,1)→(2,2,2,2)→(3,3,3,3)`,
  i.e. indices `1,86,171,256`) is present.

------------------------------------------------------------------------

## Done when

`.tsr_win_lines()` returns a `272 × 4` integer matrix, cached.

Round-trip identity holds for all 256 cells.

40 normalized directions, all canonical.

All line tests pass via
[`devtools::test()`](https://devtools.r-lib.org/reference/test.html).

No exports added (these are all internal).

## On completion

Update `STATE.md`: S1 → `DONE`, S2 → `TODO`. Report that S2_ENGINE is
now runnable.

------------------------------------------------------------------------

# S2 — Engine: Board, Moves & Status

**Depends on:** S1_GEOMETRY · **Unlocks:** S3_AI **and**
S4_VISUALIZATION

The playable core. Defines the `ttt_board` S3 class and the full set of
exported engine functions: construct a board, make and undo moves,
enumerate legal moves, detect wins and draws. After this stack you can
play a full hotseat game in the console (no AI, no plot yet).

Files: `R/tsr_board.R`, `R/tsr_move.R`, `R/tsr_status.R`

------------------------------------------------------------------------

## The S3 class — constructor / validator / helper

Class name: **`ttt_board`** (clean, no prefix). State representation: -
`state` — `integer(256)`: `0` empty, `1` player X, `2` player O. -
`to_move` — `1L` or `2L` (whose turn). - `history` — integer vector of
linear indices played, in order (for `tsr_undo`).

### 2.1 — `R/tsr_board.R`

``` r

# Low-level constructor — trusted input, no validation, INTERNAL.
new_ttt_board <- function(state = integer(256),
                          to_move = 1L,
                          history = integer(0)) {
  structure(
    list(state = state, to_move = to_move, history = history),
    class = "ttt_board"
  )
}
```

`validate_ttt_board(x)` — checks invariants, errors via
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
with a `call`: - `inherits(x, "ttt_board")` - `length(x$state) == 256L`,
integer, values in `0:2` - `to_move %in% c(1L, 2L)` - history entries in
`1:256`, and count of non-empty cells equals `length(history)` Returns
`x` invisibly on success.

Exported user functions: -
[`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md)
— returns a fresh empty board (X to move). Full roxygen with
`@return "An object of class \code{ttt_board}."` and a runnable
`@examples`. - `is_ttt_board(x)` —
[`inherits()`](https://rdrr.io/r/base/class.html)-based predicate,
returns logical scalar.

Add a small internal helper `.tsr_check_board(x, call)` that runs
`validate_ttt_board` and is reused by every engine function for input
validation.

### 2.2 — `R/tsr_move.R`

`tsr_move(board, i, j, k, l)` — **primary coordinate form**. Also accept
a single linear index via `tsr_move(board, cell = idx)` (one of the two
must be supplied; validate). Behavior: - Validate board, validate
coordinates in `0:3` (or index in `1:256`). - Compute the target linear
index. - Error informatively if the cell is occupied or the game is
already over (call `tsr_check_win` / `tsr_is_full`). Use
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
with `x`/`i` bullets showing the offending cell. - Place the current
player’s mark, flip `to_move`, append the index to `history`. - Return a
**new** `ttt_board`. **Never mutate the input** — copy then modify.

`tsr_undo(board, n = 1L)` — pops the last `n` moves: clears those cells,
restores `to_move`, trims history. Errors if `n` exceeds
`length(history)`. Returns a new board.

`tsr_legal_moves(board)` — returns an **integer vector** of empty linear
indices. If the game is over or the board is full, return `integer(0)`
(type-stable — never `NULL`). Document that the return is always
integer.

### 2.3 — `R/tsr_status.R`

- `tsr_check_win(board)` — returns `0L` (none), `1L`, or `2L`. Iterate
  the cached `.tsr_win_lines()`: for each line, pull the 4 state values;
  if all equal and non-zero, that player wins. Optimize lightly
  (vectorize over the `272 × 4` matrix rather than a slow loop where
  reasonable), but correctness first.
- `tsr_winning_line(board)` — returns the length-4 integer index vector
  of the **first** winning line found, or `integer(0)` if none.
  Type-stable.
- `tsr_is_full(board)` — logical scalar: no empty cells.
- `tsr_status(board)` — returns a **one-row tibble** with explicit
  columns and types: `winner` (integer: 0/1/2), `is_full` (logical),
  `is_over` (logical), `n_moves` (integer), `to_move` (integer),
  `n_legal` (integer). Document every column in `@return` with its type.
  Always returns the same shape.

------------------------------------------------------------------------

## Tests

`tests/testthat/helper.R` — implement `example_board()`: a reproducible
mid-game position built by applying a fixed move sequence to
[`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md).
Also add `winning_board(player = 1L)` that plays an axis-aligned line to
completion for win tests.

`tests/testthat/test-board.R`: -
[`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md)
returns a valid `ttt_board`;
[`is_ttt_board()`](https://r-heller.github.io/tesseractR/reference/is_ttt_board.md)
TRUE on it, FALSE on a list. - `validate_ttt_board()` rejects: wrong
state length, out-of-range marks, bad `to_move` (use
`expect_snapshot(error = TRUE)` for the messages).

`tests/testthat/test-move.R`: -
[`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md)
places the mark at the right index, flips `to_move`, grows history
by 1. - **Immutability:** the original board passed to
[`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md)
is unchanged afterward. - Occupied-cell move errors; over-the-game move
errors (snapshot). -
[`tsr_undo()`](https://r-heller.github.io/tesseractR/reference/tsr_undo.md)
round-trips: `board |> tsr_move(...) |> tsr_undo()` equals the
original. -
[`tsr_legal_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_legal_moves.md):
256 on empty board, 0 (length-0 integer) on full/over board, correct set
after a few moves.

`tests/testthat/test-status.R`: -
[`tsr_check_win()`](https://r-heller.github.io/tesseractR/reference/tsr_check_win.md)
detects an **axis-aligned** win and a **hyperdiagonal** win
(`1,86,171,256`), returns `0L` mid-game. -
[`tsr_winning_line()`](https://r-heller.github.io/tesseractR/reference/tsr_winning_line.md)
returns the right 4 indices on a win, `integer(0)` otherwise. -
[`tsr_is_full()`](https://r-heller.github.io/tesseractR/reference/tsr_is_full.md)
TRUE on a filled board. -
[`tsr_status()`](https://r-heller.github.io/tesseractR/reference/tsr_status.md)
returns a one-row tibble with exactly the documented columns and types;
`is_over` TRUE when there’s a winner or the board is full.

------------------------------------------------------------------------

## Done when

All engine functions implemented, exported, fully documented (`@param`,
`@return`, `@examples`).

Board is immutable across `tsr_move`/`tsr_undo`.

Win detection correct for axis-aligned and diagonal lines.

Every accessor is type-stable (verified by tests).

[`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
green for board/move/status.

STATE.md function registry rows for S2 marked tested + documented.

## On completion

Update `STATE.md`: S2 → `DONE`, S3 **and** S4 → `TODO`. Report both are
now runnable (independent — can run in either order or parallel
sessions).

------------------------------------------------------------------------

# S3 — AI, Evaluation & Win Probability

**Depends on:** S2_ENGINE · **Unlocks:** (with S4) S5_APP_SUBMISSION;
also S6_SIMULATION, S7_ANALYSIS

A depth-limited negamax opponent **and** the package’s evaluation core.
This stack is the **single source of truth** for position assessment:
the AI, the simulation engine (S6), the game-analysis tools (S7), and
the app’s real-time move rating (S5) all call the same exported
[`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
/
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md).
Get the evaluation contract right here — everything downstream depends
on it.

File: `R/tsr_ai.R`, `R/tsr_evaluate.R`

------------------------------------------------------------------------

## Design

### Evaluation heuristic — `.tsr_evaluate(board, player)`

Score the position from `player`‘s perspective. Iterate the cached win
lines; for each line, look at the 4 cells: - If the line contains
**both** players’ marks → dead line, contributes `0`. - If it contains
only `player`’s marks (and empties): `+weight[n]` where `n` = count of
player’s marks, `weight = c(1, 10, 100)` for `n = 1, 2, 3` (a completed
line is handled as terminal, see below). - If it contains only the
**opponent’s** marks: `-weight[n]`. Sum across all lines. Return a
single numeric.

Terminal handling: before searching, check
[`tsr_check_win()`](https://r-heller.github.io/tesseractR/reference/tsr_check_win.md).
A win for `player` returns `+Inf` (or a large finite sentinel like `1e6`
minus depth, to prefer faster wins); a loss returns `-Inf` (or
`-1e6 + depth`). A full board with no winner returns `0`.

### Search — `.tsr_negamax(board, depth, alpha, beta, player)`

Standard negamax with alpha-beta: - Base case: `depth == 0` or game over
→ return `.tsr_evaluate()` (with terminal sentinels). - **Move
ordering:** generate legal moves, score each by a cheap heuristic
(e.g. the evaluation after the tentative move, or the count of player’s
near-complete lines through that cell), sort descending. Good ordering
is what makes alpha-beta tractable here. - Recurse with negated/swapped
`alpha`/`beta` and the other player; prune on `alpha >= beta`.

Keep the engine functions it calls (`tsr_move`, `tsr_legal_moves`,
`tsr_check_win`) as the only interface — do not reach into board
internals directly, so a future Rcpp swap stays clean.

### Public — `tsr_ai_move(board, difficulty = 2L)`

- Validate `board` and `difficulty` (integer-coercible, in `1:4`; use a
  clear
  [`cli::cli_abort`](https://cli.r-lib.org/reference/cli_abort.html) if
  out of range).
- Difficulty → search depth mapping: `1 = win/block only` (depth 1, but
  always take an immediate win and always block an immediate opponent
  win — implement this as a guaranteed pre-check regardless of depth),
  up to `4` = depth-4 search.
- Return the chosen move as a **linear index** (document this; it can be
  fed to `tsr_move(board, cell = idx)`). If no legal moves,
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  (the caller shouldn’t ask the AI to move on a finished board).
- Deterministic tie-breaking (e.g. lowest index among equal-scored
  moves) so tests are stable; optionally mention a `seed`-free
  deterministic policy in docs.

Document the runtime caveat plainly: \> Search is exponential in depth
and runs in pure R; depth 4 may take several seconds on a \> 256-cell
board. Rcpp acceleration is a planned future enhancement and is
intentionally out \> of scope for this release.

Wrap any `@examples` that search at depth ≥ 3 in `\donttest{}`.

------------------------------------------------------------------------

## Exported evaluation surface (`R/tsr_evaluate.R`) — the single source of truth

These are the functions S5/S6/S7 all consume. Keep the internal
`.tsr_evaluate()` as the raw engine; expose clean, documented,
type-stable public wrappers.

### `tsr_evaluate(board, player = NULL)`

- Exported wrapper over the internal heuristic. If `player` is `NULL`,
  evaluate from the perspective of `board$to_move`.
- Returns a **single numeric** raw score (positive favors `player`).
  Document the scale is unitless and only comparable within the same
  board size.
- Validate inputs via `cli`.

### `tsr_win_prob(board, player = NULL, method = c("heuristic", "rollout"), n = 200L)`

The calibrated probability in **\[0, 1\]** that `player` wins from this
position. Two methods:

- **`"heuristic"` (default, real-time):** map the raw
  [`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
  score through a logistic calibration: `p = plogis((score - a) / b)`.
  The coefficients `a, b` are **fitted from self-play data produced by
  S6** and stored as an internal package object (e.g. `R/sysdata.rda`
  via `usethis::use_data(internal = TRUE)`, built by a `data-raw/`
  script in S6 — NOT computed at runtime). Until S6 produces them, ship
  sensible hand-set defaults and note the calibration is provisional.
  This path is fast → suitable for per-move ratings in the app.
- **`"rollout"` (optional, offline accuracy):** run `n` policy-guided
  Monte-Carlo playouts from the position (using a light heuristic/random
  policy), return the empirical win rate. Slower in pure R → `n` is a
  tuning knob; document the speed/accuracy tradeoff. Wrap example in
  `\donttest{}`.

Both methods return a numeric in `[0, 1]`. Terminal positions
short-circuit: a win returns `1`, a loss `0`, a draw `0.5` (document
this).

### `tsr_rate_moves(board, method = c("heuristic", "rollout"), n = 200L)`

The real-time “what’s the best next move” function the app and analysis
both call. - For every legal move, apply it, then score the
**resulting** position for the side that just moved (via
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
from that side’s perspective, or
[`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
for raw). - Return a **tibble**, one row per legal move, type-stable
columns: `cell` (integer linear index), `i`,`j`,`k`,`l` (integer
coords), `score` (numeric raw eval), `win_prob` (numeric \[0,1\]),
`rank` (integer, 1 = best), `is_best` (logical), `is_winning` (logical —
completes a line), `is_blocking` (logical — denies an opponent’s
immediate win). - Sorted best-first. Empty board → 256 rows; finished
board → **0-row tibble** with the same columns (type-stable, never
`NULL`). - This is the engine behind the app’s per-cell rating overlay
and S7’s move grading.

------------------------------------------------------------------------

## Tests (`tests/testthat/test-ai.R`)

- **Legality:**
  [`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)
  always returns an index in `tsr_legal_moves(board)`.
- **Immediate win:** construct a board where `player` has 3 in a line
  with the 4th cell empty; at difficulty ≥ 1 the AI must return that
  completing index.
- **Immediate block:** construct a board where the **opponent**
  threatens to complete a line next move; at difficulty ≥ 1 the AI must
  return the blocking index.
- **Determinism:** two calls on the same board with the same difficulty
  return the same move.
- **Terminal guard:** asking for a move on a won/full board errors
  (snapshot).
- Keep all AI tests at low depth (1–2) so the suite stays fast; never
  call depth 4 in tests.

**`tests/testthat/test-evaluate.R`:** -
[`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
returns a single numeric; sign favors the stronger side on a contrived
board. -
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
returns a value in `[0, 1]` for every method; terminal positions give
exactly `1` (win), `0` (loss), `0.5` (draw). -
`tsr_win_prob(method = "rollout", n = small)` is within a tolerance band
of the heuristic on a clearly-decided position (sanity, not exactness;
keep `n` tiny for test speed). -
[`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md)
returns a tibble with the documented columns and types; rows =
legal-move count; `rank` is a 1..n permutation; exactly one `is_best`
when there’s a unique top move; `is_winning` TRUE on a completing move;
**0-row typed tibble** on a finished board. - Type-stability assertions
on all three.

------------------------------------------------------------------------

## Done when

[`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)
implemented, exported, documented, with the perf caveat.

[`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md),
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md),
[`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md)
exported, documented, type-stable.

[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
terminal short-circuits (1/0/0.5) correct; calibration coefficients
sourced from internal data (provisional defaults until S6 fits them).

Win-take and loss-block guaranteed at difficulty ≥ 1.

Returns only legal, deterministic moves.

AI + evaluate tests green and fast (depth ≤ 2, small rollout `n` only).

STATE.md registry: `tsr_ai_move`, `tsr_evaluate`, `tsr_win_prob`,
`tsr_rate_moves` tested + documented.

## On completion

Update `STATE.md`: S3 → `DONE`. Newly runnable: **S6_SIMULATION** and
**S7_ANALYSIS** (both need S3). If S4 is also `DONE`, S5 → `TODO`.
Report the full runnable set.

------------------------------------------------------------------------

# S4 — Visualization & Print Methods

**Depends on:** S2_ENGINE · **Unlocks:** (with S3) S5_APP_SUBMISSION

Make the 4D board legible on a 2D screen and give the `ttt_board` class
clean console output. This stack is independent of S3 (AI) — it only
needs the engine.

Files: `R/tsr_plot.R`, `R/tsr_print.R`

------------------------------------------------------------------------

## The visualization design (the core trick)

4D on a 2D plane: render a **`4×4` outer grid** indexed by the outer
dimensions `(k, l)`, where each outer cell contains an **inner `4×4`
board** indexed by `(i, j)`. So the screen is a 4×4 arrangement of
mini-boards. This is the standard, most-readable projection of a
`4×4×4×4` board.

Implementation approach (single ggplot, computed offsets — preferred
over faceting for full control of gridlines and highlighting): - For
each of the 256 cells, compute a plotting `(x, y)`: - inner offset
within a mini-board from `(i, j)`, - block offset from `(k, l)` (with a
gap between blocks), - e.g. `x = k * (4 + gap) + i`,
`y = l * (4 + gap) + j` (flip y so it reads top-down). - Draw cell
backgrounds (tiles), block separators, and the marks.

### `tsr_plot(board, highlight_win = TRUE, ...)`

- Returns a **`ggplot` object** — never renders in place, never calls
  [`print()`](https://rdrr.io/r/base/print.html).
- Marks: player 1 = “X”, player 2 = “O” (use `geom_text`, or distinct
  shapes/colors — colorblind-safe, e.g. Okabe-Ito blue/orange). Empty
  cells blank.
- If the game is over and `highlight_win`, draw the winning line (from
  [`tsr_winning_line()`](https://r-heller.github.io/tesseractR/reference/tsr_winning_line.md))
  emphasized — e.g. a colored stroke/segment connecting its 4 cells, or
  highlighted tiles.
- `coord_equal()`, `theme_minimal()` (or a stripped theme removing axis
  ticks/labels — a board doesn’t need numeric axes), informative
  `labs(title=, subtitle=)` showing whose turn / winner.
- **All `aes()` column references use `.data$`** to avoid R CMD check
  “no visible binding” notes.
- Build the plotting data frame as a tibble.

### `autoplot.ttt_board(object, ...)`

- `#' @importFrom ggplot2 autoplot` and register the S3 method.
  Delegates to `tsr_plot(object, ...)`.
- Document `@param object`, `@param ...`.

------------------------------------------------------------------------

## The slice view (`tsr_plot_slice()`)

The 4×4-of-4×4 layout shows the whole board but makes the
through-all-four-dimensions diagonals visually scattered — four
collinear cells land far apart on screen. The slice view fixes one axis
to a single value, dropping 4D to **3D**, which renders as a readable
**1×4 strip** of 4×4 mini-boards (one less dimension than the full
plot). Use it to inspect a plane where a diagonal actually reads as a
line, or to teach the geometry.

### `tsr_plot_slice(board, axis = c("i", "j", "k", "l"), at = 0L, highlight_win = TRUE, ...)`

- `axis` — which of the four dimensions to fix (`match.arg`).
- `at` — the value `0:3` to hold that axis at. Validate range with
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html).
- Selects the 64 cells where the chosen axis equals `at`, then lays out
  the remaining three dimensions: two of them as the inner 4×4 board,
  the third as a 1×4 row of blocks. Pick a fixed, documented convention
  for which remaining axis becomes the block axis (e.g. the
  highest-numbered remaining axis).
- Returns a **`ggplot` object**, same styling language as
  [`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
  (Okabe-Ito marks, stripped theme, `coord_equal()`). Title/subtitle
  states the fixed axis and value (e.g. “Slice k = 2”).
- Win highlight: if a winning line lies **entirely within this slice**,
  emphasize it; if the winning line only partially intersects the slice,
  mark the intersecting cells but note in the subtitle that the full
  line spans other slices. (A line is “in this slice” iff all four of
  its cells share the fixed axis value.)
- Reuse the same internal cell→`(x,y)` offset helper as
  [`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
  (factor it out, e.g. `.tsr_layout(coords, block_axis, gap)`), so the
  two functions stay visually consistent and DRY.
- All `aes()` use `.data$`.

This is an **optional companion** to
[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md),
not a replacement — the full plot stays the default and the `autoplot`
target.

------------------------------------------------------------------------

## The 3D cube view (Shiny-app only — built in S5, specified here)

The 2D slice helps, but a 4³ slice **is** a cube, and rendering it as a
rotatable 3D object is where the geometry finally becomes intuitive —
diagonals you can turn in space. This view lives **only in the Shiny
app** (`inst/shiny/`), via `plotly`. It is **not** an exported package
function: `plotly` stays in `Suggests`, and the static `tsr_plot*()`
functions remain the CRAN/vignette/reference surface. (Keeping 3D out of
the exported API avoids a `Suggests` dependency leaking into core docs
and keeps `R CMD check` clean with zero plotly installed.)

So the app’s render logic — to be implemented in S5 — builds the plotly
object inline from engine accessors, not from a package function. Spec
for that inline builder:

- **Fix one axis** (the *projection axis*, chosen by a UI selector: i /
  j / k / l) at a value `0:3`, yielding the 64-cell cube over the
  remaining three dimensions. The two selectors together (which axis is
  fixed + at which value) give all four cut directions, fully clickable.
- `plotly::plot_ly(..., type = "scatter3d", mode = "markers+text")` over
  the 64 cells:
  - **Stones:** player 1 = “X”, player 2 = “O”, color-coded Okabe-Ito
    blue/orange, sized markers with the letter as text.
  - **Empty cells:** faint small grey points so the lattice is visible
    without clutter.
  - **Winning line:** if a winning line lies entirely within this cube,
    overlay it as a 3D segment (`add_trace` with `mode = "lines"`) in a
    highlight color; if it only partially intersects, mark the in-cube
    cells and note the span in the panel text.
- **Inspect-only** — rotation/zoom via plotly’s native controls; **no
  move-by-click in 3D** (depth ambiguity makes 3D cell-picking
  unreliable). Moves stay in the 2D full board.
- Axis ticks labelled `0:3` on the three free dimensions; scene aspect
  locked to a cube (`scene = list(aspectmode = "cube")`).
- Guard with
  [`requireNamespace("plotly", quietly = TRUE)`](https://rdrr.io/r/base/ns-load.html);
  if absent, fall back to the 2D
  [`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md)
  render and show an inline note suggesting
  `install.packages("plotly")`.

------------------------------------------------------------------------

## Print / format / summary (`R/tsr_print.R`)

Register as S3 methods with `#' @method print ttt_board` (not
`@export print.ttt_board`).

- `print.ttt_board(x, ...)` — one-screen `cli` summary:
  - class line + dimensions (“4×4×4×4 board, 256 cells”),
  - move count and whose turn, or the winner if the game is over,
  - legal-move count. Use
    [`rlang::check_dots_empty()`](https://rlang.r-lib.org/reference/check_dots_empty.html).
    Return `invisible(x)`.
- `format.ttt_board(x, ...)` — returns a character vector representation
  consistent with print.
- `summary.ttt_board(object, ...)` — returns the
  [`tsr_status()`](https://r-heller.github.io/tesseractR/reference/tsr_status.md)
  tibble (or a small summary object), so
  [`summary()`](https://rdrr.io/r/base/summary.html) is the structured
  counterpart to [`print()`](https://rdrr.io/r/base/print.html)’s human
  view.

Keep `print` and `format` in sync (print can build on format).

------------------------------------------------------------------------

## Tests

`tests/testthat/test-plot.R`: -
[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
returns an object inheriting `"ggplot"`. - Doesn’t error on: empty
board, mid-game board, won board. - On a won board with
`highlight_win = TRUE`, the plot has the extra winning-line layer
(assert `length(p$layers)` increases vs. an unfinished board, or check
for the layer). - `autoplot()` on a `ttt_board` returns a ggplot equal
in class to
[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md). -
[`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md)
returns a ggplot for every `axis` ∈ {i,j,k,l} and every `at` ∈ 0:3. -
[`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md)
errors on out-of-range `at` (snapshot) and on a bad `axis`. - On a board
won by an **axis-aligned** line that lies within a slice, that slice’s
plot shows the in-slice highlight; a slice not containing the line does
not.

`tests/testthat/test-print.R`: -
[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly and emits output (`expect_snapshot(print(board))`). -
[`print()`](https://rdrr.io/r/base/print.html) errors on extra dots
(`check_dots_empty`). -
[`summary()`](https://rdrr.io/r/base/summary.html) returns the
documented tibble shape.

------------------------------------------------------------------------

## Done when

[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
returns a ggplot rendering the 4×4-of-4×4 layout, with winning-line
highlight.

[`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md)
returns a ggplot for a fixed axis/value, with in-slice highlight logic.

Shared `.tsr_layout()` helper used by both plot functions (DRY,
consistent styling).

`autoplot.ttt_board` registered and delegating.

`print`/`format`/`summary` methods registered, one-screen,
type-consistent.

All `aes()` use `.data$` (no global-binding notes).

plot + print tests green.

STATE.md registry rows for S4 marked tested + documented.

## On completion

Update `STATE.md`: S4 → `DONE`. If S3 is also `DONE`, S5 → `TODO`
(report S5 runnable); otherwise report S3 still pending before S5
unlocks.

------------------------------------------------------------------------

# S6 — Simulation & Strategy

**Depends on:** S3 (evaluation core) · **Unlocks:** S5 (calibration
data + opening stats feed the app/analysis); contributes to AUDIT

Self-play and strategy statistics. The engine plays itself under
configurable policies, records outcomes, and produces two things: (1)
**opening/strategy statistics** (win rate by first-move position, by
difficulty, etc.) as part of the package’s analytical capability, and
(2) the **calibration dataset** that fits the logistic coefficients used
by
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
in S3.

This is where “a game” becomes “an analysis tool for a game”. All
simulation routes through the S3 evaluation core — single source of
truth, no parallel scoring logic.

File: `R/tsr_simulate.R`, plus `data-raw/calibration.R`

------------------------------------------------------------------------

## Policies

A **policy** decides a move given a board. Define an internal policy
interface and ship a few: - `"random"` — uniform over legal moves
(baseline). - `"greedy"` — highest
[`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
after the move (depth-0 lookahead). - `"ai"` —
`tsr_ai_move(difficulty = d)` for a given depth `d`. Represent a policy
as a function `(board) -> cell`, constructed by small internal factories
(e.g. `.tsr_policy_ai(difficulty)`). Document the set; keep it
extensible.

------------------------------------------------------------------------

## Core functions

### `tsr_play_game(policy_x, policy_o, seed = NULL)`

Play one complete game between two policies. - Returns a **`tsr_game` S3
object** (the move record): a list with `moves` (integer indices in
order), `winner` (0/1/2), `n_moves`, `policies` (labels), `final_board`
(a `ttt_board`), and optionally the per-move `to_move`. Provide
`print.tsr_game`. - Deterministic given `seed` (only `"random"` policy
consumes RNG; set via
[`withr::local_seed()`](https://withr.r-lib.org/reference/with_seed.html)
internally so global RNG state is untouched). - This object is the input
to S7’s
[`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md).

### `tsr_simulate(policy_x, policy_o, n_games = 100L, seed = NULL, verbose = TRUE)`

Run `n_games` self-play games. - Returns a **tibble**, one row per game:
`game_id`, `winner`, `n_moves`, `first_move` (integer cell),
`first_move_i/j/k/l`, plus policy labels. Type-stable. -
[`cli::cli_progress_bar()`](https://cli.r-lib.org/reference/cli_progress_bar.html)
over games when `verbose` (respect
[`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html)
for non-essential output). - **Performance honesty:** pure-R self-play
over 256 cells is slow; deep-AI policies multiply the cost. Default
`n_games = 100`; document that meaningful opening statistics may need
thousands of games and that the hot-path functions (`.tsr_evaluate`,
legal-move gen) are marked as future Rcpp-replaceable. Wrap any
`@examples` with non-trivial `n_games` or AI policies in `\donttest{}`.

### `tsr_opening_stats(sim, by = c("first_move", "difficulty"))`

Aggregate a
[`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md)
result into strategy statistics — the analytical payload. - Returns a
**tibble**: grouping column(s) + `n_games`, `win_rate_x`, `win_rate_o`,
`draw_rate`, and a Wilson confidence interval (`ci_lo`, `ci_hi`) on the
win rate. Use `stats::` for the CI; add `stats` to Imports if not
already there. - This powers a “first-move heat” view (which opening
cells are strong) — a `ggplot` of win rate over the 4×4-of-4×4 layout
can be added in S4’s idiom if desired, but the tibble is the contract;
plotting is optional and lives in S4/S5.

------------------------------------------------------------------------

## Calibration (`data-raw/calibration.R`) — feeds `tsr_win_prob()`

This script is **dev-only** (gitignored from the build via `data-raw/`
in `.Rbuildignore`), run once to fit the logistic calibration consumed
by S3’s heuristic
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md):

1.  Run a self-play simulation (mixed policies for coverage).
2.  At sampled mid-game positions, record `tsr_evaluate(board, player)`
    and the **eventual outcome** for `player` (1 win / 0 loss / 0.5 draw
    → treat as binary with draws split or dropped, document the choice).
3.  Fit `glm(outcome ~ score, family = binomial)` to get intercept/slope
    → derive `a, b` for `p = plogis((score - a) / b)`.
4.  Save the coefficients as internal package data:
    `usethis::use_data(.tsr_calibration, internal = TRUE, overwrite = TRUE)`.
5.  S3’s
    [`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
    reads `.tsr_calibration` from `R/sysdata.rda` at call time. If the
    object is absent, fall back to the provisional hand-set defaults (so
    the package still works before calibration is run).

Document in the script header that re-running it regenerates
`R/sysdata.rda`, and that this is a maintenance step, not part of the
user-facing API.

------------------------------------------------------------------------

## Tests (`tests/testthat/test-simulate.R`)

- [`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md)
  returns a `tsr_game` with a valid winner and a move count ≤ 256;
  replaying its moves on a fresh board reproduces `final_board`.
- Determinism: same `seed` + same policies → identical game.
- `tsr_simulate(n_games = 5)` returns a 5-row tibble with the documented
  columns/types.
- [`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md)
  returns one row per first-move group; win rates in `[0,1]` and
  `win_rate_x + win_rate_o + draw_rate == 1` per group; CI columns
  present and ordered.
- Keep all tests tiny: `random` vs `random` or `greedy`, `n_games ≤ 5`;
  never run AI-depth policies in tests. RNG isolation: a test confirms
  global `.Random.seed` is unchanged after a seeded sim.

------------------------------------------------------------------------

## Done when

[`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md),
[`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md),
[`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md)
exported, documented, type-stable.

`tsr_game` S3 object with `print` method; replay round-trips to
`final_board`.

All simulation scoring routes through the S3 evaluation core (no
parallel logic).

`data-raw/calibration.R` present; `R/sysdata.rda` produced;
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
consumes it with graceful fallback.

RNG isolation verified; sims deterministic under `seed`.

Perf caveats documented; heavy examples `\donttest{}`.

`data-raw` in `.Rbuildignore`.

STATE.md registry updated for S6 exports.

## On completion

Update `STATE.md`: S6 → `DONE`. Note the calibration data is now real
(not provisional). Report remaining runnable set.

------------------------------------------------------------------------

# S7 — Game Analysis & Play-Behavior Analytics

**Depends on:** S3 (evaluation core); consumes `tsr_game` objects from
S6 · Contributes to S5 (app analysis panel) and AUDIT

Post-hoc analysis of played games and of **play behavior** across many
games — the analytical capability that makes `tesseractR` a study tool,
not just a playable board. Move-by-move evaluation, turning points,
missed wins/blocks, and aggregate behavioral profiles of a player or
policy. Everything scores through the S3 evaluation core.

File: `R/tsr_analyze.R`

------------------------------------------------------------------------

## Single-game analysis

### `tsr_analyze_game(game, method = c("heuristic", "rollout"), n = 200L)`

Input: a `tsr_game` object (from
[`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md))
**or** a move sequence + the engine to replay it. Walk the game move by
move, re-deriving each intermediate board, and for each ply compute the
evaluation context.

Returns a **tibble**, one row per ply, type-stable columns: - `ply`
(integer), `player` (1/2), `cell` (integer), `i/j/k/l` (integer
coords), - `win_prob_before` / `win_prob_after` (numeric \[0,1\], from
the moving player’s perspective), - `delta`
(`win_prob_after - win_prob_before` — the move’s impact), - `best_cell`
(integer — the top move by
[`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md)
at that position), - `best_delta` (numeric — impact had they played
`best_cell`), - `regret` (numeric ≥ 0 — `best_delta - delta`; how much
was given up), - `is_best` (logical — played the top move), -
`missed_win` (logical — a winning move existed and was not played), -
`missed_block` (logical — an opponent threat existed and was not
blocked), - `is_turning_point` (logical — `abs(delta)` exceeds a
documented threshold).

This reuses
[`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md)
/
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
from S3 — no new scoring logic. Document the turning-point threshold and
that `"rollout"` is slower (wrap heavy examples in `\donttest{}`).

### `tsr_turning_points(analysis)`

Convenience filter: takes a
[`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md)
tibble, returns the subset where `is_turning_point` is TRUE (or the
top-`k` by `abs(delta)`), sorted by impact. Type-stable (0-row tibble if
none).

### `tsr_game_summary(game)`

One-row tibble per game: `winner`, `n_moves`, `n_missed_wins_x/o`,
`n_missed_blocks_x/o`, `mean_regret_x/o`, `n_turning_points`,
`decisiveness` (e.g. final-position \|win_prob − 0.5\|). The compact
scorecard for a single game.

------------------------------------------------------------------------

## Play-behavior analytics (aggregate — the “analysis capacity” payload)

These profile how a **player or policy** behaves across many games,
feeding the suite’s analytical positioning.

### `tsr_behavior_profile(games, label = NULL)`

Input: a list of `tsr_game` objects (e.g. all games from a
[`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md)
run, or a player’s recorded games). For a chosen side/policy, aggregate
per-move analyses into a behavioral profile tibble: - `n_games`,
`n_moves_total`, - `accuracy` (share of moves equal to the engine’s
best), - `mean_regret`, `blunder_rate` (share with `regret` over a
documented blunder threshold), - `win_conversion` (win rate when ahead
at some ply), `defense_rate` (block rate when threatened), -
`aggression` (share of moves that create new 3-in-line threats), -
`mean_decisiveness`. Type-stable; `label` tags the profile (for
comparing policies/players side by side).

### `tsr_compare_profiles(...)`

Row-bind several
[`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md)
results into one tibble for comparison (e.g. greedy vs. AI-depth-3
vs. human). Type-stable; validates matching columns.

------------------------------------------------------------------------

## Plot helpers (ggplot, optional but recommended)

Keep these in S4’s idiom (return `ggplot` objects, `.data$`),
implemented here or in `tsr_plot.R`: - `tsr_plot_winprob(analysis)` —
win-probability trajectory over plies (line, 0.5 reference), turning
points marked. The signature “evaluation curve” of a game. - Optionally
a regret-by-ply bar. All return ggplot objects; never render in place.

------------------------------------------------------------------------

## Tests (`tests/testthat/test-analyze.R`)

- [`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md)
  on a known short game returns one row per ply with the documented
  columns/types; `win_prob_before/after` in `[0,1]`; `regret ≥ 0`.
- Construct a game where a player **had** a winning move and didn’t take
  it → `missed_win` TRUE on that ply; construct an ignored block →
  `missed_block` TRUE.
- `delta` sign sanity: a clearly bad move has negative `delta`.
- [`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md)
  returns the high-impact subset, type-stable (0-row when none).
- [`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md)
  over a few games returns the documented one-row profile; `accuracy`
  and rates in `[0,1]`.
- [`tsr_compare_profiles()`](https://r-heller.github.io/tesseractR/reference/tsr_compare_profiles.md)
  row-binds and errors on mismatched columns.
- [`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md)
  returns a ggplot.
- Use tiny fixtures and `method = "heuristic"` only in tests (no
  rollouts) for speed.

------------------------------------------------------------------------

## Done when

[`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md),
[`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md),
[`tsr_game_summary()`](https://r-heller.github.io/tesseractR/reference/tsr_game_summary.md),
[`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md),
[`tsr_compare_profiles()`](https://r-heller.github.io/tesseractR/reference/tsr_compare_profiles.md)
exported, documented, type-stable.

All scoring delegates to S3 (`tsr_win_prob`/`tsr_rate_moves`) — no
parallel logic.

Missed-win / missed-block / turning-point detection correct on
constructed fixtures.

[`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md)
returns a ggplot.

Analysis tests green and fast (heuristic only).

STATE.md registry updated for S7 exports.

## On completion

Update `STATE.md`: S7 → `DONE`. Report remaining runnable set (S5 needs
S3+S4; the app’s analysis panel is richer once S6+S7 are done — see S5
note).

------------------------------------------------------------------------

# S5 — Shiny App, Vignette & Submission Prep

**Depends on:** S3 (eval), S4 (viz), S6 (simulation), S7 (analysis) ·
**Unlocks:** AUDIT_REFINE_LOOP

The user-facing layer and everything CRAN needs around the code: an
interactive Shiny app with **real-time move evaluation** and a
**game-analysis panel**, plus the vignette, README, pkgdown config, and
NEWS. After this stack the package is feature-complete; the audit loop
only fixes check findings.

Files: `R/tsr_run_app.R`, `inst/shiny/tesseractR/app.R`,
`inst/shiny/tesseractR/www/custom.css`, `vignettes/tesseractR.Rmd`,
`README.Rmd` → `README.md`, `_pkgdown.yml`, `NEWS.md`

------------------------------------------------------------------------

## 5.1 — Shiny launcher (`R/tsr_run_app.R`)

`tsr_run_app(difficulty = 2L)`: - Check
[`requireNamespace("shiny", quietly = TRUE)`](https://rdrr.io/r/base/ns-load.html);
if missing,
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
with an install hint (`{.code install.packages("shiny")}`). Same soft
check pattern for `bslib`/ `plotly` inside the app where used. - Launch:
`shiny::runApp(system.file("shiny", "tesseractR", package = "tesseractR"))`. -
`@return` “Invisible `NULL`. Launches a Shiny application.” `@examples`
wrapped in `\donttest{}`.

## 5.2 — The app (`inst/shiny/tesseractR/app.R`)

**No [`library()`](https://rdrr.io/r/base/library.html) calls —
namespace-qualify everything** (`shiny::`, `tesseractR::`, `bslib::`,
`plotly::`).

Layout (use
[`bslib::page_sidebar`](https://rstudio.github.io/bslib/reference/page_sidebar.html)
or similar, suite purple `#5E2C8E` accent via
[`bslib::bs_theme`](https://rstudio.github.io/bslib/reference/bs_theme.html)): -
**Sidebar:** new-game button; mode toggle (Hotseat vs. vs-AI);
difficulty slider (1–4, shown only in vs-AI mode); whose-turn indicator;
status readout (in progress / X wins / O wins / draw). - **Main:** the
board. Either render
[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
via [`shiny::renderPlot`](https://rdrr.io/pkg/shiny/man/renderPlot.html)
with click handling (`plotOutput(click=)`, map click coordinates back to
the nearest cell), **or** use `plotly` for native click events
(`plotly::event_data("plotly_click")`). Prefer plotly for clean cell
clicks; degrade to `renderPlot`+click if plotly is unavailable. - **View
toggle:** a control to switch the main panel between three views: 1.
**Full** 4×4-of-4×4 board
([`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md))
— the default, and where moves are made. 2. **Slice (2D)** —
[`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md),
a flat 1×4 strip for a fixed axis/value. 3. **Cube (3D)** — a rotatable
plotly `scatter3d` of the 4³ cube for a fixed *projection axis* and
value (spec in S4: app-only, built inline, inspect-only). Expose a
**projection-axis selector** (i/j/k/l) and a **value selector** (0–3);
together they cover all four cut directions. Stones as 3D X/O markers
(Okabe-Ito), empty cells as faint lattice points, winning line as a 3D
segment when it lies in the cube. In both slice and cube modes, moves
are still made in the **Full** view to avoid ambiguous click-mapping in
the reduced/3D layouts. - **plotly guard:** the Cube view requires
`plotly` (Suggests). If
[`requireNamespace("plotly")`](https://plotly-r.com) is FALSE,
disable/hide the Cube option and fall back to the 2D slice, with an
inline install hint. The app must run fully on the two ggplot views with
zero plotly installed. - Click an empty cell →
[`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md);
in vs-AI mode, follow with
[`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)
→
[`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md).
Update state. When the game ends, show the winner and highlight the
winning line (call `tsr_plot(..., highlight_win = TRUE)`).

### Real-time move evaluation (the live “best next move” layer)

- On every position change, call `tesseractR::tsr_rate_moves(board)` for
  the side to move.
- **Rating overlay (toggleable):** shade each empty cell in the Full
  view by its `win_prob` (sequential scale), mark `is_best` cells, and
  flag `is_winning` / `is_blocking` cells with a distinct symbol. This
  is the at-a-glance “where should I play” guide.
- **Win-probability gauge:** show the current player’s
  `tsr_win_prob(board)` as a gauge/number that updates each move (a
  small `tsr_plot_winprob`-style sparkline of the game so far is a nice
  extra — drive it from the running analysis, see below).
- **Performance:** use `method = "heuristic"` for the live overlay
  (fast). Offer an optional “deep estimate” button that runs
  `method = "rollout"` for the current position only, shown with a
  spinner — never block the UI on rollouts. Cache the last rating so
  re-renders don’t recompute.

### Analysis panel (post-game and live)

- Maintain the move history as a `tsr_game`-shaped record in
  `reactiveValues`.
- A panel/tab runs
  [`tesseractR::tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md)
  on the moves played so far and shows:
  - the **win-probability trajectory**
    ([`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md)),
  - a **turning-points** table
    ([`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md)),
  - per-move flags: missed wins, missed blocks, regret.
- After the game ends, show
  [`tsr_game_summary()`](https://r-heller.github.io/tesseractR/reference/tsr_game_summary.md)
  as a scorecard.
- Optional “behavior” readout when playing vs-AI across multiple games
  in the session: accumulate finished `tsr_game`s and show
  [`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md)
  for the human side (accuracy, blunder rate, defense rate) — the
  play-behavior analytics surfaced live.

State management: -
`shiny::reactiveValues(board = tesseractR::tsr_new_board())`. `<<-`
allowed **only** inside reactive/observer contexts. - Wrap render
functions in [`tryCatch()`](https://rdrr.io/r/base/conditions.html) /
`req()` for graceful failure. - No external CDN fonts/icons
(offline-safe).

`www/custom.css`: dark board background, purple chrome accent, readable
X/O contrast.

## 5.3 — Vignette (`vignettes/tesseractR.Rmd`)

YAML:
[`rmarkdown::html_vignette`](https://pkgs.rstudio.com/rmarkdown/reference/html_vignette.html),
`VignetteIndexEntry{Getting Started with tesseractR}`,
`knitr::rmarkdown` engine, UTF-8. Build \< 60s, no internet, package
functions only.

Content: 1. **What is 4D tic-tac-toe** — the hypercube, why there are
272 winning lines. 2. **A first game** —
[`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md),
a few
[`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md)
calls, show [`print()`](https://rdrr.io/r/base/print.html) output and a
[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
figure. 3. **Detecting a win** — play a line to completion, show
[`tsr_check_win()`](https://r-heller.github.io/tesseractR/reference/tsr_check_win.md)
/
[`tsr_winning_line()`](https://r-heller.github.io/tesseractR/reference/tsr_winning_line.md)
and the highlighted plot. Then show
[`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md)
on the plane containing that line, to explain how the slice view makes
an otherwise-scattered 4D line read as a straight row. 4. **Playing the
AI** — a short loop alternating
[`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)
and a fixed human move at low difficulty; explain difficulty → depth and
the pure-R performance ceiling. 5. **Evaluating positions** —
[`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
and
[`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md):
show the best next move and the win probability for a sample position.
6. **The app** — one paragraph pointing to
[`tsr_run_app()`](https://r-heller.github.io/tesseractR/reference/tsr_run_app.md)
(not run in the vignette).

**Second vignette — `vignettes/analysis.Rmd`** (“Simulation & Game
Analysis”): - Run a small
[`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md)
(random/greedy policies, modest `n_games`), show
[`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md)
and discuss first-move win rates. - Analyze one game with
[`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md),
plot the win-probability trajectory
([`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md)),
surface
[`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md)
and missed wins/blocks. - Show a
[`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md)
comparing two policies via
[`tsr_compare_profiles()`](https://r-heller.github.io/tesseractR/reference/tsr_compare_profiles.md). -
Keep `n_games` small and `method = "heuristic"` so it builds \< 60s;
note where larger runs would go (and the perf ceiling). Add
`VignetteIndexEntry{Simulation and Game Analysis}`.

## 5.4 — README (`README.Rmd` → `README.md`)

- Title line with logo slot:
  `# tesseractR <img src="man/figures/logo.png" align="right" height="139" alt="tesseractR logo" />`
  (logo added later by the hex-sticker prompt; reference is fine).
- `<!-- badges: start -->` / `<!-- badges: end -->` markers with a
  **minimal** cluster (R-CMD-check + lifecycle experimental); the full
  cluster comes from the separate Codecov prompt.
- Install-from-GitHub block
  (`remotes::install_github("r-heller/tesseractR")`).
- A short runnable example: new board → a few moves →
  [`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md).
- One line on the Shiny app.
- Build with
  [`devtools::build_readme()`](https://devtools.r-lib.org/reference/build_readme.html).

## 5.5 — pkgdown (`_pkgdown.yml`)

- `url: https://r-heller.github.io/tesseractR/`
- `template:` with a purple-accented bootswatch/theme to match the
  suite.
- `reference:` grouped:
  - **Board:** `tsr_new_board`, `is_ttt_board`
  - **Moves & Status:** `tsr_move`, `tsr_undo`, `tsr_legal_moves`,
    `tsr_check_win`, `tsr_winning_line`, `tsr_is_full`, `tsr_status`
  - **AI:** `tsr_ai_move`
  - **Evaluation:** `tsr_evaluate`, `tsr_win_prob`, `tsr_rate_moves`
  - **Simulation:** `tsr_play_game`, `tsr_simulate`, `tsr_opening_stats`
  - **Analysis:** `tsr_analyze_game`, `tsr_turning_points`,
    `tsr_game_summary`, `tsr_behavior_profile`, `tsr_compare_profiles`,
    `tsr_plot_winprob`
  - **Visualization:** `tsr_plot`, `tsr_plot_slice`,
    `autoplot.ttt_board`
  - **App:** `tsr_run_app`
- `articles:` listing both vignettes (Getting Started, Simulation & Game
  Analysis).
- Confirm **every** exported function appears — cross-check against
  STATE.md’s registry.

## 5.6 — NEWS.md

``` markdown
# tesseractR 0.1.0

## Initial release

* Game engine for 4D tic-tac-toe on a 4x4x4x4 hypercube with win detection
  across all 272 winning lines (`tsr_new_board()`, `tsr_move()`, `tsr_undo()`,
  `tsr_legal_moves()`, `tsr_check_win()`, `tsr_winning_line()`, `tsr_is_full()`,
  `tsr_status()`).
* Depth-limited negamax AI opponent with adjustable difficulty (`tsr_ai_move()`).
* Position evaluation and calibrated win probability (`tsr_evaluate()`,
  `tsr_win_prob()`), plus per-move ratings identifying the best next move
  (`tsr_rate_moves()`).
* Self-play simulation and opening/strategy statistics (`tsr_play_game()`,
  `tsr_simulate()`, `tsr_opening_stats()`).
* Game analysis and play-behavior analytics: move-by-move evaluation, turning
  points, missed wins/blocks, regret, and behavioral profiling
  (`tsr_analyze_game()`, `tsr_turning_points()`, `tsr_game_summary()`,
  `tsr_behavior_profile()`, `tsr_compare_profiles()`, `tsr_plot_winprob()`).
* ggplot2 visualization of the hypercube as a grid of boards (`tsr_plot()`,
  `autoplot()` method), plus a 2D slice view fixing one axis (`tsr_plot_slice()`)
  and a 3D plotly cube view in the app.
* Interactive Shiny application with real-time move evaluation and a game-analysis
  panel (`tsr_run_app()`).
```

------------------------------------------------------------------------

## Tests

- `tests/testthat/test-app.R` (lightweight): `tsr_run_app` errors
  cleanly when `shiny` is not available (use
  `expect_snapshot(error = TRUE)` guarded, or test the requireNamespace
  branch via a mock); confirm `app.R` **sources without error** in a
  clean environment (`source(system.file(...), local = TRUE)` does not
  throw). Do **not** launch the app in tests.
- Confirm `app.R` contains no `library(`/`require(` calls (grep
  assertion in a test or a manual check noted in STATE.md).
- Confirm the Cube (3D) view is guarded by
  [`requireNamespace("plotly")`](https://plotly-r.com) and the app’s two
  ggplot views work with plotly absent (note the manual verification in
  STATE.md if it can’t be asserted headlessly).

------------------------------------------------------------------------

## Done when

[`tsr_run_app()`](https://r-heller.github.io/tesseractR/reference/tsr_run_app.md)
implemented, exported, documented; app sources cleanly; no
[`library()`](https://rdrr.io/r/base/library.html) in app.

Vignette builds \< 60s with no internet.

README.Rmd builds to README.md; install + example present.

`_pkgdown.yml` lists every exported function;
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
runs clean.

NEWS.md complete.

App test green.

## On completion

Update `STATE.md`: S5 → `DONE`, AUDIT_REFINE_LOOP → `TODO`. Report the
audit loop is runnable.

------------------------------------------------------------------------

# AUDIT — Refine Loop (Final Gate)

**Depends on:** all stacks (S0–S5) · **Unlocks:** submission

The package is feature-complete. This stack runs the
**audit-before-fix** discipline and the mandatory
`R CMD check --as-cran` iteration loop until the result is **0 errors, 0
warnings, 0 notes** (modulo the expected “New submission” note). Do not
declare done early.

------------------------------------------------------------------------

## Phase A — Audit (catalogue before you touch anything)

Run a full read-through and diagnostics pass. **Do not fix yet** —
produce a numbered issue list first. For each finding: reproduce it,
quote the offending code, state the root cause.

### A.1 — Static sweep over `R/` and `inst/shiny/`

Grep for every suite violation and record hits: - `library(` /
`require(` anywhere (including `app.R`) → must be zero. - `T,` / `F,` /
`= T)` / `= F)` (the `T`/`F` literal trap) → must be zero. - `:::` →
zero (no cross-package internals). - `cat(` / bare `print(` outside the
registered `print.ttt_board` method → zero. - `setwd(` / hardcoded paths
(`/home/`, `/Users/`, `C:\\`) → zero. - `sapply(` → replace with
`vapply`. - `1:length(` / `1:nrow(` / `1:ncol(` →
`seq_along`/`seq_len`. - `class(x) ==` →
[`inherits()`](https://rdrr.io/r/base/class.html). - `<<-` outside
reactive contexts in `app.R` → zero. - `options(`/`par(` without
[`on.exit()`](https://rdrr.io/r/base/on.exit.html) restoration → fix.

### A.2 — Type-stability audit

For every exported accessor, trace all return paths. Confirm empty
results are typed-empty (`integer(0)`, 0-row tibble), never `NULL`.
Specifically re-verify: `tsr_legal_moves`, `tsr_winning_line`,
`tsr_status`.

### A.3 — Immutability audit

Confirm `tsr_move`/`tsr_undo`/`tsr_ai_move` never mutate their input
board. Add/keep a regression test if any path is suspect.

### A.4 — Documentation completeness

Every exported function has: title, `@description`, `@param` for
**every** argument (names matching the signature exactly), `@return`
stating the class/type, `@export`, runnable `@examples`. S3 methods use
`@method`, not `@export name.class`. Examples \> 5s wrapped in
`\donttest{}`.

### A.5 — Dependency hygiene

- Every `Imports` package has at least one `pkg::` use in `R/` (prune
  orphans).
- Every `pkg::` used in `R/` is declared in `Imports`/`Suggests`.
- `shiny`/`bslib`/`plotly` are in **Suggests** and guarded by
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).
- `stats` is in `Imports` if
  [`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md)/calibration
  use `stats::` (CI, `glm`, `plogis`).
- `withr` is in `Suggests` (used for RNG isolation in simulation and
  tests).
- No `LazyData` (there is no `data/`; the only data is internal
  `R/sysdata.rda`).

### A.5b — Internal data & calibration

- `R/sysdata.rda` exists (the `.tsr_calibration` object from S6’s
  `data-raw/calibration.R`).
- `tsr_win_prob(method = "heuristic")` reads it and falls back
  gracefully if absent.
- `data-raw/` is in `.Rbuildignore` (not shipped).
- `R/sysdata.rda` is small; no large simulation dumps committed.

### A.6 — Win-line cache audit

Confirm `.tsr_win_lines()` caches in `.tsr_cache`, computes once, writes
**nothing** to disk, uses no `<<-`. Confirm the count assertion (272) is
intact.

Write the full catalogue into `STATE.md` under “Known Issues /
Deviations Log” before fixing.

------------------------------------------------------------------------

## Phase B — Fix (root cause, one finding at a time)

For each catalogued issue: apply the **TDD discipline** where it fits —
write/confirm a failing test that reproduces the bug, fix the root
cause, confirm the test passes, keep the test as a regression guard.
Never suppress a warning/note; fix what produces it.

------------------------------------------------------------------------

## Phase C — The mandatory check loop

    REPEAT:
      1. devtools::document()
      2. devtools::test()                 # all green, no skips beyond intended
      3. devtools::build_vignettes()      # builds clean, < 60s
      4. devtools::check(args = c("--as-cran", "--no-manual"))
      5. IF errors > 0 OR warnings > 0      → fix root cause, GOTO 1
      6. IF notes > 0 AND note is fixable   → fix, GOTO 1
      7. IF only note is "New submission"   → ACCEPT
      8. DONE

If `_build.R` exists in the repo root, prefer `Rscript _build.R` as the
canonical runner.

### Common notes — pre-emptive fixes

| Note | Fix |
|----|----|
| “no visible binding for global variable” in plots | use `.data$col` in every `aes()`; `@importFrom rlang .data` present |
| “Undefined global functions or variables: .data / %\|\|%” | `@importFrom rlang .data %\|\|%` in `tesseractR-package.R` |
| Examples \> 5s (AI depth, app) | wrap in `\donttest{}` |
| “Namespace dependency not required” | prune orphan `Imports` |
| “LazyData without data directory” | remove `LazyData` from DESCRIPTION |
| Non-standard top-level files | add to `.Rbuildignore` |
| S3 method shown with full name | `@method print ttt_board` not `@export print.ttt_board` |
| partial argument match warnings | spell arguments in full |

------------------------------------------------------------------------

## Phase D — Post-check verification

- [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
  runs clean; every exported function (cross-checked against the
  STATE.md registry) appears in the reference index; both vignettes
  render.

- Both vignettes build \< 60s with `method = "heuristic"` and small
  `n_games`; no rollouts in vignettes. Confirm no `\donttest{}`-only
  path is the sole demonstration of a core function.

- RNG isolation: confirm no function leaves global `.Random.seed`
  altered (simulation uses `withr` internally); a regression test guards
  this.

- [`devtools::spell_check()`](https://devtools.r-lib.org/reference/spell_check.html)
  — fix genuine typos; add domain terms (e.g. `hypercube`, `negamax`,
  `tic`, `ggplot2`, `pkgdown`, `roxygen`, `Shiny`, `plotly`,
  `tesseractR`, `Heller`, `ORCID`, `logistic`, `calibrated`, `rollout`,
  `rollouts`, `winrate`, `Okabe`, `Ito`) to `inst/WORDLIST`.

- Build the tarball
  ([`devtools::build()`](https://devtools.r-lib.org/reference/build.html));
  confirm size is small (this package has no data — should be well under
  1 MB).

- Write/refresh `cran-comments.md`:

  ``` markdown
  ## R CMD check results
  0 errors | 0 warnings | 0 notes

  ## Test environments
  * local: [OS, R version]
  * GitHub Actions: ubuntu (release), macos (release), windows (release)

  ## This is a new submission.
  ```

------------------------------------------------------------------------

## Phase D.5 — Authorship & history audit (before merging to main)

- Verify **no AI authorship** anywhere in the git history:

  ``` bash
  git log --format='%an <%ae>%n%b' | grep -i -E 'claude|co-authored-by|generated with' && echo "FOUND — must fix" || echo "clean"
  ```

  Every commit author must be `Raban Heller <raban.heller@charite.de>`.
  No `Co-Authored-By`, no “Generated with” lines. If any slipped in,
  **stop and report** — do not rewrite shared history without Raban’s
  explicit approval (a force-push to clean history needs his sign-off).

- Grep the source for stray AI references in shipped files (`R/`,
  `man/`, `vignettes/`, `DESCRIPTION`, `NEWS.md`, `README.*`): none
  permitted.

- Confirm `DESCRIPTION` `Authors@R` lists Raban as sole `aut`/`cre` with
  his ORCID.

## Phase D.6 — Merge to main (gated on approval)

Only after the check is clean **and** Phase D.5 passes: - Push the final
`build/tesseractR` state to `origin`. - Open a PR `build/tesseractR` →
`main`. Summarize the readiness report in the PR body. - **Do not
self-merge.** The merge to `main` requires Raban’s explicit approval.
Never force-push, never bypass branch protection. If asked to merge,
confirm first, then merge (no squash that would forge a single AI-tagged
commit — preserve the per-stack authored history).

------------------------------------------------------------------------

## Phase E — Final report

Print:

    ═══════════════════════════════════════════════
      tesseractR — Submission Readiness Report
    ═══════════════════════════════════════════════
    ## R CMD check:  0 errors | 0 warnings | N notes
    ## Tests:        X passed, Y skipped, 0 failed
    ## Coverage:     [% if covr run]
    ## Tarball size: [X KB]
    ## Exported fns: [list — must match STATE.md registry]
    ## Win-line count verified: 272
    ## Issues fixed this loop:
      1. ...
    ## Remaining manual items:
      - logo (separate hex-sticker prompt)
      - Codecov wiring (separate prompt)
      - GitHub Actions workflows (R-CMD-check, pkgdown)
    ═══════════════════════════════════════════════

------------------------------------------------------------------------

## Done when

`R CMD check --as-cran` → 0 errors / 0 warnings / 0 notes (modulo “New
submission”).

[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
clean; all exports in reference index.

Vignettes build; spell check clean; WORDLIST updated.

`cran-comments.md` written.

**Git history clean of AI authorship**; every commit by Raban Heller
(Phase D.5 passed).

Final `build/tesseractR` pushed; PR to `main` opened; **merge awaits
Raban’s approval** (not self-merged).

STATE.md: AUDIT_REFINE_LOOP → `DONE`; final report printed.

**Do not declare the package ready until the check loop terminates
clean.**

## Out of scope for this loop (handled by separate suite prompts)

- Hex sticker / logo PNG.
- Codecov integration + full badge cluster.
- GitHub Actions CI workflows.
- Tidyverse design-alignment deep pass (optional follow-up).

------------------------------------------------------------------------
