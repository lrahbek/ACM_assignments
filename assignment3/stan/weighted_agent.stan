
data {
  int <lower=1> n_stim;
  int <lower=1> n_populations;
  int <lower=1> n_agents;
  int <lower=1> max_rating;
  array[n_populations, n_agents, n_stim] int <lower=0, upper=7> first_rating;
  array[n_populations, n_agents, n_stim] int <lower=0, upper=7> second_rating;
  array[n_populations, n_agents, n_stim] int <lower=0, upper=7> group_rating;
}
parameters {
  // population level params
  array[n_populations] real <lower=-6, upper=10> scaling_mu;
  array[n_populations] real <lower=0> scaling_sigma;
  array[n_populations] real <lower=-6, upper=6> weight_ratio_mu;
  array[n_populations] real <lower=0> weight_ratio_sigma;
  
  // Individual-level (random) effects
  array[n_populations, n_agents] real z_weight_ratio;              
  array[n_populations, n_agents] real z_scaling;                   
}
transformed parameters {
  // Individual-level parameters
  array[n_populations, n_agents] real <lower=0> weight_ratio;  
  array[n_populations, n_agents] real <lower=0> scaling_factor;     
  array[n_populations, n_agents] real <lower=0> weight_first;     
  array[n_populations, n_agents] real <lower=0> weight_group;      
  
  // Non-centered parameterization
  for (p in 1:n_populations){
    for (i in 1:n_agents){
      weight_ratio[p, i] = exp(weight_ratio_mu[p] + z_weight_ratio[p, i] * weight_ratio_sigma[p]);
      scaling_factor[p, i] = exp(scaling_mu[p] + z_scaling[p, i] * scaling_sigma[p]);
      
      weight_first[p, i] = scaling_factor[p, i] * weight_ratio[p, i] / (1 + weight_ratio[p, i]);
      weight_group[p, i] = scaling_factor[p, i]  / (1 + weight_ratio[p, i]);
    }
  }
}
model {
  for (p in 1:n_populations){
    // Population level priors 
    target += normal_lpdf(weight_ratio_mu[p] | 0, 1);
    target += normal_lpdf(scaling_mu[p] | 0, 1);
    target += exponential_lpdf(weight_ratio_sigma[p] | 2);        
    target += exponential_lpdf(scaling_sigma[p] | 2);    
    
    for (i in 1:n_agents){
      // Agent level priors 
      target += std_normal_lpdf(z_weight_ratio[p, i]);
      target += std_normal_lpdf(z_scaling[p, i]);
    }
  }
  // Likelihood
  for (p in 1:n_populations){
    for (i in 1:n_agents){
      real w_first = weight_first[p, i];
      real w_group = weight_group[p, i];
      
      for (j in 1:n_stim){
        real first_rating_w = first_rating[p, i, j] * w_first;
        real group_rating_w = group_rating[p, i, j] * w_group;
        
        real neg_first_rating_w = (max_rating - first_rating[p, i, j]) * w_first;
        real neg_group_rating_w = (max_rating - group_rating[p, i, j]) * w_group;
        
        real alpha_post = 1 + first_rating_w + group_rating_w;
        real beta_post = 1 + neg_first_rating_w + neg_group_rating_w;
        
        target += beta_binomial_lpmf(second_rating[p, i, j] | 7, alpha_post, beta_post);
      }
    }
  }
}
generated quantities {
  
  // Arrays for converted population parameters 
  array[n_populations] real population_ratio;
  array[n_populations] real population_scaling;
  array[n_populations] real population_weight_first;
  array[n_populations] real population_weight_group;

  array[n_populations, n_agents, n_stim] real log_lik;  // Log likelihood for model comparison
  array[n_populations, n_agents, n_stim] int pred_second_rating; // Population and individual predictions
  
  for (p in 1:n_populations){
    population_ratio[p] = exp(weight_ratio_mu[p]);
    population_scaling[p] = exp(scaling_mu[p]);
    population_weight_first[p] = population_scaling[p] * population_ratio[p] / (1 + population_ratio[p]);
    population_weight_group[p] = population_scaling[p] / (1 + population_ratio[p]);
  
    for (i in 1:n_agents){
      real w_first = weight_first[p, i];
      real w_group = weight_group[p, i];
      
      for (j in 1:n_stim){
        // calculate weighted information 
        real first_rating_w = first_rating[p, i, j] * w_first;
        real group_rating_w = group_rating[p, i, j] * w_group;
        real neg_first_rating_w = (max_rating - first_rating[p, i, j]) * w_first;
        real neg_group_rating_w = (max_rating - group_rating[p, i, j]) * w_group;
        real alpha_post = 1 + first_rating_w + group_rating_w;
        real beta_post = 1 + neg_first_rating_w + neg_group_rating_w;
        
        // Generate predictions using beta-binomial
        pred_second_rating[p, i, j] = beta_binomial_rng(7, alpha_post, beta_post);
        
        // Calculate log likelihood
        log_lik[p, i, j] = beta_binomial_lpmf(second_rating[p, i, j] | 7, alpha_post, beta_post);        
      }
    }
  }
}

