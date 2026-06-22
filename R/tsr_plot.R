.tsr_color_x <- "#0072B2"  # Okabe-Ito blue
.tsr_color_o <- "#E69F00"  # Okabe-Ito orange
.tsr_color_win <- "#CC79A7"  # Okabe-Ito pink

#' @keywords internal
#' @noRd
.tsr_layout <- function(coords, block_axes = c("k", "l"), inner_axes = c("i", "j"),
                        gap = 1) {
  bx <- coords[, block_axes[1L]]
  by <- coords[, block_axes[2L]]
  ix <- coords[, inner_axes[1L]]
  iy <- coords[, inner_axes[2L]]
  x <- bx * (4 + gap) + ix
  y <- (max(by) - by) * (4 + gap) + (3 - iy)
  cbind(x = x, y = y)
}

#' Plot a 4D tic-tac-toe board as a 4x4 grid of 4x4 boards
#'
#' Renders the 256-cell hypercube as a 4x4 outer grid (indexed by `(k, l)`),
#' where each outer cell contains a 4x4 inner board (indexed by `(i, j)`).
#' Returns a `ggplot` object; never renders in place.
#'
#' @param board A `ttt_board`.
#' @param highlight_win Logical. If `TRUE` (default) and the game is over, the
#'   four cells of the winning line are emphasised.
#' @param ... Reserved for future arguments.
#' @return A `ggplot` object.
#' @examples
#' tsr_plot(tsr_new_board())
#' @export
tsr_plot <- function(board, highlight_win = TRUE, ...) {
  .tsr_check_board(board)
  rlang::check_dots_empty()
  idx <- 1:256
  coords <- .tsr_idx_to_coord(idx)
  xy <- .tsr_layout(coords)
  marks <- board$state
  mark_lbl <- ifelse(marks == 1L, "X", ifelse(marks == 2L, "O", ""))
  mark_col <- ifelse(marks == 1L, .tsr_color_x,
              ifelse(marks == 2L, .tsr_color_o, "grey80"))
  df <- tibble::tibble(
    cell = as.integer(idx),
    x = xy[, "x"], y = xy[, "y"],
    mark = mark_lbl,
    colour = mark_col
  )
  winner <- tsr_check_win(board)
  status_lbl <- if (winner == 1L) {
    "Player X wins"
  } else if (winner == 2L) {
    "Player O wins"
  } else if (tsr_is_full(board)) {
    "Draw"
  } else {
    paste0("Turn: ", if (board$to_move == 1L) "X" else "O")
  }
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::geom_tile(fill = "grey95", colour = "grey60", width = 0.95, height = 0.95) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$mark, colour = .data$colour),
      fontface = "bold", size = 5
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::coord_equal() +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(title = "tesseractR: 4D tic-tac-toe", subtitle = status_lbl)

  if (highlight_win && winner != 0L) {
    wl <- tsr_winning_line(board)
    if (length(wl) == 4L) {
      # Index into the full-board layout: `.tsr_layout()` derives the block row
      # from `max(by)` of its input, so recomputing it on the 4-cell subset
      # would misplace the highlight whenever the line does not reach l = 3.
      xyw <- xy[wl, , drop = FALSE]
      wdf <- tibble::tibble(x = xyw[, "x"], y = xyw[, "y"])
      p <- p + ggplot2::geom_point(
        data = wdf,
        ggplot2::aes(x = .data$x, y = .data$y),
        inherit.aes = FALSE,
        shape = 1, size = 9, stroke = 1.4, colour = .tsr_color_win
      )
    }
  }
  p
}

