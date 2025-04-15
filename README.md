# Growth Models Supplementary Code

This repository contains R code used for fitting various growth models to longitudinal eye measurement data. The code implements Bayesian hierarchical modeling using the `brms` package with `CmdStanR` backend.

## Overview

The code provides implementation for six different growth models:

1. **Gompertz Function**
2. **Linear Function**
3. **Effective Radius Function**
4. **Bertalanffy Function**
5. **Mitscherlich Function**
6. **Logistic Function**

Additionally, it includes pseudo-code for forward and backward prediction methodologies, as well as code for analyzing prediction results.

## Model Descriptions

### Gompertz Function
```
mm_area ~ A * exp(- exp(-c * time_in_years + b))
```
A sigmoid growth model with three parameters (A, b, c), where A represents the asymptotic maximum, b relates to the displacement along the time axis and is parameterized this way for model stability, and c represents the growth rate.

### Linear Function
```
mm_area ~ time_in_years
```
A simple linear model relating area measurement to time.

### Effective Radius Function
```
mm_area ~ pi * (exp(-b0) + exp(-b1) * time_in_years)^2
```
A non-linear model using exponential terms to model area growth based on radius; we chose this parameterization for model stability, it is a fair assumption that lesion baseline radius and rate of growth are non-negative.

### Bertalanffy Function
```
mm_area ~ A * fmax(0, (1 - exp(-c * time_in_years + b)))^3
```
A comparison growth model adapted here for lesion measurements.

### Mitscherlich Function
```
mm_area ~ A * fmax(0, (1 - exp(-c * time_in_years + b)))
```
A growth model similar to Bertalanffy but without the cubic term.

### Logistic Function
```
mm_area ~ A/(1 + exp(b - c * time_in_years))
```
A classic sigmoid growth model with parameters for asymptote, midpoint, and growth rate.

## Model Implementation Details

Each model implementation follows a similar pattern:

1. **Data Loading**: Reading data from CSV files and setting date formats
2. **Model Formula Definition**: Using `brms` formula syntax with appropriate random effects
3. **Prior Specification**: Setting informative priors for model parameters
4. **Model Fitting**: Using the `brm()` function with the following settings:
   - High adaptation delta (0.99+) for stable MCMC sampling
   - Multiple chains (6-8) for convergence assessment
   - Long warmup (4000) and sampling periods (10000 iterations)
   - CmdStanR backend for efficient sampling
   - Parallel processing using available CPU cores
5. **Model Saving**: Storing fitted models as RDS files

## Random Effects Structure

All models use a hierarchical structure with random effects for:
- Individual participants (PID)
- Eye laterality nested within participants (PID:Laterality)

This allows the models to account for individual differences and correlation between left and right eyes within the same participant.

## Prediction Methodologies

### Forward Prediction
Predicts future measurements by training on:
- All data from other participants
- Only past exams from the target participant

### Backward Prediction
Predicts past measurements by training on:
- All data from other participants
- Only future exams from the target participant

## Prediction Analysis

The supplementary code also includes functions for analyzing prediction results:
- Calculating prediction scores and intervals
- Fitting hierarchical Gamma models to assess prediction performance
- Comparing different models using spline terms for prediction horizon
- Accounting for the number of observations in model fitting

## Requirements

- R with packages: `brms`, `tidybayes`, `bayesplot`, `ggplot2`, `dplyr`, `scoringRules`, `tidyr`, `patchwork`
- `CmdStanR` backend for efficient MCMC sampling
- Sufficient computational resources for running multiple MCMC chains in parallel
