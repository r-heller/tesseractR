#' Detect a winner on the board
#'
#' Scans the cached win-line table and returns the winning player's mark or `0L`
#' if no player has completed a line.
#'
#' @param board A `ttt_board`.
#' @return Integer scalar: `0L` (no winner), `1L` (player X), or `2L` (player O).
#' @examples
#' tsr_check_win(tsr_new_board())
#' @export
tsr_check_win <- function(board) {
  .tsr_check_board(board)
  L <- .tsr_win_lines()
  s <- board$state
  vals <- matrix(s[L], nrow = nrow(L), ncol = 4L)
  row_min <- pmin.int(vals[, 1L], vals[, 2L], vals[, 3L], vals[, 4L])
  row_max <- pmax.int(vals[, 1L], vals[, 2L], vals[, 3L], vals[, 4L])
  done <- row_min == row_max & row_min != 0L
  if (!any(done)) return(0L)
  as.integer(row_min[which(done)[1L]])
}

#' Indices of the first winning line on the board
#'
#' Returns the four linear cell indices that form the first detected winning
#' line, or `integer(0)` if no line is complete.
#'
#' @param board A `ttt_board`.
#' @return Integer vector of length 4 (the winning line) or length 0 (no winner).
#' @examples
#' tsr_winning_line(tsr_new_board())
#' @export
tsr_winning_line <- function(board) {
  .tsr_check_board(board)
  L <- .tsr_win_lines()
  s <- board$state
  vals <- matrix(s[L], nrow = nrow(L), ncol = 4L)
  row_min <- pmin.int(vals[, 1L], vals[, 2L], vals[, 3L], vals[, 4L])
  row_max <- pmax.int(vals[, 1L], vals[, 2L], vals[, 3L], vals[, 4L])
  done <- row_min == row_max & row_min != 0L
  if (!any(done)) return(integer(0))
  out <- L[which(done)[1L], ]
  storage.mode(out) <- "integer"
  unname(out)
}

#' Whether the board has no empty cells
#'
#' @param board A `ttt_board`.
#' @return Logical scalar.
#' @examples
#' tsr_is_full(tsr_new_board())
#' @export
tsr_is_full <- function(board) {
  .tsr_check_board(board)
  !any(board$state == 0L)
}

#' Structured one-row status for a board
#'
#' Returns a tibble that summarizes the position: winner, whether it is full,
#' whether the game is over, move counts, and the number of legal moves.
#'
#' @param board A `ttt_board`.
#' @return A one-row tibble with columns:
#'   `winner` (integer, `0/1/2`),
#'   `is_full` (logical),
#'   `is_over` (logical),
#'   `n_moves` (integer; total moves played),
#'   `to_move` (integer, `1/2`),
#'   `n_legal` (integer; count of legal moves remaining).
#' @examples
#' tsr_status(tsr_new_board())
#' @export
tsr_status <- function(board) {
  .tsr_check_board(board)
  winner <- tsr_check_win(board)
  full <- tsr_is_full(board)
  over <- (winner != 0L) || full
  n_moves <- length(board$history)
  n_legal <- length(tsr_legal_moves(board))
  tibble::tibble(
    winner = as.integer(winner),
    is_full = full,
    is_over = over,
    n_moves = as.integer(n_moves),
    to_move = as.integer(board$to_move),
    n_legal = as.integer(n_legal)
  )
}
