# tesseractR — Build State

> Live progress tracker. Update after **every** stack: set status, date, notes,
> and recompute the runnable set. The orchestrator reads this file first.

Last updated: 2026-06-21 — S0 complete.

---

## Stack Status

| Stack | Depends on | Status | Date | Notes |
|-------|-----------|--------|------|-------|
| S0_FOUNDATION | — | DONE | 2026-06-21 | skeleton, DESCRIPTION, MIT, zzz cache, testthat scaffolding |
| S1_GEOMETRY | S0 | TODO | | |
| S2_ENGINE | S1 | BLOCKED | | |
| S3_AI | S2 | BLOCKED | | AI + evaluation/win-prob/rate core |
| S4_VISUALIZATION | S2 | BLOCKED | | |
| S6_SIMULATION | S3 | BLOCKED | | self-play, opening stats, calibration |
| S7_ANALYSIS | S3 | BLOCKED | | game analysis + behavior analytics |
| S5_APP_SUBMISSION | S3, S4, S6, S7 | BLOCKED | | real-time eval + analysis panel |
| AUDIT_REFINE_LOOP | all | BLOCKED | | |

Status values: `TODO` (runnable now) · `BLOCKED` (deps not done) · `IN_PROGRESS` · `DONE`

---

## Runnable Set (recompute after each update)

**Currently runnable:** `S1_GEOMETRY`

Rule: a stack becomes runnable when all stacks in its "Depends on" column are `DONE`.
- S0 done → S1 runnable
- S1 done → S2 runnable
- S2 done → S3 **and** S4 runnable (independent)
- S3 done → S6 **and** S7 runnable (both need the eval core; independent)
- S3 + S4 + S6 + S7 done → S5 runnable
- S5 done → AUDIT_REFINE_LOOP runnable

Up to three parallel sessions possible after S3: S4, S6, S7 in flight together.

---

## Exported Function Registry (fill in as stacks complete)

Track every exported function here so the audit loop can verify pkgdown coverage and
NEWS completeness. Internal helpers (`.tsr_*`) are not listed.

| Function | Stack | Class/kind | Tested | Documented |
|----------|-------|-----------|--------|------------|
| `tsr_new_board()` | S2 | constructor helper | | |
| `is_ttt_board()` | S2 | predicate | | |
| `tsr_move()` | S2 | engine | | |
| `tsr_undo()` | S2 | engine | | |
| `tsr_legal_moves()` | S2 | engine | | |
| `tsr_check_win()` | S2 | status | | |
| `tsr_winning_line()` | S2 | status | | |
| `tsr_is_full()` | S2 | status | | |
| `tsr_status()` | S2 | status | | |
| `tsr_ai_move()` | S3 | AI | | |
| `tsr_evaluate()` | S3 | evaluation | | |
| `tsr_win_prob()` | S3 | evaluation | | |
| `tsr_rate_moves()` | S3 | evaluation | | |
| `tsr_play_game()` | S6 | simulation | | |
| `tsr_simulate()` | S6 | simulation | | |
| `tsr_opening_stats()` | S6 | simulation | | |
| `print.tsr_game()` | S6 | S3 method | | |
| `tsr_analyze_game()` | S7 | analysis | | |
| `tsr_turning_points()` | S7 | analysis | | |
| `tsr_game_summary()` | S7 | analysis | | |
| `tsr_behavior_profile()` | S7 | analysis | | |
| `tsr_compare_profiles()` | S7 | analysis | | |
| `tsr_plot_winprob()` | S7 | analysis (viz) | | |
| `tsr_plot()` | S4 | viz | | |
| `tsr_plot_slice()` | S4 | viz | | |
| `autoplot.ttt_board()` | S4 | viz (S3 method) | | |
| `print.ttt_board()` | S4 | S3 method | | |
| `format.ttt_board()` | S4 | S3 method | | |
| `summary.ttt_board()` | S4 | S3 method | | |
| `tsr_run_app()` | S5 | app launcher | | |

---

## Known Issues / Deviations Log

_(Record anything that deviates from the stack spec, any deferred work, or any
performance limitation discovered during the build. The audit loop reads this.)_

- _(none yet)_

---

## Decisions on file

- Variant: **simple 4D** (static `4×4×4×4`, 256 cells, 4-in-a-row). NOT the 5D multiverse variant.
- AI: **in scope** (negamax + alpha-beta, depth = difficulty).
- Evaluation core: **exported** (`tsr_evaluate`, `tsr_win_prob`, `tsr_rate_moves`) as single
  source of truth feeding AI, simulation, analysis, and the app's real-time rating.
- Win probability: **A+B** — calibrated heuristic (logistic, default, real-time) AND optional
  Monte-Carlo rollout (offline accuracy). Calibration coefficients fitted in S6, stored as
  internal data, consumed by S3 with provisional fallback.
- Simulation + game analysis + play-behavior analytics: **in scope** (S6, S7) — positions
  `tesseractR` as an analysis tool, not just a playable board.
- Compiled code: **out of scope** (pure R; Rcpp is a future option, flagged as a perf ceiling on
  the simulation/search hot paths).
- Codecov + hex sticker: handled by **separate suite prompts**, not this roadmap.
- Git: commit + push **per stack** on branch `build/tesseractR`; **main only via approved PR**
  after the audit loop is clean (honors the suite branch-only / no-force-push policy).
- Authorship: every commit by **Raban Heller** (`raban.heller@charite.de`, ORCID
  0000-0001-8006-9742). **No AI co-author trailers or attribution** anywhere — commits, code,
  docs, DESCRIPTION, NEWS.
