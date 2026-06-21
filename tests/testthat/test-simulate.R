test_that("tsr_play_game produces a valid game; replay reproduces final_board", {
  g <- tsr_play_game("random", "random", seed = 1L)
  expect_s3_class(g, "tsr_game")
  expect_true(g$winner %in% c(0L, 1L, 2L))
  expect_lte(g$n_moves, 256L)
  b <- tsr_new_board()
  for (m in g$moves) b <- tsr_move(b, cell = m)
  expect_identical(b$state, g$final_board$state)
})

test_that("tsr_play_game is deterministic given seed + policies", {
  g1 <- tsr_play_game("random", "random", seed = 42L)
  g2 <- tsr_play_game("random", "random", seed = 42L)
  expect_identical(g1$moves, g2$moves)
})

test_that("tsr_simulate returns a tibble with the documented columns", {
  s <- tsr_simulate("random", "random", n_games = 5L, seed = 1L, verbose = FALSE)
  expect_s3_class(s, "tbl_df")
  expect_equal(nrow(s), 5L)
  expect_named(s, c("game_id", "policy_x", "policy_o", "winner",
                    "n_moves", "first_move", "first_move_i",
                    "first_move_j", "first_move_k", "first_move_l"))
})

test_that("tsr_opening_stats: rate sum = 1 per group, Wilson CI in [0,1]", {
  s <- tsr_simulate("random", "random", n_games = 8L, seed = 2L, verbose = FALSE)
  os <- tsr_opening_stats(s, by = "first_move")
  expect_true(all(os$ci_lo >= 0 & os$ci_hi <= 1))
  totals <- os$win_rate_x + os$win_rate_o + os$draw_rate
  expect_true(all(abs(totals - 1) < 1e-12))
})

test_that("RNG isolation: global .Random.seed is unchanged after seeded sim", {
  set.seed(99L)
  before <- .Random.seed
  invisible(tsr_simulate("random", "random", n_games = 3L,
                         seed = 7L, verbose = FALSE))
  after <- .Random.seed
  expect_identical(before, after)
})

test_that("print.tsr_game emits and returns invisibly", {
  g <- tsr_play_game("random", "random", seed = 1L)
  expect_invisible(out <- print(g))
  expect_identical(out, g)
})
