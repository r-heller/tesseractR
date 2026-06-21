.tsr_turning_point_threshold <- 0.15
.tsr_blunder_threshold <- 0.10

#' Analyze a played game move by move
#'
#' Walks a `tsr_game` (from `tsr_play_game()`) and computes per-ply evaluation
#' context using the S3 evaluation core: win probability before/after each move,
#' the move's delta, the best alternative move, regret, and flags for
#' missed wins / missed blocks / turning points.
#'
#' A turning point is a ply with `abs(delta) >= 0.15`.
#'
#' @param game A `tsr_game` object.
#' @param method One of `"heuristic"` (default) or `"rollout"`. Passed to
#'   the underlying `tsr_win_prob()` / `tsr_rate_moves()`.
#' @param n Integer. Rollouts when `method = "rollout"`.
#' @return A tibble, one row per ply, with columns:
#'   `ply`, `player`, `cell`, `i`, `j`, `k`, `l`,
#'   `win_prob_before`, `win_prob_after`, `delta`,
#'   `best_cell`, `best_delta`, `regret`,
#'   `is_best`, `missed_win`, `missed_block`, `is_turning_point`.
#' @examples
#' \donttest{
#' g <- tsr_play_game("random", "random", seed = 1L)
#' tsr_analyze_game(g)
#' }
#' @export
tsr_analyze_game <- function(game, method = c("heuristic", "rollout"),
                             n = 200L) {
  if (!inherits(game, "tsr_game")) {
    cli::cli_abort("{.arg game} must be a {.cls tsr_game}.")
  }
  method <- match.arg(method)
  n_ply <- length(game$moves)
  if (n_ply == 0L) {
    return(.tsr_empty_analysis())
  }
  b <- tsr_new_board()
  ply <- integer(n_ply); player <- integer(n_ply); cell <- integer(n_ply)
  i_co <- integer(n_ply); j_co <- integer(n_ply)
  k_co <- integer(n_ply); l_co <- integer(n_ply)
  wpb <- numeric(n_ply); wpa <- numeric(n_ply); dlt <- numeric(n_ply)
  best <- integer(n_ply); best_dlt <- numeric(n_ply); regret <- numeric(n_ply)
  is_best <- logical(n_ply); missed_w <- logical(n_ply)
  missed_b <- logical(n_ply); is_tp <- logical(n_ply)
  for (p in seq_len(n_ply)) {
    mover <- b$to_move
    opp <- if (mover == 1L) 2L else 1L
    rated <- tsr_rate_moves(b, method = method, n = n)
    wp_before <- tsr_win_prob(b, player = mover, method = method, n = n)
    chosen <- game$moves[p]
    best_cell <- if (nrow(rated) > 0L) rated$cell[1L] else NA_integer_
    chosen_row <- rated[rated$cell == chosen, , drop = FALSE]
    chosen_wp <- if (nrow(chosen_row) > 0L) chosen_row$win_prob[1L] else NA_real_
    best_wp <- if (nrow(rated) > 0L) rated$win_prob[1L] else NA_real_
    opp_threats <- .tsr_immediate_wins(b, opp)
    own_wins <- .tsr_immediate_wins(b, mover)

    ply[p] <- p
    player[p] <- mover
    cell[p] <- chosen
    cc <- .tsr_idx_to_coord(chosen)
    i_co[p] <- cc[1L, "i"]; j_co[p] <- cc[1L, "j"]
    k_co[p] <- cc[1L, "k"]; l_co[p] <- cc[1L, "l"]
    wpb[p] <- wp_before
    wpa[p] <- if (is.na(chosen_wp)) NA_real_ else chosen_wp
    dlt[p] <- wpa[p] - wpb[p]
    best[p] <- as.integer(best_cell)
    best_dlt[p] <- if (is.na(best_wp)) NA_real_ else best_wp - wpb[p]
    regret[p] <- max(0, best_dlt[p] - dlt[p], na.rm = TRUE)
    is_best[p] <- !is.na(best_cell) && chosen == best_cell
    missed_w[p] <- length(own_wins) > 0L && !(chosen %in% own_wins)
    missed_b[p] <- length(opp_threats) > 0L && !(chosen %in% opp_threats) &&
                   length(own_wins) == 0L
    is_tp[p] <- !is.na(dlt[p]) && abs(dlt[p]) >= .tsr_turning_point_threshold
    b <- tsr_move(b, cell = chosen)
  }
  tibble::tibble(
    ply = as.integer(ply), player = as.integer(player),
    cell = as.integer(cell),
    i = as.integer(i_co), j = as.integer(j_co),
    k = as.integer(k_co), l = as.integer(l_co),
    win_prob_before = as.numeric(wpb),
    win_prob_after = as.numeric(wpa),
    delta = as.numeric(dlt),
    best_cell = as.integer(best),
    best_delta = as.numeric(best_dlt),
    regret = as.numeric(regret),
    is_best = is_best,
    missed_win = missed_w,
    missed_block = missed_b,
    is_turning_point = is_tp
  )
}

