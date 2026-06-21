# Legal moves on a board

Returns the integer linear indices of every empty cell, or an empty
integer vector if the game is over or the board is full. Always
type-stable (`integer`, never `NULL`).

## Usage

``` r
tsr_legal_moves(board)
```

## Arguments

- board:

  A `ttt_board`.

## Value

Integer vector of legal linear cell indices (possibly length zero).

## Examples

``` r
length(tsr_legal_moves(tsr_new_board()))
#> [1] 256
```
