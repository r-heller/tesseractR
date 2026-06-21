test_that("tsr_analyze_game on a short game returns one row per ply", {
  g <- tsr_play_game("random", "random", seed = 1L)
  a <- tsr_analyze_game(g)
  expect_s3_class(a, "tbl_df")
  expect_equal(nrow(a), g$n_moves)
  expect_named(a, c("ply", "player", "cell", "i", "j", "k", "l",
                    "win_prob_before", "win_prob_after", "delta",
                    "best_cell", "best_delta", "regret",
                    "is_best", "missed_win", "missed_block", "is_turning_point"))
  expect_true(all(a$win_prob_before >= 0 & a$win_prob_before <= 1))
  expect_true(all(a$win_prob_after  >= 0 & a$win_prob_after  <= 1))
  expect_true(all(a$regret >= 0))
})

test_that("missed_win is TRUE on a ply where a winning move was available", {
  # X has 3 on cells 1,2,3; X to move with 4 winning. Then we manually
  # construct a hand-coded game that plays cell 5 instead of 4.
  b <- tsr_new_board()
  moves <- c(1L, 17L, 2L, 18L, 3L, 19L, 5L)
  g <- structure(list(
    moves = as.integer(moves),
    winner = 0L,
    n_moves = length(moves),
    policies = c(x = "fixed", o = "fixed"),
    final_board = Reduce(function(acc, m) tsr_move(acc, cell = m), moves,
                         tsr_new_board()),
    to_move = c(1L, 2L, 1L, 2L, 1L, 2L, 1L)
  ), class = "tsr_game")
  a <- tsr_analyze_game(g)
  expect_true(a$missed_win[a$ply == 7L])
})

test_that("missed_block is TRUE when opponent threat exists and isn't taken", {
  # O builds 17,18,19. X to move at ply 7 plays elsewhere → missed block.
  moves <- c(50L, 17L, 51L, 18L, 80L, 19L, 100L)
  g <- structure(list(
    moves = as.integer(moves),
    winner = 0L,
    n_moves = length(moves),
    policies = c(x = "fixed", o = "fixed"),
    final_board = Reduce(function(acc, m) tsr_move(acc, cell = m), moves,
                         tsr_new_board()),
    to_move = c(1L, 2L, 1L, 2L, 1L, 2L, 1L)
  ), class = "tsr_game")
  a <- tsr_analyze_game(g)
  expect_true(a$missed_block[a$ply == 7L])
})

test_that("tsr_turning_points returns the subset; empty input stays empty", {
  g <- tsr_play_game("random", "random", seed = 3L)
  a <- tsr_analyze_game(g)
  tp <- tsr_turning_points(a)
  expect_true(all(tp$is_turning_point))
  expect_s3_class(tp, "tbl_df")

  empty <- tsr_analyze_game(structure(list(
    moves = integer(0), winner = 0L, n_moves = 0L,
    policies = c(x = "empty", o = "empty"),
    final_board = tsr_new_board(), to_move = integer(0)
  ), class = "tsr_game"))
  expect_equal(nrow(empty), 0L)
  expect_equal(nrow(tsr_turning_points(empty)), 0L)
})

test_that("tsr_game_summary returns the documented one-row tibble", {
  g <- tsr_play_game("random", "random", seed = 1L)
  s <- tsr_game_summary(g)
  expect_equal(nrow(s), 1L)
  expect_named(s, c("winner", "n_moves", "n_missed_wins_x", "n_missed_wins_o",
                    "n_missed_blocks_x", "n_missed_blocks_o",
                    "mean_regret_x", "mean_regret_o",
                    "n_turning_points", "decisiveness"))
})

test_that("tsr_behavior_profile returns the documented row and rates in [0,1]", {
  g1 <- tsr_play_game("random", "random", seed = 1L)
  g2 <- tsr_play_game("random", "random", seed = 2L)
  p <- tsr_behavior_profile(list(g1, g2), side = 1L, label = "random")
  expect_equal(nrow(p), 1L)
  for (col in c("accuracy", "blunder_rate", "aggression")) {
    v <- p[[col]]
    if (!is.na(v)) expect_true(v >= 0 && v <= 1)
  }
})

test_that("tsr_compare_profiles row-binds and errors on column mismatch", {
  g <- tsr_play_game("random", "random", seed = 1L)
  p1 <- tsr_behavior_profile(list(g), side = 1L, label = "a")
  p2 <- tsr_behavior_profile(list(g), side = 2L, label = "b")
  expect_equal(nrow(tsr_compare_profiles(p1, p2)), 2L)
  p3 <- p1; p3$extra <- 0
  expect_error(tsr_compare_profiles(p1, p3), "same columns")
})

test_that("tsr_plot_winprob returns a ggplot", {
  g <- tsr_play_game("random", "random", seed = 1L)
  expect_s3_class(tsr_plot_winprob(tsr_analyze_game(g)), "ggplot")
})