#' @keywords internal
#' @noRd
.tsr_empty_analysis <- function() {
  tibble::tibble(
    ply = integer(0), player = integer(0), cell = integer(0),
    i = integer(0), j = integer(0), k = integer(0), l = integer(0),
    win_prob_before = numeric(0), win_prob_after = numeric(0),
    delta = numeric(0),
    best_cell = integer(0), best_delta = numeric(0), regret = numeric(0),
    is_best = logical(0), missed_win = logical(0),
    missed_block = logical(0), is_turning_point = logical(0)
  )
}

#' Turning points from a game analysis
#'
#' Filters the analysis to plies where `is_turning_point` is `TRUE`, sorted by
#' `abs(delta)` descending.
#'
#' @param analysis A tibble produced by `tsr_analyze_game()`.
#' @return A tibble with the same schema as `analysis`, possibly zero rows.
#' @examples
#' \donttest{
#' g <- tsr_play_game("random", "random", seed = 1L)
#' tsr_turning_points(tsr_analyze_game(g))
#' }
#' @export
tsr_turning_points <- function(analysis) {
  if (!is.data.frame(analysis)) {
    cli::cli_abort("{.arg analysis} must be a data frame (from {.fn tsr_analyze_game}).")
  }
  if (nrow(analysis) == 0L) return(analysis)
  out <- analysis[isTRUE_vec(analysis$is_turning_point), , drop = FALSE]
  out[order(-abs(out$delta)), ]
}

#' @keywords internal
#' @noRd
isTRUE_vec <- function(x) !is.na(x) & x

#' One-row summary for a played game
#'
#' Compact scorecard with missed-win / missed-block counts, mean regret per
#' player, turning-point count, and final decisiveness.
#'
#' @param game A `tsr_game`.
#' @return A one-row tibble with columns: `winner`, `n_moves`,
#'   `n_missed_wins_x`, `n_missed_wins_o`, `n_missed_blocks_x`,
#'   `n_missed_blocks_o`, `mean_regret_x`, `mean_regret_o`,
#'   `n_turning_points`, `decisiveness`.
#' @examples
#' \donttest{
#' g <- tsr_play_game("random", "random", seed = 1L)
#' tsr_game_summary(g)
#' }
#' @export
tsr_game_summary <- function(game) {
  a <- tsr_analyze_game(game)
  x <- a[a$player == 1L, , drop = FALSE]
  o <- a[a$player == 2L, , drop = FALSE]
  final_wp <- if (nrow(a) > 0L) a$win_prob_after[nrow(a)] else 0.5
  decisiveness <- abs(final_wp - 0.5)
  tibble::tibble(
    winner = as.integer(game$winner),
    n_moves = as.integer(game$n_moves),
    n_missed_wins_x = as.integer(sum(x$missed_win)),
    n_missed_wins_o = as.integer(sum(o$missed_win)),
    n_missed_blocks_x = as.integer(sum(x$missed_block)),
    n_missed_blocks_o = as.integer(sum(o$missed_block)),
    mean_regret_x = if (nrow(x) > 0L) mean(x$regret) else NA_real_,
    mean_regret_o = if (nrow(o) > 0L) mean(o$regret) else NA_real_,
    n_turning_points = as.integer(sum(a$is_turning_point)),
    decisiveness = as.numeric(decisiveness)
  )
}

