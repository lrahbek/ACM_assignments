
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

  // Arrays for log liklihood, prior and posterior predictive second ratings 
  array[n_populations, n_agents, n_stim] real log_lik;  // Log likelihood for model comparison
  array[n_populations, n_agents, n_stim] int prior_pred_rating; // prior predictive second ratings
  array[n_populations, n_agents, n_stim] int post_pred_rating; // posterior predictiove second ratings
  
  // Generate prior and posterior predictive ratings: 
  
  for (p in 1:n_populations){
    // Calculate converted parameters: 
    population_ratio[p] = exp(weight_ratio_mu[p]);
    population_scaling[p] = exp(scaling_mu[p]);
    population_weight_first[p] = population_scaling[p] * population_ratio[p] / (1 + population_ratio[p]);
    population_weight_group[p] = population_scaling[p] / (1 + population_ratio[p]);
    
    // Generate population level values for prior predictive checks
    real weight_ratio_mu_prior = normal_rng(0, 1);
    real weight_ratio_sigma_prior = exponential_rng(2);
    real scaling_mu_prior = normal_rng(0,1);
    real scaling_sigma_prior = exponential_rng(2);

    for (i in 1:n_agents){
      // Define weights for first and group information for posterior predictive checks
      real w_first = weight_first[p, i];
      real w_group = weight_group[p, i];
      
      // Generate individual level variance values for prior predictive checks
      real z_weight_ratio_prior = std_normal_rng();
      real z_scaling_prior = std_normal_rng();
      
      // Calculate weight ratio and scaling factor for prior predictive checks
      real weight_ratio_prior= exp(weight_ratio_mu_prior + z_weight_ratio_prior * weight_ratio_sigma_prior);
      real scaling_factor_prior = exp(scaling_mu_prior + z_scaling_prior * scaling_sigma_prior);
      
      // Calculate weights for first and group information for prior predivtive checks 
      real w_first_prior = scaling_factor_prior * weight_ratio_prior / (1 + weight_ratio_prior);
      real w_group_prior = scaling_factor_prior / (1 + weight_ratio_prior);
      
      for (j in 1:n_stim){
        // calculate weighted information: posterior predictive checks  
        real first_rating_w = first_rating[p, i, j] * w_first;
        real group_rating_w = group_rating[p, i, j] * w_group;
        real neg_first_rating_w = (max_rating - first_rating[p, i, j]) * w_first;
        real neg_group_rating_w = (max_rating - group_rating[p, i, j]) * w_group;
        real alpha_post = 1 + first_rating_w + group_rating_w;
        real beta_post = 1 + neg_first_rating_w + neg_group_rating_w;
        
        // Posterior predictive second ratings 
        post_pred_rating[p, i, j] = beta_binomial_rng(7, alpha_post, beta_post);
        
        // Calculate log likelihood
        log_lik[p, i, j] = beta_binomial_lpmf(second_rating[p, i, j] | 7, alpha_post, beta_post); 
        
        // calculate weighted information: prior predictive checks  
        real first_rating_w_prior = first_rating[p, i, j] * w_first_prior;
        real group_rating_w_prior = group_rating[p, i, j] * w_group_prior;
        real neg_first_rating_w_prior = (max_rating - first_rating[p, i, j]) * w_first_prior;
        real neg_group_rating_w_prior = (max_rating - group_rating[p, i, j]) * w_group_prior;
        real alpha_post_prior = 1 + first_rating_w_prior + group_rating_w_prior;
        real beta_post_prior = 1 + neg_first_rating_w_prior + neg_group_rating_w_prior;
        
        // Posterior predictive second ratings 
        prior_pred_rating[p, i, j] = beta_binomial_rng(7, alpha_post_prior, beta_post_prior);
        
      }
    }
  }
}

