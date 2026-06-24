# Validation and empty-input branches for the analysis layer.

test_that("tsr_analyze_game rejects a non-game input", {
  expect_error(tsr_analyze_game(list()), "tsr_game")
})

test_that("tsr_turning_points rejects a non-data-frame input", {
  expect_error(tsr_turning_points(42L), "data frame")
})

test_that("isTRUE_vec handles NA and logical vectors", {
  expect_equal(tesseractR:::isTRUE_vec(c(TRUE, FALSE, NA)),
               c(TRUE, FALSE, FALSE))
})

test_that("tsr_game_summary on an empty game returns NA regrets and 0.5 final", {
  g <- structure(list(
    moves = integer(0), winner = 0L, n_moves = 0L,
    policies = c(x = "empty", o = "empty"),
    final_board = tsr_new_board(), to_move = integer(0)
  ), class = "tsr_game")
  s <- tsr_game_summary(g)
  expect_equal(nrow(s), 1L)
  expect_true(is.na(s$mean_regret_x))
  expect_equal(s$decisiveness, 0)
})

test_that("tsr_behavior_profile rejects a non-list / wrong-class games arg", {
  expect_error(tsr_behavior_profile(42L), "list of")
  expect_error(tsr_behavior_profile(list(1L, 2L)), "list of")
})

test_that("tsr_behavior_profile rejects an invalid side", {
  g <- tsr_play_game("random", "random", seed = 1L)
  expect_error(tsr_behavior_profile(list(g), side = 3L), "1L")
})

test_that("tsr_behavior_profile on games with no plies for the side returns NA row", {
  # A game whose only move is by X; profiling side O yields no rows.
  g <- structure(list(
    moves = 1L, winner = 0L, n_moves = 1L,
    policies = c(x = "fixed", o = "fixed"),
    final_board = tsr_move(tsr_new_board(), cell = 1L),
    to_move = 1L
  ), class = "tsr_game")
  p <- tsr_behavior_profile(list(g), side = 2L)
  expect_equal(nrow(p), 1L)
  expect_true(is.na(p$accuracy))
  expect_equal(p$n_moves_total, 0L)
})

test_that("tsr_behavior_profile defaults the label to 'profile'", {
  g <- tsr_play_game("random", "random", seed = 1L)
  p <- tsr_behavior_profile(list(g), side = 1L)
  expect_equal(p$label, "profile")
})

test_that("tsr_compare_profiles errors when called with no profiles", {
  expect_error(tsr_compare_profiles(), "at least one")
})

test_that("tsr_plot_winprob rejects a non-data-frame input", {
  expect_error(tsr_plot_winprob(42L), "data frame")
})