#' Aggregate behavioral profile for a side across many games
#'
#' Walks a list of `tsr_game` objects, analyses each, and computes the
#' aggregate profile for the chosen side (player X by default).
#'
#' @param games A list of `tsr_game` objects.
#' @param side Integer `1L` (X) or `2L` (O). The side to profile.
#' @param label Optional character. Label for the profile (e.g. a policy name).
#' @return A one-row tibble with `label`, `side`, `n_games`, `n_moves_total`,
#'   `accuracy`, `mean_regret`, `blunder_rate`, `win_conversion`,
#'   `defense_rate`, `aggression`, `mean_decisiveness`.
#' @examples
#' \donttest{
#' g1 <- tsr_play_game("random", "random", seed = 1L)
#' g2 <- tsr_play_game("random", "random", seed = 2L)
#' tsr_behavior_profile(list(g1, g2), side = 1L, label = "random")
#' }
#' @export
tsr_behavior_profile <- function(games, side = 1L, label = NULL) {
  if (!is.list(games) || any(!vapply(games, inherits, logical(1L), "tsr_game"))) {
    cli::cli_abort("{.arg games} must be a list of {.cls tsr_game} objects.")
  }
  side <- as.integer(side)
  if (length(side) != 1L || !(side %in% c(1L, 2L))) {
    cli::cli_abort("{.arg side} must be {.code 1L} or {.code 2L}.")
  }
  if (is.null(label)) label <- "profile"
  analyses <- lapply(games, tsr_analyze_game)
  side_rows <- lapply(analyses, function(a) a[a$player == side, , drop = FALSE])
  side_a <- do.call(rbind, side_rows)
  if (is.null(side_a) || nrow(side_a) == 0L) {
    return(tibble::tibble(
      label = label, side = side, n_games = length(games),
      n_moves_total = 0L, accuracy = NA_real_, mean_regret = NA_real_,
      blunder_rate = NA_real_, win_conversion = NA_real_,
      defense_rate = NA_real_, aggression = NA_real_,
      mean_decisiveness = NA_real_
    ))
  }
  n_games <- length(games)
  n_total <- nrow(side_a)
  accuracy <- mean(side_a$is_best)
  mean_regret <- mean(side_a$regret, na.rm = TRUE)
  blunder_rate <- mean(side_a$regret >= .tsr_blunder_threshold, na.rm = TRUE)
  # win_conversion: when ahead at some ply (win_prob_before > 0.5), share of
  # games converted to a win.
  ahead_games <- vapply(analyses, function(a) {
    sa <- a[a$player == side, , drop = FALSE]
    any(sa$win_prob_before > 0.5, na.rm = TRUE)
  }, logical(1L))
  winners <- vapply(games, function(g) g$winner == side, logical(1L))
  win_conversion <- if (sum(ahead_games) > 0L) {
    sum(winners & ahead_games) / sum(ahead_games)
  } else {
    NA_real_
  }
  # defense_rate: when threatened (opp had immediate win) and there was a
  # block move, share of plies that took it. Use !missed_block as proxy.
  threatened <- side_a$missed_block | (!side_a$missed_block & side_a$is_best == TRUE & FALSE)
  # Simpler proxy: a ply where opp had a threat is one where missed_block is
  # TRUE (didn't block) or the chosen move was a block. We tagged missed_block
  # only on plies with a threat and no own win, so:
  threat_plies <- side_a$missed_block | (
    !side_a$missed_block &
      vapply(seq_len(nrow(side_a)), function(i) FALSE, logical(1L))
  )
  # Better: replay each game and count.
  threats <- 0L; blocked <- 0L
  for (gi in seq_along(games)) {
    b <- tsr_new_board()
    for (m in seq_along(games[[gi]]$moves)) {
      if (b$to_move == side) {
        opp_w <- .tsr_immediate_wins(b, if (side == 1L) 2L else 1L)
        if (length(opp_w) > 0L) {
          threats <- threats + 1L
          if (games[[gi]]$moves[m] %in% opp_w) blocked <- blocked + 1L
        }
      }
      b <- tsr_move(b, cell = games[[gi]]$moves[m])
    }
  }
  defense_rate <- if (threats > 0L) blocked / threats else NA_real_

  # aggression: share of moves that create a new 3-in-line for `side`.
  aggro_n <- 0L; aggro_d <- 0L
  for (gi in seq_along(games)) {
    b <- tsr_new_board()
    for (m in seq_along(games[[gi]]$moves)) {
      if (b$to_move == side) {
        before <- length(.tsr_immediate_wins(b, side))
        nb <- tsr_move(b, cell = games[[gi]]$moves[m])
        after <- length(.tsr_immediate_wins(nb, side))
        aggro_d <- aggro_d + 1L
        if (after > before) aggro_n <- aggro_n + 1L
      }
      b <- tsr_move(b, cell = games[[gi]]$moves[m])
    }
  }
  aggression <- if (aggro_d > 0L) aggro_n / aggro_d else NA_real_

  mean_decisiveness <- mean(vapply(analyses, function(a) {
    if (nrow(a) == 0L) return(NA_real_)
    abs(a$win_prob_after[nrow(a)] - 0.5)
  }, numeric(1L)), na.rm = TRUE)

  tibble::tibble(
    label = label, side = side, n_games = n_games,
    n_moves_total = n_total,
    accuracy = accuracy, mean_regret = mean_regret,
    blunder_rate = blunder_rate, win_conversion = win_conversion,
    defense_rate = defense_rate, aggression = aggression,
    mean_decisiveness = mean_decisiveness
  )
}

