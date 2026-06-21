# Print method for a played game

One-screen `cli` summary of a `tsr_game`. Returns its input invisibly.

## Usage

``` r
# S3 method for class 'tsr_game'
print(x, ...)
```

## Arguments

- x:

  A `tsr_game`.

- ...:

  Reserved.

## Value

`x`, invisibly.

## Examples

``` r
print(tsr_play_game("random", "random", seed = 1L))
#> 
#> ── <tsr_game> ──
#> 
#> X policy: random
#> O policy: random
#> Result: O wins after 100 moves
```
