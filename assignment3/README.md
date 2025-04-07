# Assignment 3
- *Hand-in date: 08-04-2025*
- *By Astrid, Cassandra, Laura, & Sofie*

This assignment explores how individuals update their judgements in response to social influence using Bayesian modelling techniques. The aim is to implement and compare two hierarchical models of information integration: a Simple Bayesian model and a Weighted Bayesian model. The full code and documentation can be found in this repository: https://github.com/lrahbek/ACM_assignments/blob/main/assignment3/assignment3.Rmd

The goal of this assignment is to:

- Implement and compare two Bayesian models:
- A Simple Hierarchical Bayesian model
- A Weighted Hierarchical Bayesian model
- Simulate data from each model 
- Fit both models to real behavioural data
- Evaluate model quality using posterior diagnostics and predictive checks
- Compare models using LOO-CV and visualisation of participant-level preferences

## Models

### Simple Bayesian Model
A hierarchical beta-binomial model using:
- Prior + direct evidence (FirstRating) + social evidence (GroupRating)

### Weighted Bayesian Model
Extends the simple model by including:
- A **scaling factor** (total influence weight)
- A **weight ratio** (balance between direct and social influence)

Both models are implemented in Stan and fitted using `cmdstanr`.

## Model Simulation & Recovery

Models were first fitted to simulated data to assess:
- Parameter recovery
- Inference quality
- R-hat, trace plots
- Posterior vs true parameter values

## Model Fitting & Evaluation

After validation, both models were fitted to the real data. Model quality was assessed through:

- Trace plots and convergence diagnostics
- Prior and posterior predictive checks
- Parameter summaries
- Leave-One-Out Cross-Validation

---

## Getting Started

To run the project locally:

1. Clone this repository  
2. Install required R packages:
   ```r
   install.packages(c("cmdstanr", "tidyverse", "loo", "posterior", "ggplot2", "viridis"))
   cmdstanr::install_cmdstan()
