test_that("tsr_check_win detects axis-aligned and hyperdiagonal wins", {
  w <- winning_board(1L)
  expect_equal(tsr_check_win(w), 1L)
  expect_equal(tsr_check_win(tsr_new_board()), 0L)

  # Hyperdiagonal: cells 1, 86, 171, 256
  b <- tsr_new_board()
  # X plays diagonal, O plays elsewhere (non-blocking).
  diag_cells <- c(1L, 86L, 171L, 256L)
  other_cells <- c(2L, 3L, 4L, 5L)
  for (k in seq_len(4L)) {
    b <- tsr_move(b, cell = diag_cells[k])
    if (k < 4L) b <- tsr_move(b, cell = other_cells[k])
  }
  expect_equal(tsr_check_win(b), 1L)
})

test_that("tsr_winning_line returns integer(4) on win, integer(0) otherwise", {
  expect_identical(tsr_winning_line(tsr_new_board()), integer(0))
  w <- winning_board(1L)
  wl <- tsr_winning_line(w)
  expect_type(wl, "integer")
  expect_equal(length(wl), 4L)
  expect_true(all(w$state[wl] == 1L))
})

test_that("tsr_is_full TRUE on filled board", {
  b <- tsr_new_board()
  b$state <- rep_len(c(1L, 2L), 256L)
  b$history <- 1:256
  b$to_move <- 1L
  expect_true(tsr_is_full(b))
})

test_that("tsr_status returns a one-row tibble with the documented schema", {
  s <- tsr_status(tsr_new_board())
  expect_s3_class(s, "tbl_df")
  expect_equal(nrow(s), 1L)
  expect_named(s, c("winner", "is_full", "is_over", "n_moves", "to_move", "n_legal"))
  expect_type(s$winner, "integer")
  expect_type(s$is_full, "logical")
  expect_type(s$is_over, "logical")
  expect_type(s$n_moves, "integer")
  expect_type(s$to_move, "integer")
  expect_type(s$n_legal, "integer")

  expect_true(tsr_status(winning_board(1L))$is_over)
})
