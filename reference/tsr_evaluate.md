# Evaluate a position

Heuristic positional score from the perspective of `player`. Positive
favors `player`. The scale is unitless and only comparable within the
same board size; it is the raw input fed to the calibrated
win-probability mapping.

## Usage

``` r
tsr_evaluate(board, player = NULL)
```

## Arguments

- board:

  A `ttt_board`.

- player:

  Integer `1L` or `2L`. If `NULL` (default), the position is evaluated
  from `board$to_move`'s perspective.

## Value

Numeric scalar.

## Details

Terminal positions short-circuit: a win returns a large positive
sentinel (approximately `1e6`), a loss the negation, and a draw `0`.

## Examples

``` r
tsr_evaluate(tsr_new_board())
#> [1] 0
```
