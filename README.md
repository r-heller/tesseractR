
# tesseractR <img src="man/figures/logo.png" align="right" height="139" alt="tesseractR logo" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-heller/tesseractR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-heller/tesseractR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/r-heller/tesseractR/actions/workflows/pkgdown.yaml/badge.svg)](https://r-heller.github.io/tesseractR/)
[![CRAN
status](https://www.r-pkg.org/badges/version/tesseractR)](https://CRAN.R-project.org/package=tesseractR)
[![Codecov test
coverage](https://codecov.io/gh/r-heller/tesseractR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-heller/tesseractR?branch=main)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/tesseractR)](https://cran.r-project.org/package=tesseractR)
[![CRAN downloads
total](https://cranlogs.r-pkg.org/badges/grand-total/tesseractR)](https://cran.r-project.org/package=tesseractR)
[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

`tesseractR` plays four-dimensional tic-tac-toe on a `4×4×4×4` hypercube
(256 cells, 520 winning lines), with a depth-limited negamax AI, a
ggplot2 visualization of the hypercube as a 4×4 grid of 4×4 boards, and
an interactive Shiny app with live move evaluation and a game-analysis
panel.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("r-heller/tesseractR")
```

## Example

``` r
library(tesseractR)
b <- tsr_new_board()
b <- tsr_move(b, 0L, 0L, 0L, 0L)   # X at (0,0,0,0)
b <- tsr_move(b, cell = 17L)       # O
b <- tsr_move(b, 1L, 0L, 0L, 0L)   # X
print(b)
#> 
#> ── <ttt_board> ──
#> 
#> 4x4x4x4 board, 256 cells
#> moves played: 3
#> to move: O
#> legal moves: 253
```

``` r
tsr_plot(b)
```

<img src="man/figures/README-plot-1.png" alt="Mid-game tesseractR board" width="100%" />

Launch the interactive app with `tsr_run_app()` (requires `shiny`).
