# Assignment 1
- *Hand-in date: 18-02-2025*
- *By Astrid, Cassandra, Laura, & Sofie*

In this assignment, we will define and describe two possible strategies to play the Matching Pennies Game (MPG) and discuss their cognitive constraints. We will formalise these strategies with code and simulate their performance against a baseline model. Finally, we will visualise the results and discuss their implications.

In the MPG, one player (the guesser) tries to match the other’s choice, while the other (the hider) aims to mismatch. Observed behavior in the MPG can be analysed and modelled based on behavioral patterns and theoretical considerations. A simple strategy within the framework is the Win-Stay-Lose-Shift (WSLS) strategy, where a player repeats successful choices (win-stay) and switches after a loss (lose-shift). 

The WSLS strategy will be used by the hider in two simulations; one where strategy 1 is used by the guesser, and one where strategy 2 is used by the guesser. The two strategies of interest will be described below. Both simulations have 100 agent pairs (consisting of a hider and a guesser), each pair plays 120 trials. Noise will be added to all models to make them more closely resemble reality, where it introduces a cognitive constraint that accounts for human error and distraction. All three strategies have the same level of noise (0.1), meaning that ~10% of the trials the strategy based choice is overridden by a random choice.

## Strategy 1
Building on this, we propose an asymmetric, probabilistic WSLS strategy. The strategy models decision-making by adding weighted probabilities to staying or shifting. After a win, the guesser stays 90% of the time; while after a loss, it shifts 60% of the time. The weights were determined based on the assumption that an agent is more inclined towards exploitation in trials following a win than trials following a loss, where the agent is more inclined towards exploration. By introducing probabilistic shifts, we model a boundedly rational agent that follows a strategy but occasionally deviates, much like human behavior. This also aligns with the Theory of Mind framework, as the hider cannot fully predict the guesser’s strategy due to inherent randomness in the behavior. 

## Strategy 2
The second strategy is based on the fact that human memory is limited, and it is impossible for a person playing the MPG to take all previous trials into account when guessing which hand the penny is hidden in. A popular theory on the limits of memory was introduced by the psychologist George Miller, who suggested that humans can retain an average number of 7 (± 2) chunks in working memory. 

A simple implementation of this cognitive constraint is the basis of the second strategy. For the formalisation of the model, we assume that the hider has a bias towards one of the possible hands. Therefore, for each trial the guesser chooses the hand which was most often the correct hand in the previous seven trials. For the first six trials, the probabilities are calculated based on the available information, e.g. in trial 4 the choice is based on the previous three trials.

#### **The results and interpretation can be found in our report.**
