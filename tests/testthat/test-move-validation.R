# Validation branches for tsr_move(), tsr_undo(), and the board validator.

test_that("tsr_move rejects supplying both coordinate and cell forms", {
  b <- tsr_new_board()
  expect_error(tsr_move(b, 0L, 0L, 0L, 0L, cell = 1L), "not both")
})

test_that("tsr_move requires at least one of the two forms", {
  b <- tsr_new_board()
  expect_error(tsr_move(b), "Supply either")
})

test_that("tsr_move requires all four coordinates when any is supplied", {
  b <- tsr_new_board()
  expect_error(tsr_move(b, i = 0L), "must be supplied")
  expect_error(tsr_move(b, i = 0L, j = 0L, k = 0L), "must be supplied")
})

test_that("tsr_move rejects non-scalar coordinates", {
  b <- tsr_new_board()
  expect_error(tsr_move(b, i = c(0L, 1L), j = 0L, k = 0L, l = 0L),
               "scalar integers")
})

test_that("tsr_move rejects out-of-range coordinates", {
  b <- tsr_new_board()
  expect_error(tsr_move(b, i = 4L, j = 0L, k = 0L, l = 0L), "0:3")
  expect_error(tsr_move(b, i = -1L, j = 0L, k = 0L, l = 0L), "0:3")
})

test_that("tsr_move rejects out-of-range or non-scalar cell", {
  b <- tsr_new_board()
  expect_error(tsr_move(b, cell = 0L), "1:256")
  expect_error(tsr_move(b, cell = 257L), "1:256")
  expect_error(tsr_move(b, cell = c(1L, 2L)), "1:256")
})

test_that("tsr_move occupied-cell error reports coordinates", {
  b <- tsr_move(tsr_new_board(), cell = 1L)
  expect_error(tsr_move(b, cell = 1L), "occupied")
})

test_that("tsr_undo rejects negative or non-scalar n", {
  b <- tsr_move(tsr_new_board(), cell = 1L)
  expect_error(tsr_undo(b, n = -1L), "non-negative")
  expect_error(tsr_undo(b, n = c(1L, 1L)), "non-negative")
})

test_that("tsr_undo with n = 0 returns the board unchanged", {
  b <- tsr_move(tsr_new_board(), cell = 1L)
  expect_identical(tsr_undo(b, n = 0L), b)
})

test_that("tsr_undo of multiple moves restores to_move parity and clears cells", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)   # X
  b <- tsr_move(b, cell = 2L)   # O
  b <- tsr_move(b, cell = 3L)   # X
  u <- tsr_undo(b, n = 2L)
  expect_equal(u$state[c(2L, 3L)], c(0L, 0L))
  expect_equal(u$to_move, 2L)   # O was to move after move 1
  expect_equal(u$history, 1L)
})

test_that("tsr_undo all the way to an empty board works", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 5L)
  b <- tsr_move(b, cell = 6L)
  u <- tsr_undo(b, n = 2L)
  expect_identical(u, tsr_new_board())
})

test_that("validate_ttt_board flags non-integer history", {
  bad <- tsr_new_board()
  bad$history <- 1.5
  expect_error(tesseractR:::validate_ttt_board(bad), "history")
})

test_that("validate_ttt_board flags history out of 1:256", {
  bad <- structure(
    list(state = `[<-`(integer(256), 1L, 1L), to_move = 2L, history = 999L),
    class = "ttt_board"
  )
  expect_error(tesseractR:::validate_ttt_board(bad), "1:256")
})

test_that("validate_ttt_board flags state/history desync", {
  bad <- tsr_new_board()
  bad$state[1L] <- 1L   # one mark placed but history is empty
  expect_error(tesseractR:::validate_ttt_board(bad), "out of sync")
})

test_that(".tsr_check_board accepts a valid board invisibly", {
  expect_invisible(tesseractR:::.tsr_check_board(tsr_new_board()))
})
