#' @export
#' @method format ttt_board
#' @param x A `ttt_board`.
#' @param ... Reserved.
#' @return A character vector representation of the board.
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
#' @method print ttt_board
#' @param x A `ttt_board`.
#' @param ... Reserved.
#' @return `x`, invisibly. Called for its side effect.
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
#' @method summary ttt_board
#' @param object A `ttt_board`.
#' @param ... Reserved.
#' @return A one-row tibble as produced by `tsr_status()`.
summary.ttt_board <- function(object, ...) {
  rlang::check_dots_empty()
  tsr_status(object)
}
