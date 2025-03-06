
data{
  // the number of trials (n) cannot be below 1 and should be integers
  int <lower=1> n;
  
  // the choice have length of number of trials and should be integers either 0 and 1 
  array[n] int <lower=0, upper=1> choice;
  
  // the feedback can either be 0 (loss) or 1 (win)
  array[n] int <lower=0, upper=1> feedback;
  
}

parameters{
  // theta_win (the bias for staying when winning) log odds scale
  real theta_WS;
  // theta_loss (the for leaving when losing) log odds scale
  real theta_LS;
}

transformed parameters{
  vector[n] stay_choice; 
  vector[n] lose_choice;
  vector[n] theta;
  
  for (trial in 1:n){
   if(feedback[trial] == 1){
     lose_choice[trial] = 0;
     
     if(choice[trial] == 1){
       stay_choice[trial] = 1;
     }
     else if (choice[trial] == 0){
       stay_choice[trial] = -1;
     }
   }
   if(feedback[trial] == 0){
     stay_choice[trial] = 0;
     if(choice[trial] == 1){
       lose_choice[trial] = -1;
     }
     else if (choice[trial] == 0){
       lose_choice[trial] = 1;
     }
   }
  }
 
  theta = theta_WS*stay_choice + theta_LS*lose_choice;
}

model{
  //priors (same priors for both biases, but individual)
  target += normal_lpdf(theta_WS | 0, 1);
  target += normal_lpdf(theta_LS | 0, 1);
  
  //liklihood (model)

  target += bernoulli_logit_lpmf(choice | theta);
  
}
generated quantities{
  // defining variables: 
  // theta_WS and theta_LS prior and posterior parameters on probability scales
  real<lower=0, upper=1> theta_WS_prior;  
  real<lower=0, upper=1> theta_LS_prior;  
  real<lower=0, upper=1> theta_WS_posterior;  
  real<lower=0, upper=1> theta_LS_posterior;  
  
  // generating variables
  // theta_WS and theta_LS prior and posterior parameters on probability scales 
  theta_WS_prior = inv_logit(normal_rng(0,1)); 
  theta_LS_prior = inv_logit(normal_rng(0,1)); 

  theta_WS_posterior = inv_logit(theta_WS); 
  theta_LS_posterior = inv_logit(theta_LS); 
}

