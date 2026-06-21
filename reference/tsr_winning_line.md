# Indices of the first winning line on the board

Returns the four linear cell indices that form the first detected
winning line, or `integer(0)` if no line is complete.

## Usage

``` r
tsr_winning_line(board)
```

## Arguments

- board:

  A `ttt_board`.

## Value

Integer vector of length 4 (the winning line) or length 0 (no winner).

## Examples

``` r
tsr_winning_line(tsr_new_board())
#> integer(0)
```
