# Changelog

## tesseractR 0.1.0

### Initial release

- Game engine for 4D tic-tac-toe on a 4x4x4x4 hypercube with win
  detection across all 520 winning lines
  ([`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md),
  [`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md),
  [`tsr_undo()`](https://r-heller.github.io/tesseractR/reference/tsr_undo.md),
  [`tsr_legal_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_legal_moves.md),
  [`tsr_check_win()`](https://r-heller.github.io/tesseractR/reference/tsr_check_win.md),
  [`tsr_winning_line()`](https://r-heller.github.io/tesseractR/reference/tsr_winning_line.md),
  [`tsr_is_full()`](https://r-heller.github.io/tesseractR/reference/tsr_is_full.md),
  [`tsr_status()`](https://r-heller.github.io/tesseractR/reference/tsr_status.md)).
- Depth-limited negamax AI opponent with adjustable difficulty
  ([`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)).
- Position evaluation and calibrated win probability
  ([`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md),
  [`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)),
  plus per-move ratings identifying the best next move
  ([`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md)).
- Self-play simulation and opening/strategy statistics
  ([`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md),
  [`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md),
  [`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md)).
- Game analysis and play-behavior analytics: move-by-move evaluation,
  turning points, missed wins/blocks, regret, and behavioral profiling
  ([`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md),
  [`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md),
  [`tsr_game_summary()`](https://r-heller.github.io/tesseractR/reference/tsr_game_summary.md),
  [`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md),
  [`tsr_compare_profiles()`](https://r-heller.github.io/tesseractR/reference/tsr_compare_profiles.md),
  [`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md)).
- ggplot2 visualization of the hypercube as a grid of boards
  ([`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md),
  `autoplot()` method), plus a 2D slice view fixing one axis
  ([`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md))
  and a 3D plotly cube view in the app.
- Interactive Shiny application with real-time move evaluation and a
  game-analysis panel
  ([`tsr_run_app()`](https://r-heller.github.io/tesseractR/reference/tsr_run_app.md)).
