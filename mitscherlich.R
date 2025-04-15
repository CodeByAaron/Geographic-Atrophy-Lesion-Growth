# Required Packages
library('cmdstanr')
library('brms')
library('rstan')

# Load Participant Long-Form Data, which should include at least time_in_years (time), PID (subject-level id), Laterality (eye-level id), and mm_area (lesion area)
data = read.csv("...")

set.seed(603)

mitscherlich_formula = bf(
  mm_area ~ A * fmax(0, (1 - exp(-c * time_in_years + b))),
  A ~ 1 + (1 | p | PID:Laterality) + (1 | PID),
  b ~ 1 + (1 | p | PID:Laterality) + (1 | PID),
  c ~ 1 + (1 | p | PID:Laterality) + (1 | PID),
  nl = TRUE
)

priors = c(
  set_prior("normal(30, 50)", lb = 0, nlpar = "A"),
  set_prior("normal(0,20)", nlpar = "b"),
  set_prior("frechet(2.0392,0.2874)",lb = 0, nlpar = "c"),
  set_prior("cauchy(0,10)", lb = 0, class = "sd", nlpar = "A"),
  set_prior("cauchy(0,5)", lb = 0, class = "sd", nlpar = "b"),
  set_prior("cauchy(0,2)", lb = 0, class = "sd", nlpar = "c"),
  set_prior("cauchy(0,10)", lb = 0, class = "sigma")
)

fit_mitscherlich = brm(
  mitscherlich_formula,
  data = data,
  family = gaussian(),
  prior = priors,
  control = list(adapt_delta = 0.999,max_treedepth = 25),
  chains = 8,
  warmup = 4000,
  iter = 14000,
  backend = 'cmdstanr',
  save_pars = save_pars(all = TRUE),
  cores = parallel::detectCores() - 1
)

saveRDS(fit_mitscherlich,...)
