

data {
  int <lower=1> n_stim;
  int <lower=1> n_agents;
  int <lower=1> max_rating;
  array[n_stim, n_agents] int <lower=0, upper=7> first_rating;
  array[n_stim, n_agents] int <lower=0, upper=7> second_rating;
  array[n_stim, n_agents] int <lower=0, upper=7> group_rating;
}

parameters{
  real alpha_prior;
  real beta_prior;
}

model {
  for (i in 1:n_agents) {
    for (j in 1:n_stim) {
      
      real alpha_post = alpha_prior + first_rating[j, i] + group_rating[j, i];
      real beta_post = beta_prior + (max_rating - first_rating[j, i]) + (max_rating - group_rating[j, i]);
      
      // model the second rating
      target += beta_binomial_lpmf(second_rating[j, i] | 7, alpha_post, beta_post);
    }
  }
}
generated quantities {

  array[n_stim, n_agents] real log_lik;
  
  array[n_stim, n_agents] int prior_pred_rating;
  array[n_stim, n_agents] int post_pred_rating;

  for (i in 1:n_agents) {
    for (j in 1:n_stim) {
      
      prior_pred_rating[j, i] = beta_binomial_rng(7, 1, 1);
      
      real alpha_post = alpha_prior + first_rating[j, i] + group_rating[j, i];
      real beta_post = beta_prior+(max_rating - first_rating[j, i]) + (max_rating - group_rating[j, i]);
      
      post_pred_rating[j, i] = beta_binomial_rng(7, alpha_post, beta_post);
      
      log_lik[j, i] = beta_binomial_lpmf(second_rating[j, i] | 7, alpha_post, beta_post);
    }
  }
}

