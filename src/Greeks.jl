# == THETA ========================================================================================================================================= #
function theta(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365),
    σ::Float64=0.15, Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Array{Float64,1} where {Y<:AbstractContractModel}

    # value array -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = theta(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function theta(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Float64 where {Y<:AbstractContractModel}

    # θ : 1 day diff 
    Tₒ = T
    T₁ = Tₒ - (1 / 365)

    # build a binary tree with N levels -
    mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=Tₒ, μ=μ)
    m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T₁, μ=μ)

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
function delta(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Array{Float64,1} where {Y<:AbstractContractModel}

    # value array -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = delta(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function delta(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational)::Float64 where {Y<:AbstractContractModel}

    # advance base price by 1 -
    S₁ = Sₒ + 1

    # build models -
    mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ)
    m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=S₁, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ)

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
function gamma(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # advance base price by 1 -
    S₁ = Sₒ + 1

    # compute -
    δₒ = delta(contract; number_of_levels=number_of_levels, T=T, σ=σ, Sₒ=Sₒ, μ=μ, choice=choice)
    δ₁ = delta(contract; number_of_levels=number_of_levels, T=T, σ=σ, Sₒ=S₁, μ=μ, choice=choice)

    # compute γ -
    γ_value = (δ₁ - δₒ)

    # return -
    return γ_value
end

function gamma(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = gamma(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end
# ================================================================================================================================================== #

# == VEGA ========================================================================================================================================== #
function vega(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = vega(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end

function vega(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # setup the calculation -
    σₒ = σ
    σ₁ = σ + 0.01

    # build models -
    mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σₒ, T=T, μ=μ)
    m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ₁, T=T, μ=μ)

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
function rho(contract::Y; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # setup mu -
    μₒ = μ
    μ₁ = μ + 0.001

    # build models -
    mₒ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μₒ)
    m₁ = build(MyAdjacencyBasedCRREquityPriceTree; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ₁)

    # compute -
    Pₒ = premium(contract, mₒ; choice=choice)
    P₁ = premium(contract, m₁; choice=choice)

    # compute theta -
    ρ_value = (P₁ - Pₒ)

    # return the value -
    return ρ_value
end

function rho(contracts::Array{Y,1}; number_of_levels::Int64=2, T::Float64=(1 / 365), σ::Float64=0.15,
    Sₒ::Float64=1.0, μ::Float64=0.0015, choice::Function=_rational) where {Y<:AbstractContractModel}

    # initialize -
    value_array = Array{Float64,1}()

    # compute -
    for contract ∈ contracts
        value = rho(contract; Sₒ=Sₒ, number_of_levels=number_of_levels, σ=σ, T=T, μ=μ, choice=choice)
        push!(value_array, value)
    end

    # return -
    return value_array
end
# ================================================================================================================================================== #