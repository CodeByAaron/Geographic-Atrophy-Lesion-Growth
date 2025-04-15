# Required Packages
library('cmdstanr')
library('brms')
library('rstan')

# Load Participant Long-Form Data, which should include at least time_in_years (time), PID (subject-level id), Laterality (eye-level id), and mm_area (lesion area)
data = read.csv("...")

set.seed(603)

effr_formula = bf(
  mm_area ~ pi * (exp(-b0) + exp(-b1) * time_in_years)^2,
  b0 ~ 1 + (1 |p| PID:Laterality) + (1 | PID),
  b1 ~ 1 + (1 |p| PID:Laterality) + (1 | PID),
  nl=TRUE
)

priors = c(
  set_prior("normal(.72, 5)", class = "b", nlpar = "b0"),
  set_prior("normal(.63, 5)", class = "b", nlpar = "b1"),
  set_prior("cauchy(0, 2)", class = "sd", nlpar = "b0"),
  set_prior("cauchy(0, 2)", class = "sd", nlpar = "b1"),
  set_prior("cauchy(0, 2)", class = "sigma")
)

fit_effr = brm(
  effr_formula,
  data = data,
  family = gaussian(),
  prior = priors,
  control = list(adapt_delta = 0.999, max_treedepth = 25),
  chains = 8,
  warmup = 4000,
  iter = 14000,
  backend = 'cmdstanr',
  save_pars = save_pars(all = TRUE),
  cores = parallel::detectCores() - 1
)

saveRDS(fit_effr,...)
