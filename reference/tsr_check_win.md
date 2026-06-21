# Detect a winner on the board

Scans the cached win-line table and returns the winning player's mark or
`0L` if no player has completed a line.

## Usage

``` r
tsr_check_win(board)
```

## Arguments

- board:

  A `ttt_board`.

## Value

Integer scalar: `0L` (no winner), `1L` (player X), or `2L` (player O).

## Examples

``` r
tsr_check_win(tsr_new_board())
#> [1] 0
```
