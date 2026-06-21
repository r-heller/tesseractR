test_that("inst/shiny/tesseractR/app.R has no library()/require() calls", {
  app_file <- system.file("shiny", "tesseractR", "app.R", package = "tesseractR")
  if (!nzchar(app_file)) {
    # When testing in dev (load_all) the file may not be installed; fall back.
    app_file <- file.path("..", "..", "inst", "shiny", "tesseractR", "app.R")
  }
  skip_if(!file.exists(app_file), "app.R not found in test env")
  lines <- readLines(app_file)
  expect_false(any(grepl("\\blibrary\\(", lines)))
  expect_false(any(grepl("\\brequire\\(", lines, perl = TRUE) &
                   !grepl("requireNamespace", lines)))
})

test_that("tsr_run_app errors clearly on invalid difficulty", {
  expect_error(tsr_run_app(difficulty = 5L), "1:4")
  expect_error(tsr_run_app(difficulty = 0L), "1:4")
})

test_that("app.R parses without error in a clean environment", {
  app_file <- system.file("shiny", "tesseractR", "app.R", package = "tesseractR")
  if (!nzchar(app_file)) {
    app_file <- file.path("..", "..", "inst", "shiny", "tesseractR", "app.R")
  }
  skip_if(!file.exists(app_file), "app.R not found in test env")
  expect_silent(parse(app_file))
})
