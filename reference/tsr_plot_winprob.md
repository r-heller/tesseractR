# Win-probability trajectory for a game

Plots `win_prob_after` (from
[`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md))
over plies, with a 0.5 reference and turning points marked. Returns a
`ggplot`.

## Usage

``` r
tsr_plot_winprob(analysis)
```

## Arguments

- analysis:

  A tibble from
  [`tsr_analyze_game()`](https://r-heller.github.io/tesseractR/reference/tsr_analyze_game.md).

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
g <- tsr_play_game("random", "random", seed = 1L)
tsr_plot_winprob(tsr_analyze_game(g))

# }
```
