# Load any data
full_data = read.csv("...") # Path to anonymous Gompertz model data
alldf = read.csv("...") # Path to Forward Bayesian Forecast results

# Create score frame, labeling all models
score_frame = data.frame(
  PID = ...,                # Each PID should have repeated scores for each visit after the 5th visit (for each laterality)
  Laterality = ...,         # If a participant has GA in both eyes
  scores = ...,             # an indicator for the score you want to analyze (CRPS or Log Score), can be derived with packages like `scoringRules`
  model = ...,              # an indicator (as a factor) for which model is producing the score (Gompertz, Logistic, ...)
  Date = ...,               # Date of exam visit
  in_95_interval = ...,     # Indicator (T/F) was the actual area for the visit on this date in the 90% interval for the given model?
  pit_value = ...,          # Derived PIT value comparing area for the visit on this date for the given model.
  time_in_years = ...,      # Derived time value, calculated as years from first visit from this date.
  time_horizon = ...,       # Derived as the distance between the time of the last observed area and the time of the prediction (in years)
  time_horizon_std = ...,   # Standardized time horizon variable
  N_in_model = ...,         # Derived as the number (N) of observations used to make the prediction.
  N_in_model_std = ...      # Standardized N variable
)

# Define priors for Bayesian model
prior_spec <- c(
  prior("cauchy(0,2)", lb=0, class = "sd"),                    # The half-Cauchy (enforced by the lb=0 constraint) is a relatively standard choice for variance components. Weakly informative, but with enough mass near zero to prevent overfitting
  prior("uniform(0, x)", ub=x, lb=0, class = "Intercept"),     # While the prior is uniform (non-informative) within its range, the choice of x represents a weak form of prior information; given the expected range of the scores from the scale of the predictions, x just needs to be sufficiently large to be non-informative.
  prior("exponential(1)", class = "sds")                       # By using an exponential prior (which is left-skewed with peak at zero), this regularizes the smoothing splines to prevent overfitting
)

# Fit hierarchical model with splines for time horizon
model_fit <- brm(
  # Main fixed effects
  scores ~ model +                               # We would like to analyze differences in model performance
    s(time_horizon_std, by = model, k = 4) +     # While controlling for time horizon, which is accounted for as a non-linear spline term
    N_in_model_std + N_in_model_std:model +      # We also adjust for the number of observations, hypothesizing that increasing observations would produce better scores
    (1 | PID) + (1 | PID:Laterality),            # Random intercept terms for subject-level and eye-level correlation
  data = score_frame,
  family = Gamma(link = "log"),                  # A log-link gamma assumption is natural given the positive, right-skewed nature of prediction error scores
  prior = prior_spec,
  chains = 8,
  backend = 'cmdstanr',
  save_pars = save_pars(all = TRUE),
  save_warmup = TRUE,
  iter = 15000,
  warmup = 5000,
  cores = 8,
  control = list(adapt_delta = 0.99, max_treedepth = 25)
)
