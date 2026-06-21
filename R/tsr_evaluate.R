.tsr_eval_weights <- c(1, 10, 100)
.tsr_terminal_win <- 1e6
.tsr_default_calibration <- list(a = 0, b = 25)

#' @keywords internal
#' @noRd
.tsr_get_calibration <- function() {
  if (exists(".tsr_calibration", envir = asNamespace("tesseractR"))) {
    obj <- get(".tsr_calibration", envir = asNamespace("tesseractR"))
    if (is.list(obj) && all(c("a", "b") %in% names(obj))) return(obj)
  }
  .tsr_default_calibration
}

#' @keywords internal
#' @noRd
.tsr_raw_evaluate <- function(board, player) {
  L <- .tsr_win_lines()
  s <- board$state
  opp <- if (player == 1L) 2L else 1L
  vals <- matrix(s[L], nrow = nrow(L), ncol = 4L)
  has_p   <- rowSums(vals == player) > 0L
  has_opp <- rowSums(vals == opp) > 0L
  live <- has_p != has_opp
  n_p   <- rowSums(vals == player)
  n_opp <- rowSums(vals == opp)
  pos_score <- 0
  if (any(live & has_p)) {
    idx <- which(live & has_p)
    pos_score <- sum(.tsr_eval_weights[pmin(n_p[idx], 3L)])
  }
  neg_score <- 0
  if (any(live & has_opp)) {
    idx <- which(live & has_opp)
    neg_score <- sum(.tsr_eval_weights[pmin(n_opp[idx], 3L)])
  }
  as.numeric(pos_score - neg_score)
}

#' @keywords internal
#' @noRd
.tsr_evaluate <- function(board, player, depth = 0L) {
  winner <- tsr_check_win(board)
  if (winner == player) {
    return(.tsr_terminal_win - depth)
  }
  if (winner != 0L) {
    return(-.tsr_terminal_win + depth)
  }
  if (tsr_is_full(board)) return(0)
  .tsr_raw_evaluate(board, player)
}

#' Evaluate a position
#'
#' Heuristic positional score from the perspective of `player`. Positive favors
#' `player`. The scale is unitless and only comparable within the same board
#' size; it is the raw input fed to the calibrated win-probability mapping.
#'
#' Terminal positions short-circuit: a win returns a large positive sentinel
#' (approximately `1e6`), a loss the negation, and a draw `0`.
#'
#' @param board A `ttt_board`.
#' @param player Integer `1L` or `2L`. If `NULL` (default), the position is
#'   evaluated from `board$to_move`'s perspective.
#' @return Numeric scalar.
#' @examples
#' tsr_evaluate(tsr_new_board())
#' @export
tsr_evaluate <- function(board, player = NULL) {
  .tsr_check_board(board)
  if (is.null(player)) player <- board$to_move
  player <- as.integer(player)
  if (length(player) != 1L || !(player %in% c(1L, 2L))) {
    cli::cli_abort("{.arg player} must be {.code 1L} or {.code 2L}.")
  }
  .tsr_evaluate(board, player, depth = 0L)
}

#' Calibrated win probability for a position
#'
#' Returns the estimated probability in `[0, 1]` that `player` wins from the
#' given position. Two methods are supported:
#'
#' - `"heuristic"` (default, real-time): maps `tsr_evaluate()` through a
#'   logistic calibration `p = plogis((score - a) / b)`. The coefficients
#'   `a`, `b` are fit by a `data-raw/` script (S6) and stored as internal
#'   package data; provisional defaults are used until calibration is run.
#' - `"rollout"` (offline accuracy): runs `n` policy-guided Monte-Carlo
#'   playouts using a light heuristic policy and returns the empirical win
#'   share. Slower in pure R; intended for offline analysis, not the live UI.
#'
#' Terminal positions short-circuit: a win returns `1`, a loss `0`, a draw `0.5`.
#'
#' @param board A `ttt_board`.
#' @param player Integer `1L` or `2L`, or `NULL` (default, uses `board$to_move`).
#' @param method One of `"heuristic"` (default) or `"rollout"`.
#' @param n Integer. Number of rollouts when `method = "rollout"`.
#' @return Numeric scalar in `[0, 1]`.
#' @examples
#' tsr_win_prob(tsr_new_board())
#' \donttest{
#' tsr_win_prob(tsr_new_board(), method = "rollout", n = 20L)
#' }
#' @export
tsr_win_prob <- function(board, player = NULL,
                         method = c("heuristic", "rollout"),
                         n = 200L) {
  .tsr_check_board(board)
  method <- match.arg(method)
  if (is.null(player)) player <- board$to_move
  player <- as.integer(player)
  if (length(player) != 1L || !(player %in% c(1L, 2L))) {
    cli::cli_abort("{.arg player} must be {.code 1L} or {.code 2L}.")
  }
  winner <- tsr_check_win(board)
  if (winner == player) return(1)
  if (winner != 0L) return(0)
  if (tsr_is_full(board)) return(0.5)
  if (method == "heuristic") {
    cal <- .tsr_get_calibration()
    score <- .tsr_raw_evaluate(board, player)
    return(unname(stats::plogis((score - cal$a) / cal$b)))
  }
  n <- as.integer(n)
  if (length(n) != 1L || n < 1L) {
    cli::cli_abort("{.arg n} must be a positive integer scalar.")
  }
  wins <- 0
  draws <- 0
  for (g in seq_len(n)) {
    res <- .tsr_random_playout(board)
    if (res == player) wins <- wins + 1L
    if (res == 0L) draws <- draws + 1L
  }
  unname((wins + 0.5 * draws) / n)
}

