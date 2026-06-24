# Policy dispatch and validation branches for the simulation layer.

test_that(".tsr_policy resolves all built-in string policies", {
  expect_type(tesseractR:::.tsr_policy("random"), "closure")
  expect_type(tesseractR:::.tsr_policy("greedy"), "closure")
  expect_type(tesseractR:::.tsr_policy("ai"), "closure")
  expect_type(tesseractR:::.tsr_policy("ai3"), "closure")
})

test_that(".tsr_policy passes through a function unchanged", {
  f <- function(board) tsr_legal_moves(board)[1L]
  expect_identical(tesseractR:::.tsr_policy(f), f)
})

test_that(".tsr_policy errors on an unknown spec", {
  expect_error(tesseractR:::.tsr_policy("nonsense"), "Unknown policy")
})

test_that(".tsr_policy_label labels functions, strings, and unknowns", {
  expect_equal(tesseractR:::.tsr_policy_label(function(b) 1L), "custom")
  expect_equal(tesseractR:::.tsr_policy_label("greedy"), "greedy")
  expect_equal(tesseractR:::.tsr_policy_label(42L), "unknown")
})

test_that("greedy policy returns a legal move", {
  pol <- tesseractR:::.tsr_policy_greedy()
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)
  m <- pol(b)
  expect_true(m %in% tsr_legal_moves(b))
})

test_that("ai policy returns a legal move at the requested depth", {
  pol <- tesseractR:::.tsr_policy_ai(1L)
  b <- tsr_new_board()
  expect_true(pol(b) %in% tsr_legal_moves(b))
})

test_that("tsr_play_game accepts a custom function policy", {
  first_legal <- function(board) tsr_legal_moves(board)[1L]
  g <- tsr_play_game(first_legal, "random", seed = 1L)
  expect_s3_class(g, "tsr_game")
  expect_equal(g$policies[["x"]], "custom")
})

test_that("tsr_play_game with a greedy side runs to completion", {
  g <- tsr_play_game("greedy", "random", seed = 5L)
  expect_true(g$winner %in% c(0L, 1L, 2L))
})

test_that("tsr_simulate rejects a non-positive n_games", {
  expect_error(tsr_simulate("random", "random", n_games = 0L, verbose = FALSE),
               "positive")
  expect_error(tsr_simulate("random", "random", n_games = c(1L, 2L),
                            verbose = FALSE), "positive")
})

test_that("tsr_simulate without a seed still returns the documented tibble", {
  set.seed(11L)
  s <- tsr_simulate("random", "random", n_games = 3L, verbose = FALSE)
  expect_equal(nrow(s), 3L)
  expect_true(all(s$winner %in% c(0L, 1L, 2L)))
})

test_that("tsr_opening_stats rejects a non-data-frame input", {
  expect_error(tsr_opening_stats(list()), "data frame")
})

test_that("tsr_opening_stats errors when the grouping column is absent", {
  s <- tsr_simulate("random", "random", n_games = 3L, seed = 1L, verbose = FALSE)
  expect_error(tsr_opening_stats(s, by = "difficulty"), "not found")
})

test_that("print.tsr_game renders the draw result branch", {
  g <- tsr_play_game("random", "random", seed = 1L)
  g$winner <- 0L
  txt <- cli::cli_fmt(print(g))
  expect_true(any(grepl("draw", txt)))
})

test_that("print.tsr_game renders the X-wins branch", {
  g <- tsr_play_game("random", "random", seed = 1L)
  g$winner <- 1L
  txt <- cli::cli_fmt(print(g))
  expect_true(any(grepl("X wins", txt)))
})

test_that("print.tsr_game renders the O-wins branch and returns invisibly", {
  g <- tsr_play_game("random", "random", seed = 1L)
  g$winner <- 2L
  expect_invisible(print(g))
  txt <- cli::cli_fmt(print(g))
  expect_true(any(grepl("O wins", txt)))
})
