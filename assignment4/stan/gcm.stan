
data{
  int<lower=1> nagents;                                   // number of agents
  int<lower=1> n_trials;                                  // number of trials 
  int<lower=1> nfeatures;                                 // number of features in each stimuli
  int<lower=1> nstim;                                     // number of unique stimuli
  real<lower=0, upper=1> b;                               // bias for selecting cat 'danger' (1)
  array[nstim, nfeatures] int<lower=0, upper=1> stimuli;  // features of each stimuli
  array[nagents, n_trials] int<lower=1, upper=32> obs;    // observations (s_id) for each agent+trial
  vector<lower=0, upper=1>[nstim] cat_danger;             // vector of categories for each unique stimuli
  array[nagents, n_trials] int<lower=0, upper=1> choice;  // agent-choice on each trial 
  
  // priors
  vector[nfeatures] w_prior_values;                       // priors for param w
  array[2] real c_prior_values;                           // mean and sd for logit-normal dist (param c)
}
parameters{
  row_stochastic_matrix[nagents, nfeatures] w;            // w param (each row is a simplex)
  vector[nagents] logit_c;                                // c param for each agent
}

transformed parameters{

  // Parameter c: inverse logit transformed 
  vector <lower=0, upper=2>[nagents] c = inv_logit(logit_c)*2;
  
  // Parameter r (probability of response = 1 ) 
  array[nagents, n_trials] real<lower=0.0001, upper=0.9999> r;
  array[nagents, n_trials] real rr; 

  for (a in 1:nagents){                     // Loop through each agent 
  	for (i in 1:n_trials){                  // Loop through each trial
  	
  		vector[(i-1)]  exemp_similarities;    // Vector of similarities between current obs and previous obs
  		
  		for (e in 1:(i-1)){                   // Loop through previous aliens
  			array[nfeatures] real tmp_distance; // Array of distances for each feature for previous alien e
  			
  			for (j in 1:nfeatures){             // Loop through each feature in alien e and calculate distances
  			  tmp_distance[j] = w[a,j]*abs(stimuli[obs[a, e], j] -  stimuli[obs[a, i], j] );
  			}
  			
  			// Calculate similarity between current alien and alien e:
  			exemp_similarities[e] = exp(-c[a] * sum(tmp_distance));
  		}
  		
  	  // If first trial or category is new, make r random: 	
      if (i == 1 || sum(cat_danger[obs[a, 1:(i-1)]]) == 0 || sum(cat_danger[obs[a, 1:(i-1)]]) == (i-1)){
        r[a, i] = 0.5;
      }
      
      // Otherwise calculate summed similarities (per category):
      else{
        array[2] real similarities; 
        
        vector[(i-1)] ind_danger = cat_danger[obs[a, 1:(i-1)]];      // vector of inds of dangerous stim
        vector[(i-1)] ind_safe = abs(cat_danger[obs[a, 1:(i-1)]]-1); // vector of inds of safe stim

        
        similarities[1] = sum(ind_danger.*exemp_similarities);       // sum of cat = 1
        similarities[2] = sum(ind_safe.*exemp_similarities);         // sum of cat = 0

        // Calculate probability of choosing 1:
        rr[a, i] = (b*similarities[1]) / (b*similarities[1] + (1-b)*similarities[2]);

        // (make sampling work)
        if (rr[a, i] > 0.9999){
          r[a, i] = 0.9999;
        } else if (rr[a, i] < 0.0001){
            r[a, i] = 0.0001;
        } else if (rr[a, i] > 0.0001 && rr[a, i] < 0.9999){
            r[a, i] = rr[a, i];
        } else{
            r[a, i] = 0.5;
        }
      }
  	}
  }
}

model {
  // Priors
  for (a in 1:nagents){
    target += dirichlet_lpdf(w[a,] | w_prior_values);
    target += normal_lpdf(logit_c[a] | c_prior_values[1], c_prior_values[2]);
  }
  // Liklihood
  
  for (a in 1:nagents){
    target += bernoulli_lpmf(choice[a, ] | r[a, ]);
  }
}


