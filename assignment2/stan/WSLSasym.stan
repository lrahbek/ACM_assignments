
data{
  int <lower=1> n; // number of trials (integers above 1)
  array[n] int <lower=0, upper=1> choice; // choice made by the guesser (length n and ints of 0 (left) or 1 (right))
  array[n] int <lower=0, upper=1> feedback; // feedback for each guess (length n and ints of 0 (loss) or 1 (win))
}
parameters{
  real theta_WS; // the bias for staying when winning on log odds scale
  real theta_LS; // the bias for shifting when losing on log odds scale
}

transformed parameters{
  vector[n] win_choice; // storing the choice when winning (0 = lost on last trial)
  vector[n] lose_choice;// storing the choice when losing  (0 = won on last trial)
  vector[n] theta;      // storing theta for each trial (probability of choosing right hand on log odds scale)
  
  theta[1] = logit(0.5);// theta for the first trial is 0.5 as there is no feedback from previous trial to use
  
  for (trial in 2:n){   // loop through each trial and define whether theta_WS or theta_LS should be used as theta
  
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
   // for each trial theta is defined depending on the outcome of the previous trial (loss or win):
   theta[trial] = theta_WS*win_choice[trial] + theta_LS*lose_choice[trial]; 
  }
 
}

model{
  target += normal_lpdf(theta_WS | 0, 1); // prior for theta_WS 
  target += normal_lpdf(theta_LS | 0, 1); // prior for theta_LS
  
  // liklihood model, for each trial the choice is given the theta (as calculated in the transformed parameters chunk)
  for (trial in 1:n){
    target += bernoulli_logit_lpmf(choice[trial] | theta[trial]); 
  }
}
generated quantities{
  // Prior and Posterior theta_WS and theta_LS parameters on probability scales
  real<lower=0, upper=1> theta_WS_prior = inv_logit(normal_rng(0,1));
  real<lower=0, upper=1> theta_LS_prior = inv_logit(normal_rng(0,1));  
  real<lower=0, upper=1> theta_WS_posterior = inv_logit(theta_WS);  
  real<lower=0, upper=1> theta_LS_posterior = inv_logit(theta_LS);  
  
  // Prior predictions: // for each trial estimate the choice based on prior theta 
  vector[n] prior_preds;                   // array for prior predictions
  vector[n] prior_theta_l;                 // array for theta on log odds scale based on priors
  real theta_WS_prior_l = normal_rng(0,1); // theta_WS prior on log-odds scale
  real theta_LS_prior_l = normal_rng(0,1); // theta_LS prior on log_odds scale

  prior_theta_l[1] = logit(0.5); // prior theta for the first trial is 0.5 (random)

  prior_theta_l[2:n] = theta_WS_prior_l*win_choice[2:n] + theta_LS_prior_l*lose_choice[2:n]; 

  for (trial in 1:n){       
    prior_preds[trial] = binomial_rng(1, inv_logit(prior_theta_l[trial])); 
  }
 
  // Posterior predictions: for each trial estimate the choice based on theta
  array[n] real posterior_preds; // array for posterior predictions 
  for (trial in 1:n){       
    posterior_preds[trial] = binomial_rng(1, inv_logit(theta[trial])); 
  }
  
}

