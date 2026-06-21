# Calibrated win probability for a position

Returns the estimated probability in `[0, 1]` that `player` wins from
the given position. Two methods are supported:

## Usage

``` r
tsr_win_prob(
  board,
  player = NULL,
  method = c("heuristic", "rollout"),
  n = 200L
)
```

## Arguments

- board:

  A `ttt_board`.

- player:

  Integer `1L` or `2L`, or `NULL` (default, uses `board$to_move`).

- method:

  One of `"heuristic"` (default) or `"rollout"`.

- n:

  Integer. Number of rollouts when `method = "rollout"`.

## Value

Numeric scalar in `[0, 1]`.

## Details

- `"heuristic"` (default, real-time): maps
  [`tsr_evaluate()`](https://r-heller.github.io/tesseractR/reference/tsr_evaluate.md)
  through a logistic calibration `p = plogis((score - a) / b)`. The
  coefficients `a`, `b` are fit by a `data-raw/` script (S6) and stored
  as internal package data; provisional defaults are used until
  calibration is run.

- `"rollout"` (offline accuracy): runs `n` policy-guided Monte-Carlo
  playouts using a light heuristic policy and returns the empirical win
  share. Slower in pure R; intended for offline analysis, not the live
  UI.

Terminal positions short-circuit: a win returns `1`, a loss `0`, a draw
`0.5`.

## Examples

``` r
tsr_win_prob(tsr_new_board())
#> [1] 0.5
# \donttest{
tsr_win_prob(tsr_new_board(), method = "rollout", n = 20L)
#> [1] 0.5
# }
```
