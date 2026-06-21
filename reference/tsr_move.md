# Make a move on a 4D tic-tac-toe board

Place the current player's mark at the given cell and return a **new**
`ttt_board` with the move applied. The input board is never mutated.

## Usage

``` r
tsr_move(board, i = NULL, j = NULL, k = NULL, l = NULL, cell = NULL)
```

## Arguments

- board:

  A `ttt_board`.

- i, j, k, l:

  Integer coordinates in `0:3`. Either all four or none.

- cell:

  Optional linear cell index (`1:256`). Mutually exclusive with the
  coordinate form.

## Value

A new `ttt_board` with the mark placed, `to_move` flipped, and `history`
extended by the move.

## Details

Provide either the four hypercube coordinates `(i, j, k, l)` (each in
`0:3`), or the linear cell index via `cell` (an integer in `1:256`).
Exactly one form must be supplied.

## Examples

``` r
b <- tsr_new_board()
b <- tsr_move(b, 0L, 0L, 0L, 0L)
b <- tsr_move(b, cell = 5L)
tsr_status(b)
#> # A tibble: 1 × 6
#>   winner is_full is_over n_moves to_move n_legal
#>    <int> <lgl>   <lgl>     <int>   <int>   <int>
#> 1      0 FALSE   FALSE         2       1     254
```
