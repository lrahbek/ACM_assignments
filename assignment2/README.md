# Assignment 2
- *Hand-in date: 11-03-2025*
- *By Astrid, Cassandra, Laura, & Sofie*

In this assignment, we will build and validate a cognitive model of matching pennies behavior using Stan. We will begin by describing the model, explaining its structure, and purpose. Following, we will assess the quality of the model and conduct parameter recovery. Finally, we will analyze and discuss the results.

## The Model
We propose an asymmetric, probabilistic Win-Stay Lose-Shift (WSLS) model to capture the behavior in the Matching Pennies Game (MPG). Our model extends the classic WSLS strategy by incorporating probabilistic weighting, which reflects bounded rationality and strategic uncertainty. Specifically,  the guesser stays with a winning choice 90% of the time but shifts following a loss with a probability of 60%. These probabilities reflect the tendency of agents to exploit successful strategies while remaining more explorative after a loss. Additionally, the probabilistic component accounts for deviations from a strict deterministic behavior, which also aligns with the Theory of Mind framework, as the hider cannot fully predict the guesser’s actions due to the inherent randomness. The STAN code with comments can be found on GitHub.

## Model Quality 
The quality of the model is evaluated by assessing the Markov chains (through trace plots and convergence diagnostics), prior predictive and posterior predictive checks and prior-posterior update checks. 

## Parameter Recovery 
To assess the reliability of our model and investigate whether the model can recover parameters of different value, we will conduct parameter recovery. Parameter recovery entails simulating data, fitting our model to the simulated data, and evaluating how well the estimated parameters align with the true values used in the simulations.

#### **The results and interpretation can be found in our report.**
