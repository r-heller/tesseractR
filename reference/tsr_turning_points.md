# Turning points from a game analysis

Filters the analysis to plies where `is_turning_point` is `TRUE`, sorted
by `abs(delta)` descending.

## Usage

``` r
tsr_turning_points(analysis)
```

## Arguments

- analysis:

  A tibble produced by
  [`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md).

## Value

A tibble with the same schema as `analysis`, possibly zero rows.

## Examples

``` r
# \donttest{
g <- tsr_play_game("random", "random", seed = 1L)
tsr_turning_points(tsr_analyze_game(g))
#> # A tibble: 7 × 17
#>     ply player  cell     i     j     k     l win_prob_before win_prob_after
#>   <int>  <int> <int> <int> <int> <int> <int>           <dbl>          <dbl>
#> 1    40      2    49     0     0     3     0           0.420          0.674
#> 2    51      1    48     3     3     2     0           0.272          0.520
#> 3    63      1    16     3     3     0     0           0.152          0.373
#> 4    52      2   214     1     1     1     3           0.480          0.695
#> 5    62      2   209     0     0     1     3           0.657          0.848
#> 6    49      1    85     0     1     1     1           0.176          0.349
#> 7    44      2   185     0     2     3     2           0.676          0.828
#> # ℹ 8 more variables: delta <dbl>, best_cell <int>, best_delta <dbl>,
#> #   regret <dbl>, is_best <lgl>, missed_win <lgl>, missed_block <lgl>,
#> #   is_turning_point <lgl>
# }
```
