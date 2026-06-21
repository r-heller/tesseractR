# Autoplot method for a 4D tic-tac-toe board

Registers a
[`ggplot2::autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
method on `ttt_board` that delegates to
[`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md).

## Usage

``` r
# S3 method for class 'ttt_board'
autoplot(object, ...)
```

## Arguments

- object:

  A `ttt_board`.

- ...:

  Passed to
  [`tsr_plot()`](https://r-heller.github.io/tesseractR/reference/tsr_plot.md).

## Value

A `ggplot` object.

## Examples

``` r
ggplot2::autoplot(tsr_new_board())
```
