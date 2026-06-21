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
