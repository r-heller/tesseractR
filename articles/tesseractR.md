# Getting Started with tesseractR

``` r

library(tesseractR)
```

## What is 4D tic-tac-toe?

`tesseractR` plays tic-tac-toe on a four-dimensional 4×4×4×4 hypercube —
256 cells indexed by `(i, j, k, l)` with each coordinate in `0:3`. A
line is any four cells whose successive differences equal a constant
non-zero direction vector in `{−1, 0, 1}^4`. After deduplicating
reversed directions there are **520 winning lines** by the standard
`((n+2)^d − n^d) / 2` formula for `d = n = 4`.

## A first game

``` r

b <- tsr_new_board()
b <- tsr_move(b, 0L, 0L, 0L, 0L)   # X at (0,0,0,0) = cell 1
b <- tsr_move(b, cell = 17L)       # O
b <- tsr_move(b, 1L, 0L, 0L, 0L)   # X at (1,0,0,0) = cell 2
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

![Mid-game tesseractR
board](tesseractR_files/figure-html/unnamed-chunk-3-1.png)

## Detecting a win

We continue the game until X completes an axis-aligned line:

``` r

b <- tsr_move(b, cell = 18L)       # O
b <- tsr_move(b, 2L, 0L, 0L, 0L)   # X
b <- tsr_move(b, cell = 19L)       # O
b <- tsr_move(b, 3L, 0L, 0L, 0L)   # X completes 1-2-3-4
tsr_check_win(b)
#> [1] 1
tsr_winning_line(b)
#> [1] 1 2 3 4
```

``` r

tsr_plot_slice(b, axis = "l", at = 0L)
```

![Slice view highlighting the in-plane winning
line](tesseractR_files/figure-html/unnamed-chunk-5-1.png)

## Playing the AI

[`tsr_ai_move()`](https://r-heller.github.io/tesseractR/reference/tsr_ai_move.md)
returns the chosen linear cell index. Difficulty `1` always takes an
immediate win and blocks an immediate threat. Higher difficulties look
further ahead (search is exponential in pure R — depth 4 may take
several seconds).

``` r

b <- tsr_new_board()
b <- tsr_move(b, cell = 1L)        # human X
ai_cell <- tsr_ai_move(b, difficulty = 1L)
b <- tsr_move(b, cell = ai_cell)   # AI O
ai_cell
#> [1] 4
```

## Evaluating positions

``` r

b <- tsr_new_board()
b <- tsr_move(b, cell = 1L); b <- tsr_move(b, cell = 17L)
b <- tsr_move(b, cell = 2L)
tsr_win_prob(b, player = 1L)
#> [1] 0.5502794
head(tsr_rate_moves(b))
#> # A tibble: 6 × 11
#>    cell     i     j     k     l score win_prob  rank is_best is_winning
#>   <int> <int> <int> <int> <int> <dbl>    <dbl> <int> <lgl>   <lgl>     
#> 1     4     3     0     0     0     1    0.502     1 TRUE    FALSE     
#> 2    86     1     1     1     1     0    0.5       2 FALSE   FALSE     
#> 3   155     2     2     1     2     0    0.5       3 FALSE   FALSE     
#> 4     3     2     0     0     0    -6    0.487     4 FALSE   FALSE     
#> 5    20     3     0     1     0    -7    0.485     5 FALSE   FALSE     
#> 6    22     1     1     1     0    -7    0.485     6 FALSE   FALSE     
#> # ℹ 1 more variable: is_blocking <lgl>
```

## The app

[`tsr_run_app()`](https://r-heller.github.io/tesseractR/reference/tsr_run_app.md)
launches the interactive Shiny version with a live move-rating overlay
and a game-analysis panel. See the “Simulation and Game Analysis”
vignette for self-play and analytics.
