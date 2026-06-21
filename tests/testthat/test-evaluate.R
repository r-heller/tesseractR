test_that("tsr_evaluate returns numeric and the sign favors the stronger side", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L) # X
  b <- tsr_move(b, cell = 50L) # O (away from X's line)
  b <- tsr_move(b, cell = 2L) # X (now X has 2 on a line)
  expect_type(tsr_evaluate(b, 1L), "double")
  expect_gt(tsr_evaluate(b, 1L), 0)
  expect_lt(tsr_evaluate(b, 2L), 0)
})

test_that("tsr_win_prob is in [0,1] and respects terminal short-circuits", {
  expect_equal(tsr_win_prob(winning_board(1L), player = 1L), 1)
  expect_equal(tsr_win_prob(winning_board(1L), player = 2L), 0)

  # Synthetic draw position: state is full and tsr_check_win returns 0.
  # We cannot easily construct one organically on a 4^4 board, so we patch
  # the engine internals with local mocks.
  draw_b <- tsr_new_board()
  draw_b$state <- rep_len(c(1L, 2L), 256L)
  draw_b$history <- 1:256
  local_mocked_bindings(
    tsr_check_win = function(board) 0L,
    tsr_is_full   = function(board) TRUE
  )
  expect_equal(tsr_win_prob(draw_b, player = 1L), 0.5)
})

test_that("tsr_win_prob on a fresh board lies in [0,1]", {
  p <- tsr_win_prob(tsr_new_board())
  expect_true(p >= 0 && p <= 1)
})

test_that("tsr_win_prob rollout returns a value in [0,1]", {
  skip_on_cran()
  p <- tsr_win_prob(tsr_new_board(), method = "rollout", n = 4L)
  expect_true(is.numeric(p) && p >= 0 && p <= 1)
})

test_that("tsr_rate_moves: documented schema, rank permutation, finished-board empty", {
  b <- tsr_new_board()
  r <- tsr_rate_moves(b)
  expect_s3_class(r, "tbl_df")
  expect_named(r, c("cell", "i", "j", "k", "l", "score", "win_prob",
                    "rank", "is_best", "is_winning", "is_blocking"))
  expect_equal(nrow(r), 256L)
  expect_setequal(r$rank, seq_len(256L))
  expect_equal(sum(r$is_best), 1L)

  # Finished board → 0-row tibble with same columns.
  e <- tsr_rate_moves(winning_board(1L))
  expect_equal(nrow(e), 0L)
  expect_named(e, c("cell", "i", "j", "k", "l", "score", "win_prob",
                    "rank", "is_best", "is_winning", "is_blocking"))
})

test_that("tsr_rate_moves marks winning and blocking moves correctly", {
  # X to move with 3-in-a-row on 1,2,3 → playing 4 wins.
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L); b <- tsr_move(b, cell = 17L)
  b <- tsr_move(b, cell = 2L); b <- tsr_move(b, cell = 18L)
  b <- tsr_move(b, cell = 3L); b <- tsr_move(b, cell = 50L)
  r <- tsr_rate_moves(b)
  expect_true(r$is_winning[r$cell == 4L])

  # Build a board where O threatens 17-18-19 and X has no immediate win.
  c <- tsr_new_board()
  c <- tsr_move(c, cell = 50L); c <- tsr_move(c, cell = 17L)
  c <- tsr_move(c, cell = 51L); c <- tsr_move(c, cell = 18L)
  c <- tsr_move(c, cell = 80L); c <- tsr_move(c, cell = 19L)
  r2 <- tsr_rate_moves(c)
  expect_true(r2$is_blocking[r2$cell == 20L])
})
