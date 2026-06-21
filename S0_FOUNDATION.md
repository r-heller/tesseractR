# S0 — Foundation

**Depends on:** nothing · **Unlocks:** S1_GEOMETRY

Lay down the package skeleton so every later stack has a place to write
code. No game logic yet — just the scaffold, metadata, the internal
cache environment, and package-level documentation.

------------------------------------------------------------------------

## Tasks

### 0.1 — Create the package skeleton

Initialize the package in the current working directory with this
structure (create empty files where a later stack fills them):

    tesseractR/
      DESCRIPTION
      NAMESPACE              # generated — leave roxygen to create it
      LICENSE
      LICENSE.md
      R/
        tesseractR-package.R
        zzz.R
      tests/
        testthat.R
        testthat/
          helper.R
      .Rbuildignore
      .gitignore

Use
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
if convenient, but the DESCRIPTION below overrides any generated one.

### 0.1b — Git identity & build branch

Set authorship and create the working branch **before the first commit**
(full policy in the orchestrator’s Git Workflow section):

``` bash
git config user.name  "Raban Heller"
git config user.email "raban.heller@charite.de"
git checkout -b build/tesseractR    # branch off main; never commit to main directly
```

All stack commits land on `build/tesseractR`. No AI co-author trailers,
ever. `main` is touched only at the end via an approved PR after the
audit loop is clean.

### 0.2 — DESCRIPTION

Write exactly:

    Package: tesseractR
    Title: Four-Dimensional Tic-Tac-Toe with a Heuristic AI Opponent
    Version: 0.1.0
    Authors@R:
        person("Raban", "Heller", email = "raban.heller@charite.de",
               role = c("aut", "cre"), comment = c(ORCID = "0000-0001-8006-9742"))
    Description: Play four-dimensional tic-tac-toe on a four-by-four-by-four-by-four
        hypercube, where the first player to align four marks along any straight line
        in four-dimensional space wins. Provides a game engine with legal-move
        generation and win detection across all 272 winning lines, a depth-limited
        negamax artificial-intelligence opponent with adjustable difficulty, 'ggplot2'
        visualization of the hypercube as a grid of boards, and an interactive 'shiny'
        application for play.
    License: MIT + file LICENSE
    URL: https://github.com/r-heller/tesseractR, https://r-heller.github.io/tesseractR/
    BugReports: https://github.com/r-heller/tesseractR/issues
    Encoding: UTF-8
    Roxygen: list(markdown = TRUE)
    RoxygenNote: 7.3.2
    Depends: R (>= 4.1.0)
    Imports:
        cli,
        ggplot2,
        rlang,
        tibble
    Suggests:
        shiny,
        bslib,
        plotly,
        knitr,
        rmarkdown,
        testthat (>= 3.0.0),
        withr,
        covr,
        pkgdown
    Config/testthat/edition: 3
    VignetteBuilder: knitr

`shiny`/`bslib`/`plotly` stay in **Suggests** — the engine must load and
run with none of them installed.

### 0.3 — License files

- `LICENSE` (the two-line MIT CRAN form):

      YEAR: 2026
      COPYRIGHT HOLDER: Raban Heller

- `LICENSE.md` — full MIT text.

### 0.4 — Package-level docs (`R/tesseractR-package.R`)

``` r

#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data %||%
NULL
```

### 0.5 — Internal cache environment (`R/zzz.R`)

Create a package-level internal environment for caching the win-line
table (filled lazily in S1). Do **not** populate it on load.

``` r

# Internal cache for computed win lines. Populated lazily by .tsr_win_lines().
.tsr_cache <- new.env(parent = emptyenv())
```

No `.onLoad`/`.onAttach` message — keep startup silent. (An empty
`.onLoad` is fine if a later stack needs it, but add nothing
user-facing.)

### 0.6 — testthat plumbing

- `tests/testthat.R`:

  ``` r

  library(testthat)
  library(tesseractR)
  test_check("tesseractR")
  ```

- `tests/testthat/helper.R` — leave a header comment; S2 fills in
  `example_board()`.

### 0.7 — Ignore files

- `.Rbuildignore` (escaped regex, one per line):

      ^tesseractR\.Rproj$
      ^\.Rproj\.user$
      ^_pkgdown\.ya?ml$
      ^docs$
      ^pkgdown$
      ^README\.Rmd$
      ^\.github$
      ^LICENSE\.md$
      ^.*\.svg$
      ^_build\.R$
      ^cran-comments\.md$
      ^\.claude$
      ^codecov\.yml$

- `.gitignore`:

      .Rproj.user
      .Rhistory
      .RData
      .Ruserdata
      .DS_Store
      docs/
      inst/doc/
      _build.R
      .claude/

### 0.8 — Verify

Run
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
then
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html).
The package must load with no errors and no exported functions yet
(NAMESPACE will be near-empty — fine).

------------------------------------------------------------------------

## Done when

Package loads via
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html)
with zero errors.

`DESCRIPTION` matches the spec exactly; `Imports` = cli, ggplot2, rlang,
tibble.

`LICENSE` + `LICENSE.md` both present.

`.tsr_cache` environment exists and is empty.

`R/tesseractR-package.R` has the `_PACKAGE` sentinel and rlang imports.

testthat scaffolding in place.

## On completion

Update `STATE.md`: S0 → `DONE`, S1 → `TODO`. Report that S1_GEOMETRY is
now runnable.
