# Branch coverage for the ttt_board S3 format/print/summary methods.

test_that("format reports an O winner", {
  # Build an O win on cells 17-18-19-20 directly; X plays off the line.
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 50L)  # X
  b <- tsr_move(b, cell = 17L)  # O
  b <- tsr_move(b, cell = 51L)  # X
  b <- tsr_move(b, cell = 18L)  # O
  b <- tsr_move(b, cell = 52L)  # X
  b <- tsr_move(b, cell = 19L)  # O
  b <- tsr_move(b, cell = 53L)  # X
  b <- tsr_move(b, cell = 20L)  # O completes the line
  expect_equal(tsr_check_win(b), 2L)
  s <- format(b)
  expect_true(any(grepl("winner: O", s)))
})

test_that("format reports an X winner", {
  w <- winning_board(1L)
  s <- format(w)
  expect_true(any(grepl("winner: X", s)))
})

test_that("format reports a draw on a full, winner-less board", {
  draw_b <- tsr_new_board()
  draw_b$state <- rep_len(c(1L, 2L), 256L)
  draw_b$history <- 1:256
  local_mocked_bindings(tsr_check_win = function(board) 0L)
  s <- format(draw_b)
  expect_true(any(grepl("draw", s)))
})

test_that("format reports the side to move on an ongoing game", {
  s <- format(tsr_new_board())
  expect_true(any(grepl("to move: X", s)))
})

test_that("format and print reject extra dots", {
  expect_error(format(tsr_new_board(), foo = 1), "must be empty")
  expect_error(summary(tsr_new_board(), foo = 1), "must be empty")
})

test_that("print emits a cli summary and returns invisibly", {
  expect_invisible(out <- print(tsr_new_board()))
  expect_identical(out, tsr_new_board())
})
