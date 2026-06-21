# Plot a 3D slice of a 4D tic-tac-toe board

Holds one of the four hypercube axes at a fixed value, dropping the
board to a 3D 4x4x4 cube, then renders that cube as a 1x4 strip of 4x4
mini-boards. Use this view to make through-all-four-dimensions diagonals
read as straight lines within a single plane. Returns a `ggplot` object.

## Usage

``` r
tsr_plot_slice(
  board,
  axis = c("i", "j", "k", "l"),
  at = 0L,
  highlight_win = TRUE,
  ...
)
```

## Arguments

- board:

  A `ttt_board`.

- axis:

  One of `"i"`, `"j"`, `"k"`, `"l"`. The axis to hold fixed.

- at:

  Integer `0:3`. The value at which to fix `axis`.

- highlight_win:

  Logical. Emphasise the winning line if it lies in (or intersects) the
  slice.

- ...:

  Reserved for future arguments.

## Value

A `ggplot` object.

## Details

Convention: of the three remaining axes, the **highest-numbered** is
used as the block axis (the strip dimension); the other two form each
mini-board.

## Examples

``` r
tsr_plot_slice(tsr_new_board(), axis = "l", at = 0L)
```
