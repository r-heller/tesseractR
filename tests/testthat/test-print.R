test_that("print returns its input invisibly and emits output", {
  b <- tsr_new_board()
  expect_invisible(out <- print(b))
  expect_identical(out, b)
})

test_that("print errors on extra dots", {
  expect_error(print(tsr_new_board(), extra = 1), "must be empty")
})

test_that("format returns the documented character vector", {
  s <- format(tsr_new_board())
  expect_type(s, "character")
  expect_match(s[1L], "ttt_board")
})

test_that("summary returns the tsr_status tibble", {
  s <- summary(tsr_new_board())
  expect_s3_class(s, "tbl_df")
  expect_named(s, c("winner", "is_full", "is_over", "n_moves", "to_move", "n_legal"))
})
