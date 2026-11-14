## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'R. Heller <raban.heller@uni-ulm.de>'
  New submission

  This is the first submission of tesseractR to CRAN.

## Test environments

* local: macOS (aarch64), R 4.6.1, `R CMD check --as-cran`, including
  the PDF manual with TinyTeX (TeX Live 2026) and modern Tidy.
* The exact source archive passed with 323 test assertions and five explicit
  CRAN skips. A separate focused AI/app run passed 62 assertions, including
  the unrestricted depth-three search skipped in the CRAN run.
* GitHub Actions is configured for macOS and Windows R release, and Ubuntu
  R devel, release and oldrel-1. Hosted results for this revision are tracked
  separately from the local qualification above.

## Notes for the reviewer

* The AI opponent is a depth-limited negamax search in pure R. Examples that
  run deeper searches, rollouts or whole-game analysis use `\donttest{}`;
  the full local check also ran those examples successfully. Unrestricted
  search time depends on the board and host. Longer simulation tests are
  skipped on CRAN.
* Optional `time_limit` uses cooperative iterative deepening. The default
  remains unrestricted; the app requests a 0.5-second budget. Deterministic
  clock tests verify fallback and completed-depth behavior without relying
  on fragile timing thresholds. Scheduling and single-operation overshoot
  are documented; this is not an asynchronous or hard real-time guarantee.
* 'shiny', 'bslib' and 'plotly' are optional (Suggests) and checked with
  `requireNamespace()` before use. The `tsr_run_app()` example runs only in
  interactive sessions.
* `tsr_run_app()` sets one environment variable for the app session and
  restores the previous value on exit.

## This is a new submission.
