# Launch the tesseractR Shiny app

Opens the interactive 4D tic-tac-toe app shipped in
`inst/shiny/tesseractR`. Requires the `shiny` package (declared in
`Suggests`).

## Usage

``` r
tsr_run_app(difficulty = 2L)
```

## Arguments

- difficulty:

  Integer in `1:4`. Initial AI difficulty for vs-AI mode.

## Value

Invisible `NULL`. Called for its side effect of launching the app.

## Examples

``` r
# \donttest{
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  tsr_run_app()
}
# }
```
