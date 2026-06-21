# One-row summary for a played game

Compact scorecard with missed-win / missed-block counts, mean regret per
player, turning-point count, and final decisiveness.

## Usage

``` r
tsr_game_summary(game)
```

## Arguments

- game:

  A `tsr_game`.

## Value

A one-row tibble with columns: `winner`, `n_moves`, `n_missed_wins_x`,
`n_missed_wins_o`, `n_missed_blocks_x`, `n_missed_blocks_o`,
`mean_regret_x`, `mean_regret_o`, `n_turning_points`, `decisiveness`.

## Examples

``` r
# \donttest{
g <- tsr_play_game("random", "random", seed = 1L)
tsr_game_summary(g)
#> # A tibble: 1 × 10
#>   winner n_moves n_missed_wins_x n_missed_wins_o n_missed_blocks_x
#>    <int>   <int>           <int>           <int>             <int>
#> 1      2     100              25              29                 5
#> # ℹ 5 more variables: n_missed_blocks_o <int>, mean_regret_x <dbl>,
#> #   mean_regret_o <dbl>, n_turning_points <int>, decisiveness <dbl>
# }
```
