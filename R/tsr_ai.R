#' AI move on a 4D tic-tac-toe board
#'
#' Returns the linear cell index of the AI's chosen move using depth-limited
#' negamax with alpha-beta pruning. At difficulty `>= 1`, an immediate winning
#' move is always taken and an immediate opponent threat is always blocked.
#'
#' Tie-breaking among moves with equal evaluation is deterministic (lowest
#' linear index wins).
#'
#' Note: search is exponential in depth and runs in pure R; depth `4` may take
#' several seconds on a 256-cell board. Rcpp acceleration is a planned future
#' enhancement and is intentionally out of scope for this release.
#'
#' @param board A `ttt_board`.
#' @param difficulty Integer in `1:4` (default `2L`). Maps to search depth.
#' @return Integer scalar: the chosen cell's linear index in `1:256`.
#' @examples
#' tsr_ai_move(tsr_new_board(), difficulty = 1L)
#' \donttest{
#' tsr_ai_move(tsr_new_board(), difficulty = 3L)
#' }
#' @export
tsr_ai_move <- function(board, difficulty = 2L) {
  .tsr_check_board(board)
  difficulty <- as.integer(difficulty)
  if (length(difficulty) != 1L || !(difficulty %in% 1:4)) {
    cli::cli_abort("{.arg difficulty} must be an integer in {.code 1:4}.")
  }
  if (tsr_check_win(board) != 0L || tsr_is_full(board)) {
    cli::cli_abort("Cannot ask the AI to move on a finished board.")
  }
  moves <- tsr_legal_moves(board)
  if (length(moves) == 0L) {
    cli::cli_abort("No legal moves available.")
  }
  player <- board$to_move
  opp <- if (player == 1L) 2L else 1L

  win_now <- .tsr_immediate_wins(board, player)
  if (length(win_now) > 0L) return(min(win_now))

  block_now <- .tsr_immediate_wins(board, opp)
  if (length(block_now) > 0L) return(min(block_now))

  depth <- difficulty
  scored <- vapply(moves, function(m) {
    nb <- .tsr_apply_move(board, m)
    .tsr_raw_evaluate(nb, player)
  }, numeric(1L))
  ord <- order(-scored, moves)
  moves <- moves[ord]

  best_score <- -Inf
  best_move <- moves[1L]
  alpha <- -Inf; beta <- Inf
  for (m in moves) {
    nb <- .tsr_apply_move(board, m)
    val <- -.tsr_negamax(nb, depth - 1L, -beta, -alpha, opp, player)
    if (val > best_score ||
        (val == best_score && m < best_move)) {
      best_score <- val
      best_move <- m
    }
    if (val > alpha) alpha <- val
    if (alpha >= beta) break
  }
  as.integer(best_move)
}

#' @keywords internal
#' @noRd
.tsr_negamax <- function(board, depth, alpha, beta, side, root_player) {
  winner <- tsr_check_win(board)
  if (winner != 0L || depth == 0L || tsr_is_full(board)) {
    sgn <- if (side == root_player) 1 else -1
    return(sgn * .tsr_evaluate(board, root_player, depth = depth))
  }
  moves <- tsr_legal_moves(board)
  scored <- vapply(moves, function(m) {
    nb <- .tsr_apply_move(board, m)
    .tsr_raw_evaluate(nb, side)
  }, numeric(1L))
  ord <- order(-scored, moves)
  moves <- moves[ord]
  best <- -Inf
  opp <- if (side == 1L) 2L else 1L
  for (m in moves) {
    nb <- .tsr_apply_move(board, m)
    val <- -.tsr_negamax(nb, depth - 1L, -beta, -alpha, opp, root_player)
    if (val > best) best <- val
    if (val > alpha) alpha <- val
    if (alpha >= beta) break
  }
  best
}
