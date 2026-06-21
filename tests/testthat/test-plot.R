test_that("tsr_plot returns a ggplot for empty, mid, and won boards", {
  expect_s3_class(tsr_plot(tsr_new_board()), "ggplot")
  expect_s3_class(tsr_plot(example_board()), "ggplot")
  expect_s3_class(tsr_plot(winning_board(1L)), "ggplot")
})

test_that("winning-line highlight adds an extra layer when over", {
  p_empty <- tsr_plot(tsr_new_board())
  p_win   <- tsr_plot(winning_board(1L))
  expect_gt(length(p_win$layers), length(p_empty$layers))
})

test_that("autoplot.ttt_board returns a ggplot equal in class to tsr_plot", {
  a <- ggplot2::autoplot(tsr_new_board())
  expect_s3_class(a, "ggplot")
})

test_that("tsr_plot_slice returns a ggplot for every (axis, at)", {
  b <- example_board()
  for (ax in c("i", "j", "k", "l")) {
    for (at in 0:3) {
      expect_s3_class(tsr_plot_slice(b, axis = ax, at = at), "ggplot")
    }
  }
})

test_that("tsr_plot_slice errors on out-of-range at and bad axis", {
  expect_error(tsr_plot_slice(tsr_new_board(), axis = "i", at = 4L),
               "0:3")
  expect_error(tsr_plot_slice(tsr_new_board(), axis = "z", at = 0L),
               "should be one of")
})

test_that("Slice highlights when the winning line lies in it", {
  w <- winning_board(1L)  # win on cells 1-4 (i-axis, j=k=l=0)
  # All four winning cells share l = 0 and k = 0 and j = 0, vary in i.
  p_in <- tsr_plot_slice(w, axis = "l", at = 0L)
  p_out <- tsr_plot_slice(w, axis = "l", at = 1L)
  expect_s3_class(p_in, "ggplot")
  expect_s3_class(p_out, "ggplot")
  expect_gt(length(p_in$layers), length(p_out$layers))
})
