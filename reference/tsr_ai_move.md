# AI move on a 4D tic-tac-toe board

Returns the linear cell index of the AI's chosen move using
depth-limited negamax with alpha-beta pruning. At difficulty `>= 1`, an
immediate winning move is always taken and an immediate opponent threat
is always blocked.

## Usage

``` r
tsr_ai_move(board, difficulty = 2L)
```

## Arguments

- board:

  A `ttt_board`.

- difficulty:

  Integer in `1:4` (default `2L`). Maps to search depth.

## Value

Integer scalar: the chosen cell's linear index in `1:256`.

## Details

Tie-breaking among moves with equal evaluation is deterministic (lowest
linear index wins).

Note: search is exponential in depth and runs in pure R; depth `4` may
take several seconds on a 256-cell board. Rcpp acceleration is a planned
future enhancement and is intentionally out of scope for this release.

## Examples

``` r
tsr_ai_move(tsr_new_board(), difficulty = 1L)
#> [1] 1
# \donttest{
tsr_ai_move(tsr_new_board(), difficulty = 3L)
#> [1] 1
# }
```
