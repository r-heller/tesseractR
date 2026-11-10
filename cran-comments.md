## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Raban Heller <raban.heller@uni-ulm.de>'
  New submission

  This is the first submission of tesseractR to CRAN.

## Test environments

* local: macOS (aarch64), R 4.6.1, `R CMD check --as-cran --no-manual`
  (no LaTeX installation locally, so the PDF manual was not built)
* GitHub Actions (r-lib/actions v2):
  * macos-latest (R release)
  * windows-latest (R release)
  * ubuntu-latest (R devel, R release, R oldrel-1)

## Notes for the reviewer

* The AI opponent is a depth-limited negamax search in pure R. Examples that
  run a deeper search, rollouts or whole-game analysis are wrapped in
  `\donttest{}`; they use a shallow search, two rollouts and a short decisive
  game, so each takes at most about six seconds (all `\donttest{}` examples
  together about 30 seconds). Longer simulations in the tests are skipped on
  CRAN.
* 'shiny', 'bslib' and 'plotly' are optional (Suggests) and checked with
  `requireNamespace()` before use. The `tsr_run_app()` example runs only in
  interactive sessions.
* `tsr_run_app()` sets one environment variable for the app session and
  restores the previous value on exit.

## This is a new submission.
