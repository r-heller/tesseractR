# Simulate many games between two policies

Runs `n_games` self-play games and returns a tibble summarising each
game.

## Usage

``` r
tsr_simulate(policy_x, policy_o, n_games = 100L, seed = NULL, verbose = TRUE)
```

## Arguments

- policy_x:

  Policy for player X. See
  [`tsr_play_game()`](https://r-heller.github.io/tesseractR/reference/tsr_play_game.md).

- policy_o:

  Policy for player O.

- n_games:

  Integer. Number of games to play (default `100L`).

- seed:

  Optional integer. Seeds the RNG via
  [`withr::local_seed()`](https://withr.r-lib.org/reference/with_seed.html);
  global `.Random.seed` is unchanged.

- verbose:

  Logical. Show a progress bar in interactive sessions.

## Value

A tibble, one row per game, with columns: `game_id` (integer),
`policy_x` (character), `policy_o` (character), `winner` (integer
`0/1/2`), `n_moves` (integer), `first_move` (integer cell),
`first_move_i`, `first_move_j`, `first_move_k`, `first_move_l`
(integer).

## Details

Performance: pure-R self-play over 256 cells is slow, and deep-AI
policies multiply the cost. Meaningful opening statistics may need
thousands of games; the hot-path functions are flagged for future Rcpp
replacement.

## Examples

``` r
# \donttest{
tsr_simulate("random", "random", n_games = 5L, seed = 1L, verbose = FALSE)
#> # A tibble: 5 × 10
#>   game_id policy_x policy_o winner n_moves first_move first_move_i first_move_j
#>     <int> <chr>    <chr>     <int>   <int>      <int>        <int>        <int>
#> 1       1 random   random        2     100        249            0            2
#> 2       2 random   random        1      81        107            2            2
#> 3       3 random   random        2      98        174            1            3
#> 4       4 random   random        1      55         31            2            3
#> 5       5 random   random        1     141        103            2            1
#> # ℹ 2 more variables: first_move_k <int>, first_move_l <int>
# }
```
