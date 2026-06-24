# Validation and edge branches for tsr_ai_move() and the negamax core.

test_that("tsr_ai_move rejects out-of-range difficulty", {
  b <- tsr_new_board()
  expect_error(tsr_ai_move(b, difficulty = 0L), "1:4")
  expect_error(tsr_ai_move(b, difficulty = 5L), "1:4")
  expect_error(tsr_ai_move(b, difficulty = c(1L, 2L)), "1:4")
})

test_that("tsr_ai_move errors on a full board", {
  full <- tsr_new_board()
  full$state <- rep_len(c(1L, 2L), 256L)
  full$history <- 1:256
  # The board is full but has no winner; tsr_is_full() short-circuits.
  expect_error(tsr_ai_move(full), "finished board")
})

test_that("tsr_ai_move blocks an opponent threat when it has no win", {
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 50L)  # X
  b <- tsr_move(b, cell = 17L)  # O
  b <- tsr_move(b, cell = 51L)  # X
  b <- tsr_move(b, cell = 18L)  # O
  b <- tsr_move(b, cell = 80L)  # X (no own threat)
  b <- tsr_move(b, cell = 19L)  # O threatens 20
  expect_equal(tsr_ai_move(b, difficulty = 2L), 20L)
})

test_that("tsr_ai_move runs the full negamax search at depth >= 2", {
  # No immediate win or block, so the alpha-beta loop is exercised.
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)   # X
  m <- tsr_ai_move(b, difficulty = 2L)  # O to move, open position
  expect_true(m %in% tsr_legal_moves(b))
})

test_that("AI move at higher difficulty stays legal", {
  skip_on_cran()
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)
  b <- tsr_move(b, cell = 200L)
  m <- tsr_ai_move(b, difficulty = 3L)
  expect_true(m %in% tsr_legal_moves(b))
})
