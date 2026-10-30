#' Launch the tesseractR Shiny app
#'
#' Opens the interactive 4D tic-tac-toe app shipped in `inst/shiny/tesseractR`.
#' Requires the `shiny` package (declared in `Suggests`).
#'
#' @param difficulty Integer in `1:4`. Initial AI difficulty for vs-AI mode.
#' @return Invisible `NULL`. Called for its side effect of launching the app.
#' @examples
#' \donttest{
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   tsr_run_app()
#' }
#' }
#' @export
tsr_run_app <- function(difficulty = 2L) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg shiny} is required to launch the app.",
      i = "Install it with {.code install.packages(\"shiny\")}."
    ))
  }
  if (!is.numeric(difficulty) || length(difficulty) != 1L ||
      !is.finite(difficulty) || !(difficulty %in% 1:4)) {
    cli::cli_abort("{.arg difficulty} must be an integer in {.code 1:4}.")
  }
  difficulty <- as.integer(difficulty)
  app_dir <- system.file("shiny", "tesseractR", package = "tesseractR")
  if (!nzchar(app_dir)) {
    cli::cli_abort("Shiny app directory not found in the installed package.")
  }
  previous <- Sys.getenv("TESSERACTR_INIT_DIFFICULTY", unset = NA_character_)
  Sys.setenv(TESSERACTR_INIT_DIFFICULTY = as.character(difficulty))
  on.exit(if (is.na(previous)) Sys.unsetenv("TESSERACTR_INIT_DIFFICULTY") else
    Sys.setenv(TESSERACTR_INIT_DIFFICULTY = previous), add = TRUE)
  shiny::runApp(app_dir, display.mode = "normal")
  invisible(NULL)
}
