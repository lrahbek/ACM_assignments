# Assignment 3
- *Hand-in date: 08-04-2025*
- *By Astrid, Cassandra, Laura, & Sofie*

This assignment explores how individuals update their judgements in response to social influence using Bayesian modelling techniques. The aim is to implement and compare two hierarchical models of information integration: a Simple Bayesian model and a Weighted Bayesian model.

The goal of this assignment is to:

- Implement and compare two Bayesian models:
   - A Simple Hierarchical Bayesian model
   - A Weighted Hierarchical Bayesian model
- Simulate data from each model
- Evaluate model quality
- Fit both models to real behavioural data
- Compare models using LOO-CV and visualisation of participant-level preferences

## The Models

### Simple Bayesian Model
A hierarchical beta-binomial model using:
- Prior + direct evidence (FirstRating) + social evidence (GroupRating)

### Weighted Bayesian Model
Extends the simple model by including:
- A **scaling factor** (total influence weight)
- A **weight ratio** (balance between direct and social influence)

Both models are implemented in Stan and fitted using `cmdstanr`.

#### **The results and interpretation can be found in our report.**
