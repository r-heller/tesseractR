#' @keywords internal
#' @noRd
.tsr_policy <- function(spec) {
  if (is.function(spec)) return(spec)
  if (is.character(spec) && length(spec) == 1L) {
    if (spec == "random") return(.tsr_policy_random())
    if (spec == "greedy") return(.tsr_policy_greedy())
    if (grepl("^ai", spec)) {
      d <- as.integer(sub("^ai([0-9]+)?$", "\\1", spec))
      if (is.na(d)) d <- 2L
      return(.tsr_policy_ai(d))
    }
  }
  cli::cli_abort("Unknown policy {.val {spec}}; use {.val random}, {.val greedy}, or {.val ai}.")
}

#' @keywords internal
#' @noRd
.tsr_policy_random <- function() {
  function(board) {
    moves <- tsr_legal_moves(board)
    moves[sample.int(length(moves), 1L)]
  }
}

#' @keywords internal
#' @noRd
.tsr_policy_greedy <- function() {
  function(board) {
    moves <- tsr_legal_moves(board)
    sc <- vapply(moves, function(m) {
      .tsr_raw_evaluate(.tsr_apply_move(board, m), board$to_move)
    }, numeric(1L))
    top <- moves[which(sc == max(sc))]
    if (length(top) == 1L) top else top[1L]
  }
}

#' @keywords internal
#' @noRd
.tsr_policy_ai <- function(difficulty = 2L) {
  d <- as.integer(difficulty)
  function(board) tsr_ai_move(board, difficulty = d)
}

#' @keywords internal
#' @noRd
.tsr_policy_label <- function(spec) {
  if (is.function(spec)) return("custom")
  if (is.character(spec)) return(spec)
  "unknown"
}

#' Play a single game between two policies
#'
#' Simulates one complete 4D tic-tac-toe game with the given policies for
#' player X and player O. Returns a `tsr_game` object recording the move
#' sequence and outcome.
#'
#' Built-in policy strings: `"random"`, `"greedy"`, `"ai"` (depth 2), or
#' `"aiN"` for `N` in `1:4` (e.g. `"ai3"`).
#'
#' @param policy_x Policy for player X. Either a built-in string or a function
#'   `(board) -> integer cell index`.
#' @param policy_o Policy for player O. Same forms as `policy_x`.
#' @param seed Optional integer. If supplied, RNG is seeded via
#'   `withr::local_seed()`; global `.Random.seed` is unchanged.
#' @return A `tsr_game` object: list with `moves` (integer vector of cell
#'   indices, in order), `winner` (`0/1/2`), `n_moves` (integer),
#'   `policies` (named character `c(x, o)`), `final_board` (a `ttt_board`),
#'   `to_move` (integer vector — moving player at each ply).
#' @examples
#' g <- tsr_play_game("random", "random", seed = 1L)
#' g$winner
#' @export
tsr_play_game <- function(policy_x, policy_o, seed = NULL) {
  px <- .tsr_policy(policy_x)
  po <- .tsr_policy(policy_o)
  body <- function() {
    b <- tsr_new_board()
    moves <- integer(0)
    movers <- integer(0)
    while (tsr_check_win(b) == 0L && !tsr_is_full(b)) {
      mover <- b$to_move
      cell <- if (mover == 1L) px(b) else po(b)
      movers <- c(movers, mover)
      moves <- c(moves, as.integer(cell))
      b <- tsr_move(b, cell = cell)
    }
    list(moves = moves, movers = movers, final_board = b)
  }
  res <- if (is.null(seed)) body() else withr::with_seed(seed, body())
  out <- list(
    moves = as.integer(res$moves),
    winner = as.integer(tsr_check_win(res$final_board)),
    n_moves = length(res$moves),
    policies = c(x = .tsr_policy_label(policy_x), o = .tsr_policy_label(policy_o)),
    final_board = res$final_board,
    to_move = as.integer(res$movers)
  )
  class(out) <- "tsr_game"
  out
}

#' Print method for a played game
#'
#' One-screen `cli` summary of a `tsr_game`. Returns its input invisibly.
#'
#' @param x A `tsr_game`.
#' @param ... Reserved.
#' @return `x`, invisibly.
#' @examples
#' print(tsr_play_game("random", "random", seed = 1L))
#' @export
#' @method print tsr_game
print.tsr_game <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cli_h2("<tsr_game>")
  cli::cli_text("X policy: {x$policies[['x']]}")
  cli::cli_text("O policy: {x$policies[['o']]}")
  res <- if (x$winner == 1L) "X wins" else
         if (x$winner == 2L) "O wins" else "draw"
  cli::cli_text("Result: {res} after {x$n_moves} move{?s}")
  invisible(x)
}

