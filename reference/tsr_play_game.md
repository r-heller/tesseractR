# Play a single game between two policies

Simulates one complete 4D tic-tac-toe game with the given policies for
player X and player O. Returns a `tsr_game` object recording the move
sequence and outcome.

## Usage

``` r
tsr_play_game(policy_x, policy_o, seed = NULL)
```

## Arguments

- policy_x:

  Policy for player X. Either a built-in string or a function
  `(board) -> integer cell index`.

- policy_o:

  Policy for player O. Same forms as `policy_x`.

- seed:

  Optional integer. If supplied, RNG is seeded via
  [`withr::local_seed()`](https://withr.r-lib.org/reference/with_seed.html);
  global `.Random.seed` is unchanged.

## Value

A `tsr_game` object: list with `moves` (integer vector of cell indices,
in order), `winner` (`0/1/2`), `n_moves` (integer), `policies` (named
character `c(x, o)`), `final_board` (a `ttt_board`), `to_move` (integer
vector — moving player at each ply).

## Details

Built-in policy strings: `"random"`, `"greedy"`, `"ai"` (depth 2), or
`"aiN"` for `N` in `1:4` (e.g. `"ai3"`).

## Examples

``` r
g <- tsr_play_game("random", "random", seed = 1L)
g$winner
#> [1] 2
```
