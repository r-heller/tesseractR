# Coverage for tsr_run_app() guard branches without launching shiny.

test_that("tsr_run_app errors when shiny is unavailable", {
  local_mocked_bindings(
    requireNamespace = function(...) FALSE,
    .package = "base"
  )
  expect_error(tsr_run_app(), "shiny")
})

test_that("tsr_run_app rejects an invalid difficulty before launching", {
  expect_error(tsr_run_app(difficulty = 5L), "1:4")
  expect_error(tsr_run_app(difficulty = c(1L, 2L)), "1:4")
})
