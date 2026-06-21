# Print methods for a 4D tic-tac-toe board

S3 `format`, `print`, and `summary` methods for `ttt_board`.
[`format()`](https://rdrr.io/r/base/format.html) returns a character
vector summary, [`print()`](https://rdrr.io/r/base/print.html) emits a
one-screen `cli` summary and returns its input invisibly, and
[`summary()`](https://rdrr.io/r/base/summary.html) returns the
[`tsr_status()`](https://r-heller.github.io/tesseractR/reference/tsr_status.md)
tibble.

## Usage

``` r
# S3 method for class 'ttt_board'
format(x, ...)

# S3 method for class 'ttt_board'
print(x, ...)

# S3 method for class 'ttt_board'
summary(object, ...)
```

## Arguments

- x, object:

  A `ttt_board`.

- ...:

  Reserved.

## Value

[`format()`](https://rdrr.io/r/base/format.html) returns a character
vector. [`print()`](https://rdrr.io/r/base/print.html) returns `x`
invisibly. [`summary()`](https://rdrr.io/r/base/summary.html) returns a
one-row tibble.

## Examples

``` r
format(tsr_new_board())
#> [1] "<ttt_board>"              "4x4x4x4 board, 256 cells"
#> [3] "moves played: 0"          "to move: X"              
#> [5] "legal moves: 256"        
summary(tsr_new_board())
#> # A tibble: 1 × 6
#>   winner is_full is_over n_moves to_move n_legal
#>    <int> <lgl>   <lgl>     <int>   <int>   <int>
#> 1      0 FALSE   FALSE         0       1     256
```
