# Test helpers. example_board() and winning_board() are populated in S2.

example_board <- function() {
  b <- tsr_new_board()
  cells <- c(1L, 256L, 86L, 171L, 22L, 35L, 100L, 200L)
  for (c in cells) b <- tsr_move(b, cell = c)
  b
}

winning_board <- function(player = 1L) {
  # Plays an axis-aligned line for `player` while the other player plays
  # an alternating losing sequence on cells that do not block.
  stopifnot(player %in% c(1L, 2L))
  b <- tsr_new_board()
  win_cells <- c(1L, 2L, 3L, 4L)
  other_cells <- c(17L, 18L, 19L, 20L)
  for (k in seq_len(4L)) {
    if (player == 1L) {
      b <- tsr_move(b, cell = win_cells[k])
      if (k < 4L) b <- tsr_move(b, cell = other_cells[k])
    } else {
      b <- tsr_move(b, cell = other_cells[k])
      b <- tsr_move(b, cell = win_cells[k])
    }
  }
  b
}
