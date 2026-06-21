# Plot a 4D tic-tac-toe board as a 4x4 grid of 4x4 boards

Renders the 256-cell hypercube as a 4x4 outer grid (indexed by
`(k, l)`), where each outer cell contains a 4x4 inner board (indexed by
`(i, j)`). Returns a `ggplot` object; never renders in place.

## Usage

``` r
tsr_plot(board, highlight_win = TRUE, ...)
```

## Arguments

- board:

  A `ttt_board`.

- highlight_win:

  Logical. If `TRUE` (default) and the game is over, the four cells of
  the winning line are emphasised.

- ...:

  Reserved for future arguments.

## Value

A `ggplot` object.

## Examples

``` r
tsr_plot(tsr_new_board())
```
