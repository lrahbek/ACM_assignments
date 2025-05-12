# Assignment 4
- *Hand-in date: 13-05-2025*
- *By Astrid, Cassandra, Laura, & Sofie*

In this assignment, we will implement and evaluate a formalized model of categorization in the context of a simulated alien game. Participants were asked to classify whether an alien seems dangerous based on visual features. We will apply a Generalized Context Model (GCM) and fit it to simulated data. Finally, the report will include a discussion of model performance and parameter estimation on empirical data. All code for the assignment can be found on GitHub  https://github.com/lrahbek/ACM_assignments/tree/main/assignment4. 

## Explanation of Experimental Setup
The alien game involves categorizing 32 unique alien stimuli, each defined by five binary visual features: eyes (on stalk or not), legs (slim or big), spots (present or not), arms (up or down), and color (green or blue). Each stimulus is encoded as a five-dimensional binary vector and repeated in a randomized order across three cycles, resulting in 96 trials in total. This assignment focuses on session 1 and condition 1 with dyads. In session 1, an alien will be labeled as dangerous if it, for example, has both spots and eyes on stalks.

## The Model
We will implement the GCM model, which is an exemplar-based model of categorization developed by Nosofsky in the 1980s. Unlike prototype or rule-based models, the GCM assumes that individuals store individual exemplars of previously encountered stimuli and make judgments based on these stored examples. In the GCM, each stimulus is represented as a point in a multidimensional space with dimensions corresponding to stimulus features, whereas similarly between features is modeled using an exponential decay function. Another feature is selective attention, that allows for differently weighting of stimulus dimensions. 

#### **The results and interpretation can be found in our report.**
