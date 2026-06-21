# Analyze a played game move by move

Walks a `tsr_game` (from
[`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md))
and computes per-ply evaluation context using the S3 evaluation core:
win probability before/after each move, the move's delta, the best
alternative move, regret, and flags for missed wins / missed blocks /
turning points.

## Usage

``` r
tsr_analyze_game(game, method = c("heuristic", "rollout"), n = 200L)
```

## Arguments

- game:

  A `tsr_game` object.

- method:

  One of `"heuristic"` (default) or `"rollout"`. Passed to the
  underlying
  [`tsr_win_prob()`](https://r-heller.github.io/tesseractR/reference/tsr_win_prob.md)
  /
  [`tsr_rate_moves()`](https://r-heller.github.io/tesseractR/reference/tsr_rate_moves.md).

- n:

  Integer. Rollouts when `method = "rollout"`.

## Value

A tibble, one row per ply, with columns: `ply`, `player`, `cell`, `i`,
`j`, `k`, `l`, `win_prob_before`, `win_prob_after`, `delta`,
`best_cell`, `best_delta`, `regret`, `is_best`, `missed_win`,
`missed_block`, `is_turning_point`.

## Details

A turning point is a ply with `abs(delta) >= 0.15`.

## Examples

``` r
# \donttest{
g <- tsr_play_game("random", "random", seed = 1L)
tsr_analyze_game(g)
#> # A tibble: 100 × 17
#>      ply player  cell     i     j     k     l win_prob_before win_prob_after
#>    <int>  <int> <int> <int> <int> <int> <int>           <dbl>          <dbl>
#>  1     1      1   249     0     2     3     3           0.5            0.518
#>  2     2      2    68     3     0     0     1           0.482          0.5  
#>  3     3      1   168     3     1     2     2           0.5            0.518
#>  4     4      2   130     1     0     0     2           0.482          0.496
#>  5     5      1   164     3     0     2     2           0.504          0.535
#>  6     6      2   219     2     2     1     3           0.465          0.482
#>  7     7      1    43     2     2     2     0           0.518          0.535
#>  8     8      2    14     1     3     0     0           0.465          0.482
#>  9     9      1   216     3     1     1     3           0.518          0.531
#> 10    10      2   193     0     0     0     3           0.469          0.520
#> # ℹ 90 more rows
#> # ℹ 8 more variables: delta <dbl>, best_cell <int>, best_delta <dbl>,
#> #   regret <dbl>, is_best <lgl>, missed_win <lgl>, missed_block <lgl>,
#> #   is_turning_point <lgl>
# }
```
