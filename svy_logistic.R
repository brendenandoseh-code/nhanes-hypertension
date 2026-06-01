#!/usr/bin/env Rscript
# ---------------------------------------------------------------------------
# Design-exact survey logistic regression for the NHANES hypertension project.
#
# Called from "Hypertension Project.ipynb" via subprocess. It reads a CSV the
# notebook exports (model variables + survey design columns), fits a complex-
# survey logistic regression with R's `survey` package (the gold standard for
# design-based inference: Taylor-linearized standard errors that fully account
# for stratification, clustering, and weights), and writes adjusted odds ratios
# with 95% confidence intervals back to CSV for the notebook to display.
#
# Usage: Rscript svy_logistic.R <input_csv> <output_csv>
# ---------------------------------------------------------------------------
suppressPackageStartupMessages(library(survey))

args <- commandArgs(trailingOnly = TRUE)
infile  <- if (length(args) >= 1) args[1] else "nhanes_survey.csv"
outfile <- if (length(args) >= 2) args[2] else "svy_results.csv"

d <- read.csv(infile)

# Complex-survey design: PSUs nested within strata, weighted by the exam weight.
des <- svydesign(
  ids     = ~SDMVPSU,
  strata  = ~SDMVSTRA,
  weights = ~WTMECPRP,
  data    = d,
  nest    = TRUE
)

# Survey-weighted logistic regression (quasibinomial = design-based binomial).
model <- svyglm(
  hypertension ~ age + female + bmi + vigorous_active +
    moderate_active + sleep_trouble + sleep_hrs_weekday,
  design = des,
  family = quasibinomial()
)

ci  <- confint(model)                      # design-correct 95% CIs (normal approx)
est <- summary(model)$coefficients

out <- data.frame(
  term       = rownames(est),
  odds_ratio = exp(coef(model)),
  ci_low     = exp(ci[, 1]),
  ci_high    = exp(ci[, 2]),
  p_value    = est[, 4],
  row.names  = NULL
)
out <- out[out$term != "(Intercept)", ]

write.csv(out, outfile, row.names = FALSE)
cat(sprintf("svyglm complete: %d rows, %d terms -> %s\n",
            nrow(d), nrow(out), outfile))
