# Structured one-row status for a board

Returns a tibble that summarizes the position: winner, whether it is
full, whether the game is over, move counts, and the number of legal
moves.

## Usage

``` r
tsr_status(board)
```

## Arguments

- board:

  A `ttt_board`.

## Value

A one-row tibble with columns: `winner` (integer, `0/1/2`), `is_full`
(logical), `is_over` (logical), `n_moves` (integer; total moves played),
`to_move` (integer, `1/2`), `n_legal` (integer; count of legal moves
remaining).

## Examples

``` r
tsr_status(tsr_new_board())
#> # A tibble: 1 × 6
#>   winner is_full is_over n_moves to_move n_legal
#>    <int> <lgl>   <lgl>     <int>   <int>   <int>
#> 1      0 FALSE   FALSE         0       1     256
```
