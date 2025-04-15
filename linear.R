# Required Packages
library('cmdstanr')
library('brms')
library('rstan')

# Load Participant Long-Form Data, which should include at least time_in_years (time), PID (subject-level id), Laterality (eye-level id), and mm_area (lesion area)
data = read.csv("...")

set.seed(603)

linear_formula = bf(mm_area ~ time_in_years + (time_in_years | PID) + 
                    (time_in_years | p | PID:Laterality))

priors = c(
  set_prior("normal(0, 10000)", class = "Intercept"),
  set_prior("normal(1.66, 10000)", class = "b", coef = "time_in_years"),
  set_prior("cauchy(0, 20)", class = "sigma")
)

fit_linear = brm(
  linear_formula,
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

saveRDS(fit_linear,...)
