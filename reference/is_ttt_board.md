# Test whether an object is a `ttt_board`

Test whether an object is a `ttt_board`

## Usage

``` r
is_ttt_board(x)
```

## Arguments

- x:

  Object to test.

## Value

Logical scalar: `TRUE` if `x` inherits from `"ttt_board"`.

## Examples

``` r
is_ttt_board(tsr_new_board())
#> [1] TRUE
is_ttt_board(list())
#> [1] FALSE
```
