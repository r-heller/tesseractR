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
