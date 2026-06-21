#' @keywords internal
#' @noRd
new_ttt_board <- function(state = integer(256),
                          to_move = 1L,
                          history = integer(0)) {
  structure(
    list(state = state, to_move = to_move, history = history),
    class = "ttt_board"
  )
}

#' @keywords internal
#' @noRd
validate_ttt_board <- function(x, call = rlang::caller_env()) {
  if (!inherits(x, "ttt_board")) {
    cli::cli_abort("{.arg x} must be a {.cls ttt_board}.", call = call)
  }
  s <- x$state
  if (!is.integer(s) || length(s) != 256L) {
    cli::cli_abort(
      "{.field state} must be an integer vector of length 256.",
      call = call
    )
  }
  if (any(s < 0L | s > 2L)) {
    cli::cli_abort(
      "{.field state} must contain only 0, 1, or 2 (got values outside that range).",
      call = call
    )
  }
  tm <- x$to_move
  if (!is.integer(tm) || length(tm) != 1L || !(tm %in% c(1L, 2L))) {
    cli::cli_abort("{.field to_move} must be {.code 1L} or {.code 2L}.", call = call)
  }
  h <- x$history
  if (!is.integer(h)) {
    cli::cli_abort("{.field history} must be an integer vector.", call = call)
  }
  if (length(h) > 0L && any(h < 1L | h > 256L)) {
    cli::cli_abort("{.field history} entries must lie in 1:256.", call = call)
  }
  n_played <- sum(s != 0L)
  if (n_played != length(h)) {
    cli::cli_abort(
      c("Board state and history are out of sync.",
        i = "{n_played} non-empty cell{?s} but history has {length(h)} entr{?y/ies}."),
      call = call
    )
  }
  invisible(x)
}

#' @keywords internal
#' @noRd
.tsr_check_board <- function(x, call = rlang::caller_env()) {
  validate_ttt_board(x, call = call)
}

#' Create a new, empty 4D tic-tac-toe board
#'
#' Constructs a fresh `ttt_board` representing an empty 4x4x4x4 hypercube with
#' player X (mark `1`) to move.
#'
#' @return An object of class `ttt_board`: a list with components
#'   `state` (integer vector of length 256, values in `0:2`),
#'   `to_move` (`1L` for X, `2L` for O), and
#'   `history` (integer vector of linear cell indices played, in order).
#'
#' @examples
#' b <- tsr_new_board()
#' is_ttt_board(b)
#' tsr_status(b)
#' @export
tsr_new_board <- function() {
  new_ttt_board()
}

#' Test whether an object is a `ttt_board`
#'
#' @param x Object to test.
#' @return Logical scalar: `TRUE` if `x` inherits from `"ttt_board"`.
#' @examples
#' is_ttt_board(tsr_new_board())
#' is_ttt_board(list())
#' @export
is_ttt_board <- function(x) {
  inherits(x, "ttt_board")
}
