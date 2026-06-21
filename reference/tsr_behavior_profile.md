# Aggregate behavioral profile for a side across many games

Walks a list of `tsr_game` objects, analyses each, and computes the
aggregate profile for the chosen side (player X by default).

## Usage

``` r
tsr_behavior_profile(games, side = 1L, label = NULL)
```

## Arguments

- games:

  A list of `tsr_game` objects.

- side:

  Integer `1L` (X) or `2L` (O). The side to profile.

- label:

  Optional character. Label for the profile (e.g. a policy name).

## Value

A one-row tibble with `label`, `side`, `n_games`, `n_moves_total`,
`accuracy`, `mean_regret`, `blunder_rate`, `win_conversion`,
`defense_rate`, `aggression`, `mean_decisiveness`.

## Examples

``` r
# \donttest{
g1 <- tsr_play_game("random", "random", seed = 1L)
g2 <- tsr_play_game("random", "random", seed = 2L)
tsr_behavior_profile(list(g1, g2), side = 1L, label = "random")
#> # A tibble: 1 × 11
#>   label   side n_games n_moves_total accuracy mean_regret blunder_rate
#>   <chr>  <int>   <int>         <int>    <dbl>       <dbl>        <dbl>
#> 1 random     1       2            95        0       0.410        0.842
#> # ℹ 4 more variables: win_conversion <dbl>, defense_rate <dbl>,
#> #   aggression <dbl>, mean_decisiveness <dbl>
# }
```
