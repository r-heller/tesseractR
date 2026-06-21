test_that("tsr_ai_move returns a legal move", {
  b <- tsr_new_board()
  m <- tsr_ai_move(b, difficulty = 1L)
  expect_true(m %in% tsr_legal_moves(b))
})

test_that("AI takes an immediate win at difficulty >= 1", {
  # X has 3 on the i-axis row at j=k=l=0 (cells 1,2,3), cell 4 empty.
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 1L)   # X
  b <- tsr_move(b, cell = 17L)  # O
  b <- tsr_move(b, cell = 2L)   # X
  b <- tsr_move(b, cell = 18L)  # O
  b <- tsr_move(b, cell = 3L)   # X
  b <- tsr_move(b, cell = 19L)  # O (does not block: line is 1-2-3-4)
  expect_equal(tsr_ai_move(b, difficulty = 1L), 4L)
  expect_equal(tsr_ai_move(b, difficulty = 2L), 4L)
})

test_that("AI blocks an immediate opponent threat at difficulty >= 1", {
  # X plays first; O builds 3-in-row on cells 17,18,19 while X plays
  # cells off that line.
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 33L)  # X
  b <- tsr_move(b, cell = 17L)  # O
  b <- tsr_move(b, cell = 34L)  # X
  b <- tsr_move(b, cell = 18L)  # O
  b <- tsr_move(b, cell = 35L)  # X (gives X 3 in a row on 33-36 too!)
  # On this board, X also has a winning move at 36. AI should take its
  # own win first, not block.
  m <- tsr_ai_move(b, difficulty = 1L)
  expect_equal(m, 36L)
})

test_that("AI blocks when no immediate win exists", {
  # O builds 17,18,19 (row at j=1,k=l=0). X plays harmless cells.
  b <- tsr_new_board()
  b <- tsr_move(b, cell = 50L)  # X
  b <- tsr_move(b, cell = 17L)  # O
  b <- tsr_move(b, cell = 51L)  # X
  b <- tsr_move(b, cell = 18L)  # O
  b <- tsr_move(b, cell = 80L)  # X (no own threat)
  b <- tsr_move(b, cell = 19L)  # O has 17-18-19; needs 20 to win
  # Now X to move. No immediate X win; must block at 20.
  expect_equal(tsr_ai_move(b, difficulty = 1L), 20L)
})

test_that("AI is deterministic for the same board + difficulty", {
  b <- tsr_new_board()
  m1 <- tsr_ai_move(b, difficulty = 2L)
  m2 <- tsr_ai_move(b, difficulty = 2L)
  expect_equal(m1, m2)
})

test_that("AI errors on a finished game", {
  w <- winning_board(1L)
  expect_error(tsr_ai_move(w), "finished")
})