#' Combine multiple behavioral profiles
#'
#' Row-binds a sequence of `tsr_behavior_profile()` tibbles for side-by-side
#' comparison. Errors on mismatched columns.
#'
#' @param ... Tibbles produced by `tsr_behavior_profile()`.
#' @return A tibble with one row per input.
#' @examples
#' \donttest{
#' g1 <- tsr_play_game("random", "random", seed = 1L)
#' p1 <- tsr_behavior_profile(list(g1), side = 1L, label = "random")
#' p2 <- tsr_behavior_profile(list(g1), side = 2L, label = "random")
#' tsr_compare_profiles(p1, p2)
#' }
#' @export
tsr_compare_profiles <- function(...) {
  profs <- list(...)
  if (length(profs) == 0L) {
    cli::cli_abort("Supply at least one profile.")
  }
  cols <- lapply(profs, names)
  ref <- cols[[1L]]
  if (!all(vapply(cols, identical, logical(1L), ref))) {
    cli::cli_abort("All profiles must have the same columns.")
  }
  do.call(rbind, profs)
}

#' Win-probability trajectory for a game
#'
#' Plots `win_prob_after` (from `tsr_analyze_game()`) over plies, with a 0.5
#' reference and turning points marked. Returns a `ggplot`.
#'
#' @param analysis A tibble from `tsr_analyze_game()`.
#' @return A `ggplot` object.
#' @examples
#' \donttest{
#' g <- tsr_play_game("random", "random", seed = 1L)
#' tsr_plot_winprob(tsr_analyze_game(g))
#' }
#' @export
tsr_plot_winprob <- function(analysis) {
  if (!is.data.frame(analysis)) {
    cli::cli_abort("{.arg analysis} must be a data frame.")
  }
  df <- tibble::tibble(
    ply = analysis$ply,
    win_prob_after = analysis$win_prob_after,
    player = factor(analysis$player, levels = c(1L, 2L), labels = c("X", "O")),
    is_turning_point = analysis$is_turning_point
  )
  tp <- df[df$is_turning_point, , drop = FALSE]
  ggplot2::ggplot(df, ggplot2::aes(x = .data$ply, y = .data$win_prob_after)) +
    ggplot2::geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey60") +
    ggplot2::geom_line(colour = "#0072B2") +
    ggplot2::geom_point(ggplot2::aes(colour = .data$player), size = 2) +
    ggplot2::geom_point(
      data = tp,
      ggplot2::aes(x = .data$ply, y = .data$win_prob_after),
      inherit.aes = FALSE,
      shape = 1, size = 5, stroke = 1.2, colour = "#CC79A7"
    ) +
    ggplot2::scale_colour_manual(values = c(X = "#0072B2", O = "#E69F00")) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      x = "Ply", y = "Win probability after move",
      title = "Win-probability trajectory"
    )
}