#' Plot a 3D slice of a 4D tic-tac-toe board
#'
#' Holds one of the four hypercube axes at a fixed value, dropping the board to
#' a 3D 4x4x4 cube, then renders that cube as a 1x4 strip of 4x4 mini-boards.
#' Use this view to make through-all-four-dimensions diagonals read as straight
#' lines within a single plane. Returns a `ggplot` object.
#'
#' Convention: of the three remaining axes, the **highest-numbered** is used as
#' the block axis (the strip dimension); the other two form each mini-board.
#'
#' @param board A `ttt_board`.
#' @param axis One of `"i"`, `"j"`, `"k"`, `"l"`. The axis to hold fixed.
#' @param at Integer `0:3`. The value at which to fix `axis`.
#' @param highlight_win Logical. Emphasise the winning line if it lies in
#'   (or intersects) the slice.
#' @param ... Reserved for future arguments.
#' @return A `ggplot` object.
#' @examples
#' tsr_plot_slice(tsr_new_board(), axis = "l", at = 0L)
#' @export
tsr_plot_slice <- function(board, axis = c("i", "j", "k", "l"), at = 0L,
                           highlight_win = TRUE, ...) {
  .tsr_check_board(board)
  rlang::check_dots_empty()
  axis <- match.arg(axis)
  at <- as.integer(at)
  if (length(at) != 1L || at < 0L || at > 3L) {
    cli::cli_abort("{.arg at} must be a single integer in {.code 0:3}.")
  }
  all_axes <- c("i", "j", "k", "l")
  remaining <- setdiff(all_axes, axis)
  block_axis <- remaining[3L]
  inner_axes <- remaining[1:2]
  coord <- .tsr_idx_to_coord(1:256)
  in_slice <- coord[, axis] == at
  cells <- which(in_slice)
  sub_coord <- coord[in_slice, , drop = FALSE]
  xy <- .tsr_layout(
    cbind(i = sub_coord[, inner_axes[1L]], j = sub_coord[, inner_axes[2L]],
          k = sub_coord[, block_axis], l = 0L),
    block_axes = c("k", "l"), inner_axes = c("i", "j")
  )
  marks <- board$state[cells]
  mark_lbl <- ifelse(marks == 1L, "X", ifelse(marks == 2L, "O", ""))
  mark_col <- ifelse(marks == 1L, .tsr_color_x,
              ifelse(marks == 2L, .tsr_color_o, "grey80"))
  df <- tibble::tibble(
    cell = as.integer(cells),
    x = xy[, "x"], y = xy[, "y"],
    mark = mark_lbl, colour = mark_col
  )

  winner <- tsr_check_win(board)
  subtitle <- sprintf("Slice %s = %d", axis, at)
  if (winner != 0L) {
    subtitle <- paste0(subtitle, ", winner: ",
                       if (winner == 1L) "X" else "O")
  }
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::geom_tile(fill = "grey95", colour = "grey60",
                       width = 0.95, height = 0.95) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$mark, colour = .data$colour),
      fontface = "bold", size = 5
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::coord_equal() +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(title = "tesseractR: slice view", subtitle = subtitle)

  if (highlight_win && winner != 0L) {
    wl <- tsr_winning_line(board)
    if (length(wl) == 4L) {
      win_coord <- .tsr_idx_to_coord(wl)
      in_slice_win <- win_coord[, axis] == at
      if (any(in_slice_win)) {
        wc <- win_coord[in_slice_win, , drop = FALSE]
        xyw <- .tsr_layout(
          cbind(i = wc[, inner_axes[1L]], j = wc[, inner_axes[2L]],
                k = wc[, block_axis], l = 0L),
          block_axes = c("k", "l"), inner_axes = c("i", "j")
        )
        wdf <- tibble::tibble(x = xyw[, "x"], y = xyw[, "y"])
        p <- p + ggplot2::geom_point(
          data = wdf,
          ggplot2::aes(x = .data$x, y = .data$y),
          inherit.aes = FALSE,
          shape = 1, size = 9, stroke = 1.4, colour = .tsr_color_win
        )
        if (sum(in_slice_win) < 4L) {
          p <- p + ggplot2::labs(
            caption = "Full winning line spans other slices."
          )
        }
      }
    }
  }
  p
}

#' Autoplot method for a 4D tic-tac-toe board
#'
#' Registers a `ggplot2::autoplot()` method on `ttt_board` that delegates to
#' `tsr_plot()`.
#'
#' @param object A `ttt_board`.
#' @param ... Passed to `tsr_plot()`.
#' @return A `ggplot` object.
#' @examples
#' ggplot2::autoplot(tsr_new_board())
#' @export
#' @importFrom ggplot2 autoplot
#' @method autoplot ttt_board
autoplot.ttt_board <- function(object, ...) {
  tsr_plot(object, ...)
}
