#' Print methods for a 4D tic-tac-toe board
#'
#' S3 `format`, `print`, and `summary` methods for `ttt_board`. `format()`
#' returns a character vector summary, `print()` emits a one-screen `cli`
#' summary and returns its input invisibly, and `summary()` returns the
#' `tsr_status()` tibble.
#'
#' @param x,object A `ttt_board`.
#' @param ... Reserved.
#' @return `format()` returns a character vector. `print()` returns `x`
#'   invisibly. `summary()` returns a one-row tibble.
#' @examples
#' format(tsr_new_board())
#' summary(tsr_new_board())
#' @name ttt_board-methods
NULL

#' @export
#' @rdname ttt_board-methods
#' @method format ttt_board
format.ttt_board <- function(x, ...) {
  rlang::check_dots_empty()
  st <- tsr_status(x)
  winner_txt <- if (st$winner == 1L) {
    "winner: X"
  } else if (st$winner == 2L) {
    "winner: O"
  } else if (st$is_full) {
    "result: draw"
  } else {
    sprintf("to move: %s", if (st$to_move == 1L) "X" else "O")
  }
  c(
    "<ttt_board>",
    "4x4x4x4 board, 256 cells",
    sprintf("moves played: %d", st$n_moves),
    winner_txt,
    sprintf("legal moves: %d", st$n_legal)
  )
}

#' @export
#' @rdname ttt_board-methods
#' @method print ttt_board
print.ttt_board <- function(x, ...) {
  rlang::check_dots_empty()
  lines <- format(x)
  cli::cli_h2(lines[1L])
  cli::cli_text(lines[2L])
  cli::cli_text(lines[3L])
  cli::cli_text(lines[4L])
  cli::cli_text(lines[5L])
  invisible(x)
}

#' @export
#' @rdname ttt_board-methods
#' @method summary ttt_board
summary.ttt_board <- function(object, ...) {
  rlang::check_dots_empty()
  tsr_status(object)
}
