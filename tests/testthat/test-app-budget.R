test_that("bounded AI responses and resets preserve app state", {
  skip_if_not_installed("shiny")
  path <- system.file("shiny", "tesseractR", "app.R", package = "tesseractR")
  if (!nzchar(path)) path <- file.path("..", "..", "inst", "shiny", "tesseractR", "app.R")
  skip_if_not(file.exists(path), "app unavailable")
  app <- new.env(parent = globalenv())
  sys.source(path, envir = app)
  # Exercise the shipped 2D mode without constructing unused 3D outputs.
  app$has_plotly <- FALSE
  ticks <- 0
  testthat::local_mocked_bindings(.tsr_elapsed = function() {
    ticks <<- ticks + 1
    ticks
  })
  shiny::testServer(app$server, {
    session$setInputs(view = "full", mode = "ai", difficulty = 4L, new_game = 1L)
    xy <- tesseractR:::.tsr_layout(tesseractR:::.tsr_idx_to_coord(1:256))
    session$setInputs(board_click = list(x = xy[1L, "x"], y = xy[1L, "y"]))
    expect_identical(rv$history, c(1L, 2L))
    expect_equal(sum(rv$board$state != 0L), 2L)
    session$setInputs(new_game = 2L)
    expect_identical(rv$history, integer())
    expect_true(all(rv$board$state == 0L))
    session$flushReact()
    expect_identical(rv$history, integer())
    # A reset has no queued worker response; hotseat receives only this click.
    session$setInputs(mode = "hotseat")
    session$setInputs(board_click = list(x = xy[256L, "x"], y = xy[256L, "y"]))
    expect_identical(rv$history, 256L)
    expect_equal(sum(rv$board$state != 0L), 1L)
  })
})
