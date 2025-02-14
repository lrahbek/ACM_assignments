# ----- STRATEGY FUNCTIONS FOR ASSIGNMENT 1 ----

# ---- strategy 1: Assymetric & Probabilistic WSLS (w. noise) ----
WSLS_asym_noise <- function(prev_choice, feedback, WS_weight, LS_weight, noise){
  if(feedback == 1){
    if(rbinom(1, 1, WS_weight) == 1){
      choice <- prev_choice
    }
    else{
      choice <- 1 - prev_choice
    }
  }
  else if (feedback == 0){
    if(rbinom(1, 1, LS_weight) == 1){
      choice <- 1 - prev_choice
    }
    else{
      choice <- prev_choice
    }  
  }
  if(rbinom(1, 1, noise) == 1){
    choice <- rbinom(1, 1, .5)
  }
  return(choice)
}
# ---- Strategy 2: Memory w. moving Average of 7 trials (w. noise) ----
memory_agent <- function(hider_choices, noise){
  
  right_prob <- sum(hider_choices)/length(hider_choices) #probability of the right hand (1) holding the penny, based on the proportion of the previous seven trials where the penny was in the right hand. 
  choice <- rbinom(1, 1, right_prob)
  if(rbinom(1, 1, noise) == 1){
    choice <- rbinom(1, 1, .5)
  }
  return(choice)
}


# ---- Additional models ----

# Strategy 3: WSLS with noise and deterministic 
WSLS_noise <-function(prev_choice, feedback, noise){
  if(feedback == 1){
    choice <- prev_choice
  }
  else if (feedback == 0){
    choice <- 1 - prev_choice 
  }
  if(rbinom(1, 1, noise) == 1){
    choice <- rbinom(1, 1, 0.5)
  }
  return(choice)
}

## Random agent
random_agent <- function(rate){
  choice <- rbinom(1, 1, rate) 
  return(choice)
} 


