# tesseractR — Session Handoff

> Picking this up later. Read this first, then `git status` + `git log --oneline -5`.

## Where things stand

### Local + remote source (`main`)
- `main` is at **`c0d0b66`** locally and on `origin/main`.
- 11 commits total since the initial commit: S0–S5, audit pass, roadmap cleanup,
  and the themakR + icons + vignette rewrite.
- Working tree clean. SSH remote (`git@github.com:r-heller/tesseractR.git`).

### Package state
- `R CMD check --as-cran` was **0 errors / 0 warnings / 0 notes** on the last
  full run (iter 3, after the logo, themakR template, and rewritten vignettes).
- `devtools::test()`: **151 passed / 0 failed / 0 skipped**.
- `devtools::spell_check()`: clean against `inst/WORDLIST`.
- `devtools::build_vignettes()`: **~54s** (under the 60s budget).
- Calibration: `R/sysdata.rda` fitted (`a ≈ 0, b ≈ 114, n = 480`); provisional
  defaults remain as fallback.

### pkgdown / GitHub Pages
- **Local pkgdown build works** under the themakR template
  (`pkgdown::build_site(install = FALSE, devel = FALSE)`).
- **`origin/gh-pages` is stale**: still at `28a6622` ("Rebuild pkgdown site
  (drop build artifacts)"). The follow-up themakR+icons redeploy was
  interrupted before it pushed.
- **Pages 404**: `curl -sI https://r-heller.github.io/tesseractR/` returns 404
  and `GET /repos/r-heller/tesseractR/pages` returns Not Found. The repo
  Pages source is not yet wired to `gh-pages`.

## How to resume

### 1. Restart the gh-pages deploy
```r
Rscript -e 'pkgdown::deploy_to_branch(branch = "gh-pages",
  commit_message = "Rebuild pkgdown site (themakR theme + icons)")'
```
This builds locally and force-pushes to `gh-pages` (the expected pkgdown
flow — main is untouched).

### 2. Activate GitHub Pages on `gh-pages`
GitHub web UI → **Settings → Pages → Source: Deploy from a branch →
branch `gh-pages`, folder `/ (root)`**. Save. First serve takes a couple
of minutes.

Verify:
```bash
curl -sI https://r-heller.github.io/tesseractR/ | head -2   # expect 200
```

### 3. Pick up the open tasks
The TaskList carries four items still flagged in progress / pending:

- **#12 Audit refinement loops** — `in_progress`. Iter 3 was clean; if any
  new content is added (icons, vignette tweaks), re-run
  `devtools::check(args = c("--as-cran", "--no-manual"))` and spell.
- **#13 Push to main on the fly** — `pending` (rolling). Every substantive
  change so far is pushed; keep doing that for new ones.
- **#14 Apply themakR vignette theme** — `pending` but functionally done.
  Only remaining step is the gh-pages redeploy (see step 1).

### 4. Optional follow-ups still open
- **Author identity rewrite**: every commit on `main` is currently
  `R. Heller <58561665+r-heller@users.noreply.github.com>` because the
  shell has `GIT_AUTHOR_*`/`GIT_COMMITTER_*` env vars set. No AI
  attribution anywhere. If you want the academic email
  (`raban.heller@charite.de`) on the published history, that's a rebase
  with `--author=` and a force-push of `main` — explicit sign-off required.
- **CRAN submission**: `cran-comments.md` is ready. Tarball builds with
  `devtools::build()` (~168 KB).
- **GitHub Actions** (`R-CMD-check.yaml`, `pkgdown.yaml`) and
  **Codecov** integration — deferred per orchestrator.
- **Logo**: `man/figures/logo.png` + favicons committed. Also a
  user-provided `tesseractR_icon.svg` lives at repo root; `.Rbuildignore`
  excludes `^.*\.svg$` so it doesn't ship in the tarball. Move it under
  `man/figures/` if you want it tracked alongside the PNG.

## Logged deviations (carry forward)

- **Win-line count is 520, not 272.** The roadmap asserted 272 lines but the
  standard formula `((n+2)^d − n^d)/2` for `n = d = 4` gives 520. 272 is
  3-in-a-row on 3^4. Geometry honored; copy in DESCRIPTION / NEWS / vignettes
  uses 520.
- **No remote auth at session start.** Resolved by switching `origin` from
  HTTPS to SSH (`git@github.com:r-heller/tesseractR.git`). SSH key
  `~/.ssh/id_ed25519.pub` authenticates as `r-heller`.

## File map (what was built where)

```
R/
  tesseractR-package.R   S0 — package doc
  zzz.R                  S0 — .tsr_cache env
  tsr_lines.R            S1 — 520 win lines, cached
  tsr_board.R            S2 — class + new + predicate
  tsr_move.R             S2 — move / undo / legal_moves
  tsr_status.R           S2 — check_win / winning_line / is_full / status
  tsr_evaluate.R         S3 — eval / win_prob / rate_moves + raw + rollout
  tsr_ai.R               S3 — tsr_ai_move + negamax
  tsr_simulate.R         S6 — play_game / simulate / opening_stats + tsr_game
  tsr_analyze.R          S7 — analyze_game / turning_points / game_summary /
                                behavior_profile / compare_profiles / plot_winprob
  tsr_plot.R             S4 — plot / plot_slice / autoplot + .tsr_layout
  tsr_print.R            S4 — format / print / summary S3 methods
  tsr_run_app.R          S5 — Shiny launcher
  sysdata.rda            S6 — fitted .tsr_calibration

inst/shiny/tesseractR/   S5 — app.R + www/custom.css + www/logo.png
data-raw/calibration.R   S6 — calibration fit script (dev-only)
vignettes/               S5 — tesseractR.Rmd + analysis.Rmd
_pkgdown.yml             S5 — themakR template, grouped reference
NEWS.md, README.Rmd      S5
man/figures/logo.png     icon (PNG, 600 dpi source)
pkgdown/favicon/         themakR-generated favicon set
```
