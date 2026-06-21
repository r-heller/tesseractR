# Rate every legal move from a position

For each legal move, applies it and scores the resulting position from
the moving side's perspective. Returns a tibble sorted best-first with
type- stable columns; on a finished board returns a zero-row tibble with
the same schema.

## Usage

``` r
tsr_rate_moves(board, method = c("heuristic", "rollout"), n = 200L)
```

## Arguments

- board:

  A `ttt_board`.

- method:

  One of `"heuristic"` (default) or `"rollout"`.

- n:

  Integer. Number of rollouts when `method = "rollout"`.

## Value

A tibble with columns: `cell` (integer linear index), `i`, `j`, `k`, `l`
(integer coordinates in `0:3`), `score` (numeric raw evaluation after
the move), `win_prob` (numeric in `[0, 1]`), `rank` (integer; `1` =
best), `is_best` (logical), `is_winning` (logical; the move completes a
line), `is_blocking` (logical; the move denies an opponent's immediate
win). Sorted by `rank`.

## Examples

``` r
tsr_rate_moves(tsr_new_board())
#> # A tibble: 256 × 11
#>     cell     i     j     k     l score win_prob  rank is_best is_winning
#>    <int> <int> <int> <int> <int> <dbl>    <dbl> <int> <lgl>   <lgl>     
#>  1     1     0     0     0     0    15    0.533     1 TRUE    FALSE     
#>  2     4     3     0     0     0    15    0.533     2 FALSE   FALSE     
#>  3    13     0     3     0     0    15    0.533     3 FALSE   FALSE     
#>  4    16     3     3     0     0    15    0.533     4 FALSE   FALSE     
#>  5    49     0     0     3     0    15    0.533     5 FALSE   FALSE     
#>  6    52     3     0     3     0    15    0.533     6 FALSE   FALSE     
#>  7    61     0     3     3     0    15    0.533     7 FALSE   FALSE     
#>  8    64     3     3     3     0    15    0.533     8 FALSE   FALSE     
#>  9    86     1     1     1     1    15    0.533     9 FALSE   FALSE     
#> 10    87     2     1     1     1    15    0.533    10 FALSE   FALSE     
#> # ℹ 246 more rows
#> # ℹ 1 more variable: is_blocking <lgl>
```