#' @keywords internal
#' @noRd
.tsr_random_playout <- function(board) {
  b <- board
  while (tsr_check_win(b) == 0L && !tsr_is_full(b)) {
    moves <- tsr_legal_moves(b)
    if (length(moves) == 0L) break
    # Light heuristic: prefer the move maximizing the moving side's score.
    scores <- vapply(moves, function(m) {
      .tsr_raw_evaluate(.tsr_apply_move(b, m), b$to_move)
    }, numeric(1L))
    top <- moves[which(scores == max(scores))]
    pick <- if (length(top) == 1L) top else top[sample.int(length(top), 1L)]
    b <- .tsr_apply_move(b, pick)
  }
  tsr_check_win(b)
}

#' @keywords internal
#' @noRd
.tsr_apply_move <- function(board, idx) {
  st <- board$state
  st[idx] <- board$to_move
  tm <- if (board$to_move == 1L) 2L else 1L
  new_ttt_board(state = st, to_move = tm, history = c(board$history, idx))
}

#' Rate every legal move from a position
#'
#' For each legal move, applies it and scores the resulting position from the
#' moving side's perspective. Returns a tibble sorted best-first with type-
#' stable columns; on a finished board returns a zero-row tibble with the same
#' schema.
#'
#' @param board A `ttt_board`.
#' @param method One of `"heuristic"` (default) or `"rollout"`.
#' @param n Integer. Number of rollouts when `method = "rollout"`.
#' @return A tibble with columns:
#'   `cell` (integer linear index),
#'   `i`, `j`, `k`, `l` (integer coordinates in `0:3`),
#'   `score` (numeric raw evaluation after the move),
#'   `win_prob` (numeric in `[0, 1]`),
#'   `rank` (integer; `1` = best),
#'   `is_best` (logical),
#'   `is_winning` (logical; the move completes a line),
#'   `is_blocking` (logical; the move denies an opponent's immediate win).
#'   Sorted by `rank`.
#' @examples
#' tsr_rate_moves(tsr_new_board())
#' @export
tsr_rate_moves <- function(board,
                           method = c("heuristic", "rollout"),
                           n = 200L) {
  .tsr_check_board(board)
  method <- match.arg(method)
  empty_tbl <- tibble::tibble(
    cell = integer(0), i = integer(0), j = integer(0),
    k = integer(0), l = integer(0),
    score = numeric(0), win_prob = numeric(0),
    rank = integer(0), is_best = logical(0),
    is_winning = logical(0), is_blocking = logical(0)
  )
  if (tsr_check_win(board) != 0L || tsr_is_full(board)) return(empty_tbl)
  moves <- tsr_legal_moves(board)
  if (length(moves) == 0L) return(empty_tbl)
  player <- board$to_move
  opp <- if (player == 1L) 2L else 1L

  opp_winning <- .tsr_immediate_wins(board, opp)

  score <- numeric(length(moves))
  win_prob <- numeric(length(moves))
  is_winning <- logical(length(moves))
  is_blocking <- logical(length(moves))
  for (a in seq_along(moves)) {
    nb <- .tsr_apply_move(board, moves[a])
    score[a] <- .tsr_evaluate(nb, player, depth = 1L)
    win_prob[a] <- tsr_win_prob(nb, player, method = method, n = n)
    is_winning[a] <- tsr_check_win(nb) == player
    is_blocking[a] <- moves[a] %in% opp_winning
  }
  coord <- .tsr_idx_to_coord(moves)
  ord <- order(-score, moves)
  rnk <- integer(length(moves))
  rnk[ord] <- seq_along(moves)
  best <- rnk == 1L
  out <- tibble::tibble(
    cell = as.integer(moves),
    i = as.integer(coord[, "i"]),
    j = as.integer(coord[, "j"]),
    k = as.integer(coord[, "k"]),
    l = as.integer(coord[, "l"]),
    score = as.numeric(score),
    win_prob = as.numeric(win_prob),
    rank = as.integer(rnk),
    is_best = best,
    is_winning = is_winning,
    is_blocking = is_blocking
  )
  out[order(out$rank), ]
}

#' @keywords internal
#' @noRd
.tsr_immediate_wins <- function(board, player) {
  L <- .tsr_win_lines()
  s <- board$state
  vals <- matrix(s[L], nrow = nrow(L), ncol = 4L)
  n_p <- rowSums(vals == player)
  n_other <- rowSums(vals != 0L & vals != player)
  threat <- n_p == 3L & n_other == 0L
  if (!any(threat)) return(integer(0))
  rows <- L[threat, , drop = FALSE]
  vrows <- matrix(s[rows], nrow = nrow(rows), ncol = 4L)
  out <- integer(nrow(rows))
  for (r in seq_len(nrow(rows))) {
    out[r] <- rows[r, vrows[r, ] == 0L][1L]
  }
  unique(as.integer(out))
}
