test_that("tsr_move places mark, flips to_move, grows history", {
  b <- tsr_new_board()
  b2 <- tsr_move(b, cell = 1L)
  expect_equal(b2$state[1L], 1L)
  expect_equal(b2$to_move, 2L)
  expect_equal(b2$history, 1L)
})

test_that("tsr_move is immutable", {
  b <- tsr_new_board()
  before <- b
  tsr_move(b, cell = 10L)
  expect_identical(b, before)
})

test_that("tsr_move(i,j,k,l) and tsr_move(cell=) agree", {
  b <- tsr_new_board()
  a1 <- tsr_move(b, 0L, 0L, 0L, 0L)
  a2 <- tsr_move(b, cell = 1L)
  expect_identical(a1, a2)
})

test_that("tsr_move errors on occupied cell and after game over", {
  b <- tsr_move(tsr_new_board(), cell = 1L)
  expect_error(tsr_move(b, cell = 1L), "occupied")

  w <- winning_board(1L)
  expect_error(tsr_move(w, cell = which(w$state == 0L)[1L]),
               "finished")
})

test_that("tsr_undo round-trips a single move", {
  b <- tsr_new_board()
  b2 <- tsr_move(b, cell = 17L)
  expect_identical(tsr_undo(b2), b)
})

test_that("tsr_undo errors when n exceeds history", {
  expect_error(tsr_undo(tsr_new_board(), n = 1L), "Cannot undo")
})

test_that("tsr_legal_moves: 256 on empty, 0 on finished, integer type", {
  expect_equal(length(tsr_legal_moves(tsr_new_board())), 256L)
  expect_type(tsr_legal_moves(tsr_new_board()), "integer")
  w <- winning_board(1L)
  expect_identical(tsr_legal_moves(w), integer(0))
})
