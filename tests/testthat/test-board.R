test_that("tsr_new_board() returns a valid empty ttt_board", {
  b <- tsr_new_board()
  expect_true(is_ttt_board(b))
  expect_equal(length(b$state), 256L)
  expect_true(all(b$state == 0L))
  expect_equal(b$to_move, 1L)
  expect_equal(b$history, integer(0))
})

test_that("is_ttt_board() rejects non-boards", {
  expect_false(is_ttt_board(list()))
  expect_false(is_ttt_board(NULL))
})

test_that("validate_ttt_board() rejects bad inputs", {
  bad <- structure(list(state = 1:10, to_move = 1L, history = integer(0)),
                   class = "ttt_board")
  expect_error(tesseractR:::validate_ttt_board(bad), "length 256")

  bad2 <- structure(list(state = integer(256), to_move = 3L, history = integer(0)),
                    class = "ttt_board")
  expect_error(tesseractR:::validate_ttt_board(bad2), "to_move")

  bad3 <- tsr_new_board()
  bad3$state[1L] <- 5L
  expect_error(tesseractR:::validate_ttt_board(bad3), "0, 1, or 2")
})