#' Simulate many games between two policies
#'
#' Runs `n_games` self-play games and returns a tibble summarising each game.
#'
#' Performance: pure-R self-play over 256 cells is slow, and deep-AI policies
#' multiply the cost. Meaningful opening statistics may need thousands of
#' games; the hot-path functions are flagged for future Rcpp replacement.
#'
#' @param policy_x Policy for player X. See `tsr_play_game()`.
#' @param policy_o Policy for player O.
#' @param n_games Integer. Number of games to play (default `100L`).
#' @param seed Optional integer. Seeds the RNG via `withr::local_seed()`;
#'   global `.Random.seed` is unchanged.
#' @param verbose Logical. Show a progress bar in interactive sessions.
#' @return A tibble, one row per game, with columns:
#'   `game_id` (integer), `policy_x` (character), `policy_o` (character),
#'   `winner` (integer `0/1/2`), `n_moves` (integer),
#'   `first_move` (integer cell),
#'   `first_move_i`, `first_move_j`, `first_move_k`, `first_move_l` (integer).
#' @examples
#' \donttest{
#' tsr_simulate("random", "random", n_games = 5L, seed = 1L, verbose = FALSE)
#' }
#' @export
tsr_simulate <- function(policy_x, policy_o, n_games = 100L,
                         seed = NULL, verbose = TRUE) {
  n_games <- as.integer(n_games)
  if (length(n_games) != 1L || n_games < 1L) {
    cli::cli_abort("{.arg n_games} must be a positive integer scalar.")
  }
  show_bar <- isTRUE(verbose) && rlang::is_interactive()
  if (show_bar) {
    cli::cli_progress_bar("Simulating games", total = n_games)
  }
  winners <- integer(n_games)
  n_moves <- integer(n_games)
  first_move <- integer(n_games)
  body <- function() {
    for (g in seq_len(n_games)) {
      game <- tsr_play_game(policy_x, policy_o, seed = NULL)
      winners[g] <<- game$winner
      n_moves[g] <<- game$n_moves
      first_move[g] <<- if (length(game$moves) > 0L) game$moves[1L] else NA_integer_
      if (show_bar) cli::cli_progress_update()
    }
  }
  if (is.null(seed)) body() else withr::with_seed(seed, body())
  if (show_bar) cli::cli_progress_done()
  coord <- .tsr_idx_to_coord(ifelse(is.na(first_move), 1L, first_move))
  coord[is.na(first_move), ] <- NA_integer_
  tibble::tibble(
    game_id = seq_len(n_games),
    policy_x = .tsr_policy_label(policy_x),
    policy_o = .tsr_policy_label(policy_o),
    winner = as.integer(winners),
    n_moves = as.integer(n_moves),
    first_move = as.integer(first_move),
    first_move_i = as.integer(coord[, "i"]),
    first_move_j = as.integer(coord[, "j"]),
    first_move_k = as.integer(coord[, "k"]),
    first_move_l = as.integer(coord[, "l"])
  )
}

#' Opening statistics from a simulation
#'
#' Aggregates a `tsr_simulate()` result into per-group win rates with Wilson
#' confidence intervals.
#'
#' @param sim A tibble produced by `tsr_simulate()`.
#' @param by Character. Grouping column(s). Defaults to `"first_move"`.
#' @return A tibble with columns: the grouping column(s), `n_games`,
#'   `win_rate_x`, `win_rate_o`, `draw_rate`, `ci_lo`, `ci_hi`
#'   (Wilson 95% CI for `win_rate_x`).
#' @examples
#' \donttest{
#' sim <- tsr_simulate("random", "random", n_games = 5L, seed = 1L, verbose = FALSE)
#' tsr_opening_stats(sim)
#' }
#' @export
tsr_opening_stats <- function(sim, by = c("first_move", "difficulty")) {
  if (!is.data.frame(sim)) {
    cli::cli_abort("{.arg sim} must be a data frame (from {.fn tsr_simulate}).")
  }
  by <- match.arg(by)
  if (!(by %in% names(sim))) {
    cli::cli_abort("Column {.field {by}} not found in {.arg sim}.")
  }
  keys <- sort(unique(sim[[by]]))
  rows <- lapply(keys, function(k) {
    sub <- sim[sim[[by]] == k, , drop = FALSE]
    n <- nrow(sub)
    wx <- sum(sub$winner == 1L)
    wo <- sum(sub$winner == 2L)
    dr <- sum(sub$winner == 0L)
    px <- wx / n
    z <- stats::qnorm(0.975)
    denom <- 1 + z^2 / n
    centre <- (px + z^2 / (2 * n)) / denom
    half <- (z * sqrt(px * (1 - px) / n + z^2 / (4 * n^2))) / denom
    ci_lo <- max(0, centre - half)
    ci_hi <- min(1, centre + half)
    tibble::tibble(
      key = k, n_games = as.integer(n),
      win_rate_x = px, win_rate_o = wo / n,
      draw_rate = dr / n,
      ci_lo = ci_lo, ci_hi = ci_hi
    )
  })
  out <- do.call(rbind, rows)
  names(out)[1L] <- by
  out
}
