# Validation and branch coverage for the evaluation core.

test_that("tsr_evaluate rejects an invalid player", {
  b <- tsr_new_board()
  expect_error(tsr_evaluate(b, player = 3L), "1L")
  expect_error(tsr_evaluate(b, player = c(1L, 2L)), "1L")
})

test_that("tsr_evaluate defaults player to board$to_move", {
  b <- tsr_new_board()
  expect_equal(tsr_evaluate(b), tsr_evaluate(b, player = b$to_move))
})

test_that("tsr_evaluate returns the terminal sentinel on a won board", {
  w <- winning_board(1L)
  expect_gt(tsr_evaluate(w, player = 1L), 1e5)
  expect_lt(tsr_evaluate(w, player = 2L), -1e5)
})

test_that("tsr_evaluate returns 0 on a full, drawn board", {
  draw_b <- tsr_new_board()
  draw_b$state <- rep_len(c(1L, 2L), 256L)
  draw_b$history <- 1:256
  local_mocked_bindings(tsr_check_win = function(board) 0L)
  expect_equal(tsr_evaluate(draw_b, player = 1L), 0)
})

test_that("tsr_win_prob rejects an invalid player", {
  b <- tsr_new_board()
  expect_error(tsr_win_prob(b, player = 0L), "1L")
})

test_that("tsr_win_prob rejects a non-positive rollout n", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)
  expect_error(tsr_win_prob(b, method = "rollout", n = 0L), "positive")
})

test_that("tsr_win_prob heuristic honors a non-default calibration", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)
  # Inject a calibration object into the namespace so .tsr_get_calibration()
  # takes its non-default branch.
  local_mocked_bindings(
    .tsr_get_calibration = function() list(a = 5, b = 50)
  )
  p <- tsr_win_prob(b, player = 1L, method = "heuristic")
  expect_true(p >= 0 && p <= 1)
})

test_that("tsr_win_prob rollout accumulates wins and draws", {
  skip_on_cran()
  set.seed(1L)
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)
  p <- tsr_win_prob(b, player = 1L, method = "rollout", n = 6L)
  expect_true(p >= 0 && p <= 1)
})

test_that(".tsr_random_playout returns a terminal mark", {
  skip_on_cran()
  set.seed(2L)
  res <- tesseractR:::.tsr_random_playout(tsr_new_board())
  expect_true(res %in% c(0L, 1L, 2L))
})

test_that(".tsr_immediate_wins returns the completing cell for a threat", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)   # X
  b <- tsr_move(b, cell = 17L)  # O
  b <- tsr_move(b, cell = 2L)   # X
  b <- tsr_move(b, cell = 18L)  # O
  b <- tsr_move(b, cell = 3L)   # X threatens 4
  w <- tesseractR:::.tsr_immediate_wins(b, 1L)
  expect_true(4L %in% w)
})

test_that(".tsr_immediate_wins returns integer(0) when no threat exists", {
  expect_identical(tesseractR:::.tsr_immediate_wins(tsr_new_board(), 1L),
                   integer(0))
})

test_that("tsr_rate_moves rollout method produces win_prob in [0,1]", {
  skip_on_cran()
  # Use a nearly-full board so there are only a handful of legal moves; each
  # rollout then plays out in a few plies, keeping this test fast.
  b <- tsr_new_board()
  b$state <- rep_len(c(1L, 2L), 256L)
  b$state[c(250L, 251L, 252L)] <- 0L   # three empty cells
  b$state[c(1L, 2L)] <- c(1L, 2L)
  b$to_move <- 1L
  b$history <- which(b$state != 0L)
  r <- tsr_rate_moves(b, method = "rollout", n = 2L)
  expect_true(all(r$win_prob >= 0 & r$win_prob <= 1))
})
