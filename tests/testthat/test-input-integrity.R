test_that("fractional and missing inputs never select a different move", {
  board <- tsr_new_board()
  played <- tsr_move(board, cell = 2)
  for (bad in list(1.5, NA_real_, NaN, Inf, "2", logical(), c(1, 2))) {
    expect_error(tsr_move(board, cell = bad), "single integer")
    expect_error(tsr_move(board, bad, 0, 0, 0), "scalar integers")
    expect_error(tsr_undo(played, n = bad), "integer scalar")
    expect_error(tsr_ai_move(board, difficulty = bad), "integer")
    if (requireNamespace("shiny", quietly = TRUE)) {
      expect_error(tsr_run_app(difficulty = bad), "integer")
    }
  }
  expect_error(tsr_move(board, 1e100, 0, 0, 0), "0:3")
  expect_identical(tsr_move(board, cell = 2), played)
  expect_identical(tsr_undo(played, n = 1), board)
})

test_that("app startup restores the caller's difficulty setting on failure", {
  skip_if_not_installed("shiny")
  withr::local_envvar(TESSERACTR_INIT_DIFFICULTY = "previous")
  testthat::local_mocked_bindings(runApp = function(...) {
    expect_identical(Sys.getenv("TESSERACTR_INIT_DIFFICULTY"), "3")
    stop("startup failed")
  }, .package = "shiny")
  expect_error(tsr_run_app(3L), "startup failed")
  expect_identical(Sys.getenv("TESSERACTR_INIT_DIFFICULTY"), "previous")
})

test_that("missing board values produce a controlled validation error", {
  board <- tsr_new_board()
  board$state[1] <- NA_integer_
  expect_error(tsr_legal_moves(board), "state.*only")
  board <- tsr_move(tsr_new_board(), cell = 1)
  board$history[1] <- NA_integer_
  expect_error(tsr_undo(board), "history.*1:256")
})
