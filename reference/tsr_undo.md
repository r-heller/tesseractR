# Undo the most recent moves on a board

Pops `n` moves from the end of the history, clearing those cells and
restoring the player-to-move. Returns a new board.

## Usage

``` r
tsr_undo(board, n = 1L)
```

## Arguments

- board:

  A `ttt_board`.

- n:

  Integer (default `1L`). Number of moves to undo. Must not exceed
  `length(board$history)`.

## Value

A new `ttt_board` with the moves removed.

## Examples

``` r
b <- tsr_new_board()
b2 <- tsr_move(b, cell = 1L)
identical(tsr_undo(b2), b)
#> [1] TRUE
```
