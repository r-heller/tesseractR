#' Make a move on a 4D tic-tac-toe board
#'
#' Place the current player's mark at the given cell and return a **new**
#' `ttt_board` with the move applied. The input board is never mutated.
#'
#' Provide either the four hypercube coordinates `(i, j, k, l)` (each in `0:3`),
#' or the linear cell index via `cell` (an integer in `1:256`). Exactly one form
#' must be supplied.
#'
#' @param board A `ttt_board`.
#' @param i,j,k,l Integer coordinates in `0:3`. Either all four or none.
#' @param cell Optional linear cell index (`1:256`). Mutually exclusive with the
#'   coordinate form.
#' @return A new `ttt_board` with the mark placed, `to_move` flipped, and
#'   `history` extended by the move.
#' @examples
#' b <- tsr_new_board()
#' b <- tsr_move(b, 0L, 0L, 0L, 0L)
#' b <- tsr_move(b, cell = 5L)
#' tsr_status(b)
#' @export
tsr_move <- function(board, i = NULL, j = NULL, k = NULL, l = NULL, cell = NULL) {
  .tsr_check_board(board)
  coords_supplied <- !is.null(i) || !is.null(j) || !is.null(k) || !is.null(l)
  cell_supplied <- !is.null(cell)
  if (coords_supplied && cell_supplied) {
    cli::cli_abort("Supply either {.arg i,j,k,l} or {.arg cell}, not both.")
  }
  if (!coords_supplied && !cell_supplied) {
    cli::cli_abort("Supply either {.arg i,j,k,l} or {.arg cell}.")
  }
  if (coords_supplied) {
    if (is.null(i) || is.null(j) || is.null(k) || is.null(l)) {
      cli::cli_abort("All of {.arg i}, {.arg j}, {.arg k}, {.arg l} must be supplied.")
    }
    i <- as.integer(i); j <- as.integer(j); k <- as.integer(k); l <- as.integer(l)
    if (length(i) != 1L || length(j) != 1L || length(k) != 1L || length(l) != 1L) {
      cli::cli_abort("Coordinates must be scalar integers.")
    }
    if (any(c(i, j, k, l) < 0L | c(i, j, k, l) > 3L)) {
      cli::cli_abort("Coordinates must lie in {.code 0:3}.")
    }
    idx <- .tsr_coord_to_idx(i, j, k, l)
  } else {
    cell <- as.integer(cell)
    if (length(cell) != 1L || cell < 1L || cell > 256L) {
      cli::cli_abort("{.arg cell} must be a single integer in {.code 1:256}.")
    }
    idx <- cell
  }
  if (tsr_check_win(board) != 0L || tsr_is_full(board)) {
    cli::cli_abort(c(
      "Cannot move on a finished game.",
      i = "Call {.fn tsr_status} to inspect the position."
    ))
  }
  if (board$state[idx] != 0L) {
    cc <- .tsr_idx_to_coord(idx)
    cli::cli_abort(c(
      "Cell {.val {idx}} is already occupied.",
      x = "Coordinates (i={cc[1L,'i']}, j={cc[1L,'j']}, k={cc[1L,'k']}, l={cc[1L,'l']})."
    ))
  }
  new_state <- board$state
  new_state[idx] <- board$to_move
  new_to_move <- if (board$to_move == 1L) 2L else 1L
  new_history <- c(board$history, idx)
  new_ttt_board(state = new_state, to_move = new_to_move, history = new_history)
}

#' Undo the most recent moves on a board
#'
#' Pops `n` moves from the end of the history, clearing those cells and
#' restoring the player-to-move. Returns a new board.
#'
#' @param board A `ttt_board`.
#' @param n Integer (default `1L`). Number of moves to undo. Must not exceed
#'   `length(board$history)`.
#' @return A new `ttt_board` with the moves removed.
#' @examples
#' b <- tsr_new_board()
#' b2 <- tsr_move(b, cell = 1L)
#' identical(tsr_undo(b2), b)
#' @export
tsr_undo <- function(board, n = 1L) {
  .tsr_check_board(board)
  n <- as.integer(n)
  if (length(n) != 1L || n < 0L) {
    cli::cli_abort("{.arg n} must be a non-negative integer scalar.")
  }
  if (n > length(board$history)) {
    cli::cli_abort(c(
      "Cannot undo {n} move{?s}; only {length(board$history)} on the history.",
      i = "Use {.code length(board$history)} as an upper bound."
    ))
  }
  if (n == 0L) return(board)
  keep <- length(board$history) - n
  removed <- board$history[(keep + 1L):length(board$history)]
  new_state <- board$state
  new_state[removed] <- 0L
  new_history <- if (keep == 0L) integer(0) else board$history[seq_len(keep)]
  # to_move parity: after removing n moves, whoever's turn it was n moves ago.
  new_to_move <- if (board$to_move == 1L) {
    if (n %% 2L == 0L) 1L else 2L
  } else {
    if (n %% 2L == 0L) 2L else 1L
  }
  new_ttt_board(state = new_state, to_move = new_to_move, history = new_history)
}

#' Legal moves on a board
#'
#' Returns the integer linear indices of every empty cell, or an empty integer
#' vector if the game is over or the board is full. Always type-stable
#' (`integer`, never `NULL`).
#'
#' @param board A `ttt_board`.
#' @return Integer vector of legal linear cell indices (possibly length zero).
#' @examples
#' length(tsr_legal_moves(tsr_new_board()))
#' @export
tsr_legal_moves <- function(board) {
  .tsr_check_board(board)
  if (tsr_check_win(board) != 0L) return(integer(0))
  empty <- which(board$state == 0L)
  storage.mode(empty) <- "integer"
  empty
}
