# tesseractR 0.2.0

## CRAN preparation

* Maintainer address changed to raban.heller@uni-ulm.de.
* The package help page uses the vector logo, which is now shipped in the
  source package; the build no longer leaves an empty `tools/` directory.
* Added `cran-comments.md` details for the first submission.
* Examples that analyse games now use a short decisive game, and the slow
  `\donttest{}` examples use fewer rollouts and a shallower search, so each
  example finishes in a few seconds.

## Bug fixes

* Move coordinates, cell indices, undo counts and AI difficulty now reject
  fractional, missing and non-finite values before integer conversion.
* Missing board-state and history entries now produce controlled validation errors.
* `tsr_run_app()` restores a pre-existing `TESSERACTR_INIT_DIFFICULTY`
  environment variable when the app stops or fails to start.

# tesseractR 0.1.0

## Initial release

* Game engine for 4D tic-tac-toe on a 4x4x4x4 hypercube with win detection
  across all 520 winning lines (`tsr_new_board()`, `tsr_move()`, `tsr_undo()`,
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
