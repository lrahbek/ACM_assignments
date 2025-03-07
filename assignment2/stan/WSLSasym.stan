
data{
  int <lower=1> n; // the number of trials (n) cannot be below 1 and should be integers
  array[n] int <lower=0, upper=1> choice; // the choice made by the guesser (WSLS) with length og n and can be ints 0 or 1
  array[n] int <lower=0, upper=1> feedback; // the feedback can either be 0 (loss) or 1 (win)
}
parameters{
  real theta_WS; // the bias for staying when winning on log odds scale
  real theta_LS; // the bias for shifting when losing on log odds scale
}

transformed parameters{
  vector[n] win_choice;  // define vector for storing the choice when winning (0 = lost on last trial)
  vector[n] lose_choice; // define vector for storing the choice when losing  (0 = lost on last trial)
  vector[n] theta;       // define vector for storing theta for each trial (probability of choosing right hand)
  
  theta[1] = logit(0.5); // theta for the first trial is 0.5 as there is no feedback from previous trial to use
  
  for (trial in 2:n){    // loop through each trial from trial 2 and define whether theta_WS or theta_LS should be used as theta
  
   if(feedback[trial-1] == 1){      // if the guesser won on the previous trial
     lose_choice[trial] = 0;        // discount theta_LS parameter when calculating theta
     
     if(choice[trial-1] == 1){      // if the guesser picked right (1) on the previous trial 
       win_choice[trial] = 1;       // use theta_WS parameter when calculating theta
     }
     else if (choice[trial-1] == 0){// if the guesser picked left (0)
       win_choice[trial] = -1;      // use theta_WS parameter when calculating theta
     }
   }
   if(feedback[trial-1] == 0){      // if the guesser lost on the previous trial  
     win_choice[trial] = 0;         // discount theta_wS parameter when calculating theta
     
     if(choice[trial-1] == 1){      // if the guesser picked right (1) on the previous trial 
       lose_choice[trial] = -1;     // use theta_LS when calculating theta
     }
     else if (choice[trial-1] == 0){// if the guesser picked left (0) on the previous trial 
       lose_choice[trial] = 1;      // use theta_LS when calculating theta 
     }
   }
   theta[trial] = theta_WS*win_choice[trial] + theta_LS*lose_choice[trial]; // for each trial theta is defined depending on the outcome of the previous trial (lose or win) 
  }
 
}

model{
  target += normal_lpdf(theta_WS | 0, 1); // prior for theta_WS 
  target += normal_lpdf(theta_LS | 0, 1); // prior for theta_LS
  
  for (trial in 1:n){
    target += bernoulli_logit_lpmf(choice[trial] | theta[trial]); // liklihood model, for each trial the choice is given the theta (as calculated in the transformed parameters chunk)
  }
}
generated quantities{
  // defining variables: theta_WS and theta_LS prior and posterior parameters on probability scales
  real<lower=0, upper=1> theta_WS_prior;
  real<lower=0, upper=1> theta_LS_prior;  
  real<lower=0, upper=1> theta_WS_posterior;  
  real<lower=0, upper=1> theta_LS_posterior;  
  
  // generating variables: theta_WS and theta_LS prior and posterior parameters on probability scales 
  theta_WS_prior = inv_logit(normal_rng(0,1)); 
  theta_LS_prior = inv_logit(normal_rng(0,1)); 
  theta_WS_posterior = inv_logit(theta_WS); 
  theta_LS_posterior = inv_logit(theta_LS); 
}

