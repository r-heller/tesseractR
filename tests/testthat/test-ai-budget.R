test_that("time budgets are validated before finished-board shortcuts", {
  active <- tsr_new_board()
  finished <- active
  for (m in c(1L, 17L, 2L, 18L, 3L, 80L, 4L)) {
    finished <- tsr_move(finished, cell = m)
  }
  for (b in list(active, finished)) {
    for (bad in list(-1, Inf, NA_real_, NaN, numeric(), c(.1, .2),
                     TRUE, "1", 1 + 0i, matrix(1))) {
      expect_error(tsr_ai_move(b, time_limit = bad), "time_limit")
    }
  }
})

test_that("zero budget has a legal deterministic fallback without RNG changes", {
  b <- tsr_move(tsr_new_board(), cell = 1L)
  before <- b
  set.seed(17); rng <- .Random.seed
  expect_identical(tsr_ai_move(b, 4L, time_limit = 0), 2L)
  expect_identical(tsr_ai_move(b, 4L, time_limit = 0), 2L)
  expect_identical(.Random.seed, rng)
  expect_identical(b, before)
})

test_that("immediate wins and blocks retain priority even with zero budget", {
  win <- tsr_new_board()
  for (m in c(1L, 17L, 2L, 18L, 3L, 80L)) win <- tsr_move(win, cell = m)
  expect_identical(tsr_ai_move(win, 4L, time_limit = 0), 4L)
  block <- tsr_new_board()
  for (m in c(50L, 17L, 51L, 18L, 80L, 19L)) block <- tsr_move(block, cell = m)
  expect_identical(tsr_ai_move(block, 4L, time_limit = 0), 20L)
})

test_that("a partial depth cannot replace the last completed search", {
  b <- tsr_move(tsr_new_board(), cell = 1L)
  calls <- 0L
  testthat::local_mocked_bindings(.tsr_elapsed = function() {
    calls <<- calls + 1L
    0
  })
  # Record actual clock checkpoints for a fully searched depth-one tree.
  expected <- tsr_ai_move(b, 1L, time_limit = 1)
  complete_calls <- calls
  expect_identical(expected, 4L)
  for (allowed in c(1L, complete_calls - 1L)) {
    calls <- 0L
    testthat::local_mocked_bindings(.tsr_elapsed = function() {
      calls <<- calls + 1L
      if (calls <= allowed) 0 else 2
    })
    expect_identical(tsr_ai_move(b, 4L, time_limit = 1), 2L)
  }
  # Permit depth one, then stop during the next depth's ordering/recursion.
  for (extra in c(0L, length(tsr_legal_moves(b)) + 10L)) {
    calls <- 0L
    testthat::local_mocked_bindings(.tsr_elapsed = function() {
      calls <<- calls + 1L
      if (calls <= complete_calls + extra) 0 else 2
    })
    expect_identical(tsr_ai_move(b, 4L, time_limit = 1), expected)
  }
})

test_that("the unrestricted API does not consult a clock", {
  testthat::local_mocked_bindings(.tsr_elapsed = function() stop("clock called"))
  b <- tsr_move(tsr_new_board(), cell = 1L)
  expect_identical(tsr_ai_move(b, 1L), 4L)
  expect_identical(tsr_ai_move(b, 1L, time_limit = NULL), 4L)
})
