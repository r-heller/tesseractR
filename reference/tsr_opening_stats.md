# Opening statistics from a simulation

Aggregates a
[`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md)
result into per-group win rates with Wilson confidence intervals.

## Usage

``` r
tsr_opening_stats(sim, by = c("first_move", "difficulty"))
```

## Arguments

- sim:

  A tibble produced by
  [`tsr_simulate()`](https://r-heller.github.io/tesseractR/reference/tsr_simulate.md).

- by:

  Character. Grouping column(s). Defaults to `"first_move"`.

## Value

A tibble with columns: the grouping column(s), `n_games`, `win_rate_x`,
`win_rate_o`, `draw_rate`, `ci_lo`, `ci_hi` (Wilson 95% CI for
`win_rate_x`).

## Examples

``` r
# \donttest{
sim <- tsr_simulate("random", "random", n_games = 5L, seed = 1L, verbose = FALSE)
tsr_opening_stats(sim)
#> # A tibble: 5 × 7
#>   first_move n_games win_rate_x win_rate_o draw_rate ci_lo ci_hi
#>        <int>   <int>      <dbl>      <dbl>     <dbl> <dbl> <dbl>
#> 1         31       1          1          0         0 0.207 1    
#> 2        103       1          1          0         0 0.207 1    
#> 3        107       1          1          0         0 0.207 1    
#> 4        174       1          0          1         0 0     0.793
#> 5        249       1          0          1         0 0     0.793
# }
```
