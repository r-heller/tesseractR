# Re-running this script regenerates R/sysdata.rda with the calibration
# coefficients consumed by tsr_win_prob(method = "heuristic"). It is a
# maintenance step and not part of the user-facing API. Run with:
#   Rscript data-raw/calibration.R

devtools::load_all()

set.seed(2026)
n_games <- 60L
sample_plies <- 4L

rows <- vector("list", n_games * sample_plies)
ptr <- 0L

for (g in seq_len(n_games)) {
  px <- sample(c("random", "greedy"), 1L)
  po <- sample(c("random", "greedy"), 1L)
  game <- tsr_play_game(px, po, seed = g)
  outcome_x <- if (game$winner == 1L) 1 else if (game$winner == 2L) 0 else 0.5
  outcome_o <- 1 - outcome_x
  b <- tesseractR::tsr_new_board()
  if (length(game$moves) < 4L) next
  sample_at <- sort(sample.int(length(game$moves), sample_plies))
  for (m in seq_along(game$moves)) {
    if (m %in% sample_at) {
      sc1 <- tesseractR::tsr_evaluate(b, 1L)
      sc2 <- tesseractR::tsr_evaluate(b, 2L)
      ptr <- ptr + 1L
      rows[[ptr]] <- data.frame(
        score = sc1, outcome = outcome_x
      )
      ptr <- ptr + 1L
      rows[[ptr]] <- data.frame(
        score = sc2, outcome = outcome_o
      )
    }
    b <- tesseractR::tsr_move(b, cell = game$moves[m])
  }
}
rows <- rows[seq_len(ptr)]
dat <- do.call(rbind, rows)
# Drop draws (outcome == 0.5) for the binomial fit.
fit_dat <- dat[dat$outcome != 0.5, ]
fit_dat$outcome <- as.integer(fit_dat$outcome)

mod <- glm(outcome ~ score, data = fit_dat, family = binomial())
slope <- unname(coef(mod)[["score"]])
intercept <- unname(coef(mod)[["(Intercept)"]])
# p = plogis((score - a) / b) ⇔ p = plogis(intercept + slope * score)
# ⇒ b = 1/slope; a = -intercept / slope
b_coef <- 1 / slope
a_coef <- -intercept / slope
.tsr_calibration <- list(a = a_coef, b = b_coef, n = nrow(fit_dat))

usethis::use_data(.tsr_calibration, internal = TRUE, overwrite = TRUE)
message("Calibration fit on ", nrow(fit_dat), " observations: ",
        sprintf("a=%.3f, b=%.3f", a_coef, b_coef))
