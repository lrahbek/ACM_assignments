
data {
  int <lower=1> n_stim;
  int <lower=1> n_agents;
  int <lower=1> max_rating;
  array[n_agents, n_stim] int <lower=0, upper=7> first_rating;
  array[n_agents, n_stim] int <lower=0, upper=7> second_rating;
  array[n_agents, n_stim] int <lower=0, upper=7> group_rating;
}
parameters{
  real <lower=0, upper=10> alpha_prior;
  real <lower=0, upper=10> beta_prior;
}
model {

  for (i in 1:n_agents) {
    for (j in 1:n_stim) {
      real alpha_post = alpha_prior + first_rating[i, j] + group_rating[i, j];
      real beta_post = beta_prior + (max_rating - first_rating[i, j]) + (max_rating - group_rating[i, j]);
      
      // model the second rating
      target += beta_binomial_lpmf(second_rating[i, j] | 7, alpha_post, beta_post);
    }
  }
}
generated quantities {

  array[n_agents, n_stim] real log_lik;
  array[n_agents, n_stim] int prior_pred_rating;
  array[n_agents, n_stim] int post_pred_rating;

  for (i in 1:n_agents) {
    for (j in 1:n_stim) {
      
      prior_pred_rating[i, j] = beta_binomial_rng(7, 1, 1);
      
      real alpha_post = alpha_prior + first_rating[i, j] + group_rating[i, j];
      real beta_post = beta_prior+(max_rating - first_rating[i, j]) + (max_rating - group_rating[i, j]);
      
      post_pred_rating[i, j] = beta_binomial_rng(7, alpha_post, beta_post);
      
      log_lik[i, j] = beta_binomial_lpmf(second_rating[i, j] | 7, alpha_post, beta_post);
    }
  }
}

