init_diff_env <- Sys.getenv("TESSERACTR_INIT_DIFFICULTY", unset = "2")
init_difficulty <- suppressWarnings(as.integer(init_diff_env))
if (is.na(init_difficulty) || !(init_difficulty %in% 1:4)) init_difficulty <- 2L

has_bslib  <- requireNamespace("bslib", quietly = TRUE)
has_plotly <- requireNamespace("plotly", quietly = TRUE)

theme_obj <- if (has_bslib) {
  bslib::bs_theme(
    bootswatch = "flatly", primary = "#5E2C8E",
    "navbar-bg" = "#5E2C8E"
  )
} else {
  NULL
}

tagged <- function(label, icon_name) {
  shiny::tagList(shiny::icon(icon_name), " ", label)
}

ui_view_choices <- c(
  "Full" = "full",
  "Slice (2D)" = "slice"
)
if (has_plotly) ui_view_choices <- c(ui_view_choices, "Cube (3D)" = "cube")

ui <- shiny::fluidPage(
  theme = theme_obj,
  shiny::tags$head(shiny::tags$link(rel = "stylesheet", href = "custom.css")),
  shiny::titlePanel(shiny::tagList(
    shiny::tags$img(src = "logo.png", height = "48px",
                    style = "margin-right: 12px; vertical-align: middle;"),
    "tesseractR — 4D tic-tac-toe"
  )),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::actionButton("new_game",
                          shiny::tagList(shiny::icon("rotate-right"), " New game"),
                          class = "btn-primary"),
      shiny::hr(),
      shiny::radioButtons(
        "mode", tagged("Mode", "gamepad"),
        choices = c("Hotseat" = "hotseat", "vs AI" = "ai"),
        selected = "ai"
      ),
      shiny::conditionalPanel(
        condition = "input.mode == 'ai'",
        shiny::sliderInput("difficulty",
                           tagged("AI difficulty", "robot"),
                           min = 1L, max = 4L,
                           value = init_difficulty, step = 1L)
      ),
      shiny::hr(),
      shiny::radioButtons(
        "view", tagged("View", "eye"),
        choices = ui_view_choices, selected = "full"
      ),
      shiny::conditionalPanel(
        condition = "input.view == 'slice' || input.view == 'cube'",
        shiny::selectInput("fix_axis",
                           tagged("Fixed axis", "compass"),
                           choices = c("i", "j", "k", "l"), selected = "l"),
        shiny::sliderInput("fix_at",
                           tagged("At value", "ruler"),
                           min = 0L, max = 3L, value = 0L, step = 1L)
      ),
      shiny::checkboxInput("show_overlay",
                           tagged("Show move-rating overlay", "wand-magic-sparkles"),
                           value = TRUE),
      shiny::hr(),
      shiny::h4(tagged("Status", "circle-info")),
      shiny::uiOutput("status"),
      shiny::h4(tagged("Win probability", "chart-line")),
      shiny::uiOutput("win_prob")
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        id = "tabs",
        shiny::tabPanel(
          tagged("Board", "table-cells"),
          shiny::conditionalPanel(
            condition = "input.view != 'cube'",
            shiny::plotOutput("board", click = "board_click", height = "600px")
          ),
          shiny::conditionalPanel(
            condition = "input.view == 'cube'",
            if (has_plotly) plotly::plotlyOutput("board_cube", height = "600px")
            else shiny::p(shiny::icon("triangle-exclamation"),
                          " plotly is required for the 3D cube view; using slice instead.")
          )
        ),
        shiny::tabPanel(
          tagged("Analysis", "magnifying-glass-chart"),
          shiny::plotOutput("trajectory", height = "300px"),
          shiny::h4(tagged("Turning points", "bullseye")),
          shiny::tableOutput("turning"),
          shiny::h4(tagged("Game summary", "clipboard-list")),
          shiny::tableOutput("summary")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  rv <- shiny::reactiveValues(
    board = tesseractR::tsr_new_board(),
    history = integer(0)
  )

  shiny::observeEvent(input$new_game, {
    rv$board <- tesseractR::tsr_new_board()
    rv$history <- integer(0)
  })

  current_rating <- shiny::reactive({
    b <- rv$board
    if (tesseractR::tsr_check_win(b) != 0L || tesseractR::tsr_is_full(b)) {
      return(NULL)
    }
    tesseractR::tsr_rate_moves(b, method = "heuristic")
  })

  player_glyph <- function(side) {
    icon_name <- if (side == 1L) "xmark" else "circle"
    colour    <- if (side == 1L) "#0072B2" else "#E69F00"
    shiny::span(shiny::icon(icon_name),
                style = sprintf("color: %s; font-weight: 600;", colour))
  }

  output$status <- shiny::renderUI({
    b <- rv$board
    s <- tesseractR::tsr_status(b)
    if (s$winner != 0L) {
      shiny::tagList(
        shiny::span(shiny::icon("trophy"), " winner: "),
        player_glyph(s$winner)
      )
    } else if (s$is_full) {
      shiny::tagList(shiny::icon("handshake"), " draw")
    } else {
      shiny::tagList(
        shiny::span(shiny::icon("hourglass-half"),
                    sprintf(" %d move(s), to move: ", s$n_moves)),
        player_glyph(s$to_move)
      )
    }
  })

  output$win_prob <- shiny::renderUI({
    b <- rv$board
    if (tesseractR::tsr_check_win(b) != 0L || tesseractR::tsr_is_full(b)) {
      return(shiny::tagList(shiny::icon("flag-checkered"), " game over"))
    }
    p <- tesseractR::tsr_win_prob(b, method = "heuristic")
    shiny::tagList(
      shiny::span(sprintf("%.2f ", p)),
      shiny::icon("arrow-right"), " ",
      player_glyph(b$to_move)
    )
  })

  build_full_plot <- function(b, overlay) {
    p <- tesseractR::tsr_plot(b, highlight_win = TRUE)
    if (overlay) {
      r <- current_rating()
      if (!is.null(r) && nrow(r) > 0L) {
        full_xy <- tesseractR:::.tsr_layout(tesseractR:::.tsr_idx_to_coord(1:256))
        xy <- full_xy[r$cell, , drop = FALSE]
        df <- tibble::tibble(
          x = xy[, "x"], y = xy[, "y"],
          win_prob = r$win_prob,
          is_best = r$is_best,
          is_winning = r$is_winning,
          is_blocking = r$is_blocking
        )
        p <- p +
          ggplot2::geom_tile(
            data = df,
            mapping = ggplot2::aes(x = .data$x, y = .data$y,
                                   alpha = .data$win_prob),
            fill = "#5E2C8E",
            inherit.aes = FALSE,
            width = 0.9, height = 0.9
          ) +
          ggplot2::scale_alpha_continuous(range = c(0, 0.4)) +
          ggplot2::guides(alpha = "none")
      }
    }
    p
  }

  output$board <- shiny::renderPlot({
    b <- rv$board
    if (input$view == "full") {
      build_full_plot(b, isTRUE(input$show_overlay))
    } else {
      tesseractR::tsr_plot_slice(b, axis = input$fix_axis, at = input$fix_at)
    }
  })

  if (has_plotly) {
    output$board_cube <- plotly::renderPlotly({
      b <- rv$board
      ax <- input$fix_axis
      at <- as.integer(input$fix_at)
      coord <- tesseractR:::.tsr_idx_to_coord(1:256)
      in_slice <- coord[, ax] == at
      free_axes <- setdiff(c("i", "j", "k", "l"), ax)
      cube_coord <- coord[in_slice, , drop = FALSE]
      st <- b$state[in_slice]
      df <- data.frame(
        x = cube_coord[, free_axes[1L]],
        y = cube_coord[, free_axes[2L]],
        z = cube_coord[, free_axes[3L]],
        mark = ifelse(st == 1L, "X", ifelse(st == 2L, "O", "")),
        col = ifelse(st == 1L, "#0072B2",
                ifelse(st == 2L, "#E69F00", "grey80"))
      )
      fig <- plotly::plot_ly(
        df[df$mark != "", , drop = FALSE],
        x = ~x, y = ~y, z = ~z, text = ~mark,
        type = "scatter3d", mode = "markers+text",
        marker = list(size = 8, color = ~col),
        textfont = list(size = 14, color = ~col)
      )
      empties <- df[df$mark == "", , drop = FALSE]
      fig <- plotly::add_trace(
        fig, data = empties,
        x = ~x, y = ~y, z = ~z, mode = "markers",
        marker = list(size = 3, color = "grey80")
      )
      wl <- tesseractR::tsr_winning_line(b)
      if (length(wl) == 4L) {
        wcoord <- tesseractR:::.tsr_idx_to_coord(wl)
        in_cube <- wcoord[, ax] == at
        if (all(in_cube)) {
          wdf <- data.frame(
            x = wcoord[, free_axes[1L]],
            y = wcoord[, free_axes[2L]],
            z = wcoord[, free_axes[3L]]
          )
          fig <- plotly::add_trace(
            fig, data = wdf, x = ~x, y = ~y, z = ~z,
            mode = "lines",
            line = list(color = "#CC79A7", width = 6)
          )
        }
      }
      plotly::layout(
        fig,
        scene = list(aspectmode = "cube"),
        showlegend = FALSE
      )
    })
  }

  output$trajectory <- shiny::renderPlot({
    if (length(rv$history) < 2L) return(NULL)
    g <- structure(list(
      moves = rv$history, winner = tesseractR::tsr_check_win(rv$board),
      n_moves = length(rv$history),
      policies = c(x = "human", o = if (input$mode == "ai") "ai" else "human"),
      final_board = rv$board,
      to_move = integer(0)
    ), class = "tsr_game")
    a <- tesseractR::tsr_analyze_game(g)
    tesseractR::tsr_plot_winprob(a)
  })

  output$turning <- shiny::renderTable({
    if (length(rv$history) < 2L) return(NULL)
    g <- structure(list(
      moves = rv$history, winner = tesseractR::tsr_check_win(rv$board),
      n_moves = length(rv$history),
      policies = c(x = "human", o = if (input$mode == "ai") "ai" else "human"),
      final_board = rv$board,
      to_move = integer(0)
    ), class = "tsr_game")
    tp <- tesseractR::tsr_turning_points(tesseractR::tsr_analyze_game(g))
    tp[, c("ply", "player", "cell", "win_prob_before", "win_prob_after",
           "delta", "is_best")]
  })

  output$summary <- shiny::renderTable({
    if (length(rv$history) < 2L) return(NULL)
    g <- structure(list(
      moves = rv$history, winner = tesseractR::tsr_check_win(rv$board),
      n_moves = length(rv$history),
      policies = c(x = "human", o = if (input$mode == "ai") "ai" else "human"),
      final_board = rv$board,
      to_move = integer(0)
    ), class = "tsr_game")
    tesseractR::tsr_game_summary(g)
  })

  click_to_cell <- function(click) {
    if (is.null(click)) return(NULL)
    coord <- tesseractR:::.tsr_idx_to_coord(1:256)
    xy <- tesseractR:::.tsr_layout(coord)
    d2 <- (xy[, "x"] - click$x)^2 + (xy[, "y"] - click$y)^2
    idx <- which.min(d2)
    if (d2[idx] > 1) return(NULL)
    as.integer(idx)
  }

  shiny::observeEvent(input$board_click, {
    if (input$view != "full") return()
    b <- rv$board
    if (tesseractR::tsr_check_win(b) != 0L || tesseractR::tsr_is_full(b)) return()
    cell <- click_to_cell(input$board_click)
    if (is.null(cell)) return()
    if (b$state[cell] != 0L) return()
    nb <- tesseractR::tsr_move(b, cell = cell)
    rv$board <- nb
    rv$history <- c(rv$history, cell)
    if (input$mode == "ai" &&
        tesseractR::tsr_check_win(nb) == 0L && !tesseractR::tsr_is_full(nb)) {
      ai_cell <- tesseractR::tsr_ai_move(nb, difficulty = input$difficulty)
      rv$board <- tesseractR::tsr_move(nb, cell = ai_cell)
      rv$history <- c(rv$history, ai_cell)
    }
  })
}

shiny::shinyApp(ui = ui, server = server)
