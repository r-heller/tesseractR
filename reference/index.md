# Package index

## Board

- [`tsr_new_board()`](https://r-heller.github.io/tesseractR/reference/tsr_new_board.md)
  : Create a new, empty 4D tic-tac-toe board

- [`is_ttt_board()`](https://r-heller.github.io/tesseractR/reference/is_ttt_board.md)
  :

  Test whether an object is a `ttt_board`

## Moves and status

- [`tsr_move()`](https://r-heller.github.io/tesseractR/reference/tsr_move.md)
  : Make a move on a 4D tic-tac-toe board
- [`tsr_undo()`](https://r-heller.github.io/tesseractR/reference/tsr_undo.md)
  : Undo the most recent moves on a board
- [`tsr_legal_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_legal_moves.md)
  : Legal moves on a board
- [`tsr_check_win()`](https://r-heller.github.io/tesseractR/reference/tsr_check_win.md)
  : Detect a winner on the board
- [`tsr_winning_line()`](https://r-heller.github.io/tesseractR/reference/tsr_winning_line.md)
  : Indices of the first winning line on the board
- [`tsr_is_full()`](https://r-heller.github.io/tesseractR/reference/tsr_is_full.md)
  : Whether the board has no empty cells
- [`tsr_status()`](https://r-heller.github.io/tesseractR/reference/tsr_status.md)
  : Structured one-row status for a board

## AI

- [`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)
  : AI move on a 4D tic-tac-toe board

## Evaluation

- [`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
  : Evaluate a position
- [`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
  : Calibrated win probability for a position
- [`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md)
  : Rate every legal move from a position

## Simulation

- [`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md)
  : Play a single game between two policies
- [`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md)
  : Simulate many games between two policies
- [`tsr_opening_stats()`](https://r-heller.github.io/tesseractR/reference/tsr_opening_stats.md)
  : Opening statistics from a simulation
- [`print(`*`<tsr_game>`*`)`](https://r-heller.github.io/tesseractR/reference/print.tsr_game.md)
  : Print method for a played game

## Analysis

- [`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md)
  : Analyze a played game move by move
- [`tsr_turning_points()`](https://r-heller.github.io/tesseractR/reference/tsr_turning_points.md)
  : Turning points from a game analysis
- [`tsr_game_summary()`](https://r-heller.github.io/tesseractR/reference/tsr_game_summary.md)
  : One-row summary for a played game
- [`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md)
  : Aggregate behavioral profile for a side across many games
- [`tsr_compare_profiles()`](https://r-heller.github.io/tesseractR/reference/tsr_compare_profiles.md)
  : Combine multiple behavioral profiles
- [`tsr_plot_winprob()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_winprob.md)
  : Win-probability trajectory for a game

## Visualization

- [`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md)
  : Plot a 4D tic-tac-toe board as a 4x4 grid of 4x4 boards
- [`tsr_plot_slice()`](https://r-heller.github.io/tesseractR/reference/tsr_plot_slice.md)
  : Plot a 3D slice of a 4D tic-tac-toe board
- [`autoplot(`*`<ttt_board>`*`)`](https://r-heller.github.io/tesseractR/reference/autoplot.ttt_board.md)
  : Autoplot method for a 4D tic-tac-toe board
- [`format(`*`<ttt_board>`*`)`](https://r-heller.github.io/tesseractR/reference/ttt_board-methods.md)
  [`print(`*`<ttt_board>`*`)`](https://r-heller.github.io/tesseractR/reference/ttt_board-methods.md)
  [`summary(`*`<ttt_board>`*`)`](https://r-heller.github.io/tesseractR/reference/ttt_board-methods.md)
  : Print methods for a 4D tic-tac-toe board

## App

- [`tsr_run_app()`](https://r-heller.github.io/tesseractR/reference/tsr_run_app.md)
  : Launch the tesseractR Shiny app
