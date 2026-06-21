test_that("coord/idx round-trip for all 256 cells", {
  idx <- 1:256
  cc <- tesseractR:::.tsr_idx_to_coord(idx)
  back <- tesseractR:::.tsr_coord_to_idx(cc[, "i"], cc[, "j"], cc[, "k"], cc[, "l"])
  expect_identical(back, as.integer(idx))
})

test_that(".tsr_directions: 40 rows, normalized", {
  d <- tesseractR:::.tsr_directions()
  expect_equal(nrow(d), 40L)
  expect_false(any(rowSums(d != 0L) == 0L))
  first_nz <- vapply(seq_len(nrow(d)), function(r) {
    nz <- which(d[r, ] != 0L); d[r, nz[1L]]
  }, integer(1L))
  expect_true(all(first_nz == 1L))
})

test_that("win lines: 520 x 4 integer matrix, valid indices", {
  L <- tesseractR:::.tsr_win_lines()
  expect_equal(dim(L), c(520L, 4L))
  expect_true(is.integer(L))
  expect_true(all(L >= 1L & L <= 256L))
})

test_that("win lines are collinear", {
  L <- tesseractR:::.tsr_win_lines()
  for (r in c(1L, 100L, 272L)) {
    cc <- tesseractR:::.tsr_idx_to_coord(L[r, ])
    diffs <- diff(cc)
    expect_true(nrow(unique(diffs)) == 1L)
  }
})

test_that("cache populated on first call and stable across calls", {
  rm(list = ls(envir = tesseractR:::.tsr_cache),
     envir = tesseractR:::.tsr_cache)
  expect_null(tesseractR:::.tsr_cache[["win_lines"]])
  L1 <- tesseractR:::.tsr_win_lines()
  expect_false(is.null(tesseractR:::.tsr_cache[["win_lines"]]))
  L2 <- tesseractR:::.tsr_win_lines()
  expect_identical(L1, L2)
})

test_that("known axis-aligned line and main hyperdiagonal present", {
  L <- tesseractR:::.tsr_win_lines()
  key <- apply(L, 1L, function(row) paste(sort(row), collapse = "-"))
  expect_true(paste(c(1L, 2L, 3L, 4L), collapse = "-") %in% key)
  expect_true(paste(c(1L, 86L, 171L, 256L), collapse = "-") %in% key)
})
