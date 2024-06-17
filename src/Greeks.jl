# == THETA ========================================================================================================================================= #
function theta(contracts::Array{Y,1}; h::Int64=2, T::Float64=(1 / 365),
    σ::Float64=0.15, Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Array{Float64,1} where {Y<:AbstractContractModel}

    # value array -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = theta(contract; Sₒ=Sₒ, h=h, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function theta(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Float64 where {Y<:AbstractContractModel}

    # θ : 1 day diff 
    Tₒ = T
    T₁ = Tₒ - (1 / 365)

    # build a binary tree with N levels -
    # mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, h=h, σ=σ, T=Tₒ, μ=μ)
    # m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, h=h, σ=σ, T=T₁, μ=μ)

    mₒ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ, T = Tₒ, σ = σ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    m₁ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ, T = T₁, σ = σ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    θ_value = (P₁ - Pₒ)

    # return the value -
    return θ_value
end
# ================================================================================================================================================== #

# == DELTA ========================================================================================================================================= #
function delta(contracts::Array{Y,1}; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Array{Float64,1} where {Y<:AbstractContractModel}

    # value array -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = delta(contract; Sₒ=Sₒ, h=h, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

"""
    delta(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
        Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Float64 where {Y<:AbstractContractModel}

Compute the `delta` of a contract using the [Cox-Ross-Rubinstein binomial tree method](https://en.wikipedia.org/wiki/Binomial_options_pricing_model).
Delta measures the change in the options premium for a `1 USD` change in the underlying price:

```math
\\Delta = \\frac{\\partial\\mathcal{P}}{\\partial{S}}
```

### Arguments
- `contract::Y`: The contract model for which we compute the delta where `Y` is a subtype of `AbstractContractModel`.
- `h::Int64=2`: The number of levels in the binomial tree.
- `T::Float64 = (1 / 365)`: The time to maturity for the options contract measured in years, assume a 365-day year.
- `σ::Float64 = 0.15`: The implied volatility (IV) for the options contract
- `Sₒ::Float64 = 1.0`: Initial share price of the underlying at the time contract was purchased
- `μ::Float64 = 0.0015`: Single-step growth rate. Equals the risk-free rate for risk-neutral options evaluation

### Return
- `Δ::Float64`: The delta value for this option contract

### See also:
- [What is Delta?](https://www.investopedia.com/terms/d/delta.asp)|
"""
function delta(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Float64 where {Y<:AbstractContractModel}

    # advance base price by 1 -
    S₁ = Sₒ + 1

    mₒ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ, T = T, σ = σ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    m₁ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ, T = T, σ = σ)) |> (x-> populate(x, Sₒ = S₁, h = h));

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    δ_value = (P₁ - Pₒ)

    # return the value -
    return δ_value
end
# ================================================================================================================================================== #

# == GAMMA ========================================================================================================================================= #
"""
    gamma(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
        Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}
"""
function gamma(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # advance base price by 1 -
    S₁ = Sₒ + 1

    # compute -
    δₒ = delta(contract; h=h, T=T, σ=σ, Sₒ=Sₒ, μ=μ, choice=choice)
    δ₁ = delta(contract; h=h, T=T, σ=σ, Sₒ=S₁, μ=μ, choice=choice)

    # compute γ -
    γ_value = (δ₁ - δₒ)

    # return -
    return γ_value
end

function gamma(contracts::Array{Y,1}; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = gamma(contract; Sₒ=Sₒ, h=h, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end
# ================================================================================================================================================== #

# == VEGA ========================================================================================================================================== #
function vega(contracts::Array{Y,1}; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = vega(contract; Sₒ=Sₒ, h=h, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function vega(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # setup the calculation -
    σₒ = σ
    σ₁ = σ + 0.01;

    # build models -
    # mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σₒ, T=T, μ=μ)
    # m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ₁, T=T, μ=μ)

    mₒ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ, T = T, σ = σₒ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    m₁ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ, T = T, σ = σ₁)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    vega_value = (P₁ - Pₒ)

    # return the value -
    return vega_value
end
# ================================================================================================================================================== #

# == RHO =========================================================================================================================================== #
function rho(contract::Y; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # setup mu -
    μₒ = μ
    μ₁ = μ + 0.01

    # build models -
    # mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μₒ)
    # m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ₁)

    mₒ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μₒ, T = T, σ = σ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    m₁ = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = μ₁, T = T, σ = σ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    ρ_value = (P₁ - Pₒ)

    # return the value -
    return ρ_value
end

function rho(contracts::Array{Y,1}; h::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = rho(contract; Sₒ=Sₒ, h=h, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end
# ================================================================================================================================================== #