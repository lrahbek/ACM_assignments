# ----- STRATEGY FUNCTIONS FOR ASSIGNMENT 1 ----

# ---- strategy 1: Assymetric & Probabilistic WSLS (w. noise) ----
WSLS_asym_noise <- function(prev_choice, feedback,
                            WS_weight, LS_weight, noise){
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

memory_model1 <- function(prev_choices, prev_feedbacks, window_size = 7) {
  
  # Window size, return the last/newest part of the lists
  if (length(prev_choices) > window_size) {
    prev_choices <- tail(prev_choices, window_size)
    prev_feedbacks <- tail(prev_feedbacks, window_size)
  }
  
  # Success rates
  success_left <- sum(prev_feedbacks[prev_choices == 0]) / max(1, sum(prev_choices == 0))
  success_right <- sum(prev_feedbacks[prev_choices == 1]) / max(1, sum(prev_choices == 1))
  
  # Decide next choice
  # if success rate of right is higher, then choose right/1
  if (success_right > success_left) {
    return(1)
    # if success rate of left is higher, then choose left/0
  } else if (success_left > success_right) {
    return(0)
  } else {
    # if the success rates are equal (which should be impossible?), random choice from binom dist.
    return(rbinom(1, 1, 0.5))
  }
}


memory_model2 <- function(hider_choices, noise){
  
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


