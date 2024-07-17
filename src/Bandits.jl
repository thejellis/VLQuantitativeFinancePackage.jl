"""
    function sample(model::MyEpsilonSamplingBanditModel, world::MyTickerPickerWorldModel)::Dict{Int64, Array{Beta,1}}

This function solved the ticker picker problem as a bandit model using an epsilon-greedy strategy. 
The function takes two arguments: a bandit model and a world model. 
The bandit model is a custom type, [`MyEpsilonSamplingBanditModel`](@ref), which contains the parameters of the bandit model. 
The world model is a custom type, `MyTickerPickerWorldModel`, which contains the parameters of the world model. 
The function returns a dictionary where the keys are integers (time steps) and the values are arrays of Beta distributions.

### Arguments
- `model::MyEpsilonSamplingBanditModel`: An instance of the [`MyEpsilonSamplingBanditModel`](@ref) that defines the bandit model parameters.
- `world::MyTickerPickerWorldModel`: An instance of the [`MyTickerPickerWorldModel`](@ref) that defines the world model parameters.
- `horizon::Int64 = 1`: The number of trials to sample. Default is 1 (single trial).

### Returns
- `Dict{Int64, Array{Beta,1}}`: A dictionary where the keys are integers (trials) and the values are arrays of Beta distributions (ticker preferences).
"""
function sample(samplingmodel::MyEpsilonSamplingBanditModel, worldmodel::MyTickerPickerWorldModel; 
    horizon::Int64 = 1)::Dict{Int64, Array{Beta,1}}

    # data from the sampling model -
    α = samplingmodel.α
    β = samplingmodel.β
    K = samplingmodel.K
    ϵ = samplingmodel.ϵ

    # data from the world model -
    risk_free_rate = worldmodel.risk_free_rate
    data = worldmodel.data
    tickers = worldmodel.tickers
    world = worldmodel.world

    # initialize -
    θ̂_vector = Array{Float64,1}(undef, K)
    time_sample_results_dict_Ts = Dict{Int64, Array{Beta,1}}();
    action_distribution = Array{Beta,1}(undef, K);

    # generate random Categorical distribution -
    parray = [1/K for _ = 1:K]
    dcat = Categorical(parray);
    
    # initialize collection of Beta distributions -
    foreach(k -> action_distribution[k] = Beta(α[k], β[k]), 1:K);
 
    # main sampling loop -
    for t ∈ 1:horizon

        # create a new parameter array -
        parameter_array = Array{Float64,2}(undef, K, 2);
        fill!(parameter_array, 0.0);

        # for each action, grab the parameters -
        # for k ∈ 1:K
            
        #     # grab the distribution for action k -
        #     d = action_distribution[k];

        #     # store the parameter array -
        #     αₖ, βₖ = params(d);
        #     parameter_array[k,1] = αₖ
        #     parameter_array[k,2] = βₖ

        #     # store -
        #     time_sample_results_dict_Ts[t] = parameter_array;
        # end

        # update the results archive -
        time_sample_results_dict_Ts[t] = deepcopy(action_distribution);

        aₜ = nothing; # default to nothing 
        if (rand() < ϵ)
            aₜ = rand(dcat); # choose a random action uniformly
        else

            # for each arm, sample from the distribution -
            foreach(k -> θ̂_vector[k] = rand(action_distribution[k]), 1:K);

            # ok: let's choose an action -
            aₜ = argmax(θ̂_vector);

            # pass that action to the world function, gives back a reward -
            rₜ = world(t, aₜ, worldmodel);

            # update the parameters -
            # first, get the old parameters -
            αₒ,βₒ = action_distribution[aₜ] |> params;

            # update the old values with the new values -
            αₜ = αₒ + rₜ
            βₜ = βₒ + (1-rₜ)

            # build new distribution -
            action_distribution[aₜ] = Beta(αₜ, βₜ);
        end
    end

    return time_sample_results_dict_Ts;
end

# function build_beta_array(parameters::Array{Float64,2})::Array{Beta,1}

#     # build an array of beta distributions -
#     (NR,_) = size(parameters);
#     beta_array = Array{Beta,1}(undef,NR)
#     for i ∈ 1:NR
        
#         # grab the parameters -
#         α = parameters[i,1];
#         β = parameters[i,2];

#         # build -
#         beta_array[i] = Beta(α, β);
#     end

#     # return -
#     return beta_array;
# end

"""
    function preference(beta::Array{Beta,1}, tickers::Array{String,1}) -> Array{Int64,1}

This function computes the preference of each action based on the mean of the Beta distribution.

### Arguments
- `beta::Array{Beta,1}`: An array of Beta distributions that represent the actions (or preferences)
- `tickers::Array{String,1}`: An array of strings that represent the tickers (or actions)

### Returns
- `Array{Int64,1}`: An array of integers that represent the preference of each action based on the mean of the Beta distribution.

"""
function preference(beta::Array{Beta,1}, tickers::Array{String,1})::Array{Int64,1}

    # sample -
    K = length(tickers);
    θ̂_vector = Array{Float64,1}(undef, K)

    # Let's compute the mean of each beta distribution -
    for k ∈ 1:K # for each action
        
        # grab -
        α,β = beta[k] |> d -> params(d);
        
        # generate a sample for this action -
        θ̂_vector[k] = (α)/(α+β);
    end

    # ok: let's choose an action -

    # return -
    return tiedrank(θ̂_vector, rev = true) .|> x -> trunc(Int64, x);
end