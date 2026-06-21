# Create a new, empty 4D tic-tac-toe board

Constructs a fresh `ttt_board` representing an empty 4x4x4x4 hypercube
with player X (mark `1`) to move.

## Usage

``` r
tsr_new_board()
```

## Value

An object of class `ttt_board`: a list with components `state` (integer
vector of length 256, values in `0:2`), `to_move` (`1L` for X, `2L` for
O), and `history` (integer vector of linear cell indices played, in
order).

## Examples

``` r
b <- tsr_new_board()
is_ttt_board(b)
#> [1] TRUE
tsr_status(b)
#> # A tibble: 1 × 6
#>   winner is_full is_over n_moves to_move n_legal
#>    <int> <lgl>   <lgl>     <int>   <int>   <int>
#> 1      0 FALSE   FALSE         0       1     256
```
