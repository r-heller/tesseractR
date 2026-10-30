# Maintenance review — 30 October 2026

## Purpose and release criteria

Provide a reusable 4D tic-tac-toe engine and an interactive Shiny game. The
maintenance milestone requires legal moves, deterministic immediate-win/block
behavior, controlled invalid-input errors, successful package checks and a
runnable installed first-use path. The existing experimental status remains.

## Findings and completed repairs

- High: coordinates, cell indices, undo counts and AI/app difficulty were
  truncated by integer conversion. Fractional values could silently select a
  different move or search depth. Validate scalar numeric, finite integer
  inputs before conversion (`R/tsr_move.R`, `R/tsr_board.R`, `R/tsr_ai.R`,
  `R/tsr_run_app.R`). Missing state/history entries now fail clearly.
- Medium: app startup removed a caller's existing difficulty environment setting.
  Restore the previous value on both success and startup failure.
- Medium: wide Shiny analysis tables pushed the whole page horizontally.
  Give their output containers a scrollable block layout within the app column.
- Packaging: exclude the linked-worktree `.git` pointer from source archives.
  Source and installed documentation retain the same supported game rules.

## Verification

On macOS arm64, R 4.6.1: the complete source suite passed (149.03 seconds).
Additional final input/app regression checks passed, including fractional,
missing, infinite, vector and overflow inputs and failed-startup restoration.
The final app-guard package check (`R CMD check --no-manual --no-tests`)
passed with Status OK, including rebuilt vignettes and examples; the full source
suite and final input regressions were run separately. A fresh installation
passed a winning-move/undo journey outside the checkout. Chromium exercised
hotseat moves, reset, an AI reply and analysis tables without page errors. The
final table CSS also passed a no-horizontal-page-overflow assertion and visual
inspection. This final CSS is verified by the app test rather than R CMD check.
The tests use actual game operations, not just validation-function mocks.

## First use

```r
install.packages(c("cli", "ggplot2", "rlang", "tibble", "shiny"))
```

From this checkout run `R CMD INSTALL .`, then in a new R session:

```r
library(tesseractR)
b <- tsr_move(tsr_new_board(), cell = 1L)
b <- tsr_move(b, cell = tsr_ai_move(b, difficulty = 1L))
tsr_plot(b)
tsr_run_app(difficulty = 1L)
```

Coordinates use 0:3; linear cells use 1:256. Depth 4 remains an expensive
pure-R search, with no hard latency guarantee. Use difficulty 1 for first use.

## Remaining roadmap and release boundary

The essential input-integrity repairs are complete. Next, benchmark stronger
search levels on representative mid-game boards before promising interactive
latency; any compiled engine must retain deterministic rules and tie-breaking.
Remote CI, Windows/Linux and CRAN submission are unverified for this candidate.
No package was submitted or pushed. After review, publish the candidate through
the existing check matrix and inspect that exact commit's results.
