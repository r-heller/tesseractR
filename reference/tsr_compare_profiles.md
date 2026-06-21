# Combine multiple behavioral profiles

Row-binds a sequence of
[`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md)
tibbles for side-by-side comparison. Errors on mismatched columns.

## Usage

``` r
tsr_compare_profiles(...)
```

## Arguments

- ...:

  Tibbles produced by
  [`tsr_behavior_profile()`](https://r-heller.github.io/tesseractR/reference/tsr_behavior_profile.md).

## Value

A tibble with one row per input.

## Examples

``` r
# \donttest{
g1 <- tsr_play_game("random", "random", seed = 1L)
p1 <- tsr_behavior_profile(list(g1), side = 1L, label = "random")
p2 <- tsr_behavior_profile(list(g1), side = 2L, label = "random")
tsr_compare_profiles(p1, p2)
#> # A tibble: 2 × 11
#>   label   side n_games n_moves_total accuracy mean_regret blunder_rate
#>   <chr>  <int>   <int>         <int>    <dbl>       <dbl>        <dbl>
#> 1 random     1       1            50        0       0.512         0.94
#> 2 random     2       1            50        0       0.147         0.6 
#> # ℹ 4 more variables: win_conversion <dbl>, defense_rate <dbl>,
#> #   aggression <dbl>, mean_decisiveness <dbl>
# }
```
