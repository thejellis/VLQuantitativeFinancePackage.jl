abstract type AbstractAssetModel end
abstract type AbstractEquityPriceTreeModel <: AbstractAssetModel end
abstract type AbstractInterestRateTreeModel <: AbstractAssetModel end
abstract type AbstractContractModel <: AbstractAssetModel end
abstract type AbstractTreasuryDebtSecurity end
abstract type AbstractCompoundingModel end
abstract type AbstractStochasticChoiceProblem end
abstract type AbstractReturnModel end
abstract type AbstractProbabilityMeasure end
abstract type AbstractStochasticSolverModel end

# --- Equity models ------------------------------------------------------------------------ #
struct MyLocalExpectationRegressionModel 
    
    # parameters -
    a0::Float64
    a1::Float64
    a2::Float64

    function MyLocalExpectationRegressionModel(a0,a1,a2)
        this = new(a0,a1,a2)
    end
end

mutable struct MyCRRLatticeNodeModel

    # data -
    price::Float64
    probability::Float64
    intrinsic::Union{Nothing,Float64}
    extrinsic::Union{Nothing,Float64}

    # constructor -
    MyCRRLatticeNodeModel() = new();
end

mutable struct MyGeometricBrownianMotionEquityModel <: AbstractAssetModel

    # data -
    μ::Float64
    σ::Float64

    # constructor -
    MyGeometricBrownianMotionEquityModel() = new()
end

mutable struct MyMultipleAssetGeometricBrownianMotionEquityModel <: AbstractAssetModel

    # data -
    μ::Array{Float64,1}
    A::Array{Float64,2}

    # constructor -
    MyMultipleAssetGeometricBrownianMotionEquityModel() = new()
end

mutable struct MyAdjacencyBasedCRREquityPriceTree <: AbstractEquityPriceTreeModel

    # data -
    μ::Float64
    σ::Float64
    T::Float64

    # we compute these values -
    ΔT::Union{Nothing,Float64}
    u::Union{Nothing,Float64}
    d::Union{Nothing,Float64}
    p::Union{Nothing,Float64}
    data::Union{Nothing, Dict{Int, MyCRRLatticeNodeModel}}
    connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}
    levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}
   
    # constructor 
    MyAdjacencyBasedCRREquityPriceTree() = new()
end

mutable struct MyLongstaffSchwartzContractPricingModel <: AbstractEquityPriceTreeModel

    # data -
    S::Array{Float64,2}
    r̄::Float64
    Δt::Float64

    # constructor -
    MyLongstaffSchwartzContractPricingModel() = new();
end

mutable struct MyBlackScholesContractPricingModel <: AbstractAssetModel

    # data -
    r::Float64
    Sₒ::Float64

    # constructor -
    MyBlackScholesContractPricingModel() = new();
end

"""
    mutable struct MyOrnsteinUhlenbeckModel <: AbstractAssetModel

A mutable struct that represents a [Ornstein-Uhlenbeck process](https://en.wikipedia.org/wiki/Ornstein–Uhlenbeck_process).
An instance of `MyOrnsteinUhlenbeckModel` is configured and constructed using a corresponding `build` method.

### Fields
- `μ::Function`: The price drift function (long term price level)
- `σ::Function`: The price volatility function
- `θ::Function`: The mean reversion function. This function determines how quickly the price reverts to the long-term mean.
"""
mutable struct MyOrnsteinUhlenbeckModel <: AbstractAssetModel
    
    # data -
    μ::Function
    σ::Function
    θ::Function

    # constructor -
    MyOrnsteinUhlenbeckModel() = new();
end


"""
    mutable struct MyHestonModel <: AbstractAssetModel

A mutable struct that represents the [Heston model](https://en.wikipedia.org/wiki/Heston_model). 
An instance of `MyHestonModel` is configured and constructed using a corresponding `build` method.

### Fields
- `μ::Function`: Drift function takes the state matrix `X` and time `t` and returns a scalar, i.e., `\\mu:X\\times{t}\\rightarrow\\mathbb{R}`
- `κ::Function`: Mean reversion function
- `θ::Function`: Long-run volatility function
- `ξ::Function`: Volatility of volatility function
- `Σ::Array{Float64,2}`: Covariance matrix between the asset price and the volatility process
"""
mutable struct MyHestonModel <: AbstractAssetModel
    
    # data -
    μ::Function
    κ::Function
    θ::Function
    ξ::Function
    Σ::Array{Float64,2}

    # constructor -
    MyHestonModel() = new();
end

"""
    mutable struct MySisoLegSHippoModel <: AbstractAssetModel

A mutable struct that represents a single-input, single-output (SISO) linear time-invariant (LTI) system
that used the Leg-S parameterization. An instance of `MySisoLegSHippoModel` is configuired and constructed using
a corresponding `build` method.

### Fields
- `Â::Array{Float64,2}`: Discretized state matrix of the system `Â ∈ ℝ^(n x n)` where `n` is the number of hidden states
- `B̂::Array{Float64,1}`: Discretized input matrix of the system `B̂ ∈ ℝ^n x 1`
- `Ĉ::Array{Float64,1}`: Discretized output matrix of the system `Ĉ ∈ ℝ^1 x n`
- `D̂::Array{Float64,1}`: Discretized feedforward matrix of the system `D̂ ∈ ℝ^1 x 1`
- `n::Int`: Number of hidden states in the system
- `Xₒ::Array{Float64,1}`: Initial conditions of the system
"""
mutable struct MySisoLegSHippoModel <: AbstractAssetModel

    # data -
    Â::Array{Float64,2}
    B̂::Array{Float64,1}
    Ĉ::Array{Float64,1}
    D̂::Array{Float64,1}
    n::Int
    Xₒ::Array{Float64,1}

    # constructor -
    MySisoLegSHippoModel() = new();
end

# tagging type -
"""
    struct EulerMaruyamaMethod <: AbstractStochasticSolverModel

Immutable type that represents the [Euler-Maruyama method](https://en.wikipedia.org/wiki/Euler–Maruyama_method) for solving stochastic differential equations.
This type is passed to various functions in their `method` argument to indicate that the [Euler-Maruyama method](https://en.wikipedia.org/wiki/Euler–Maruyama_method) 
should be used in calculations.
"""
struct EulerMaruyamaMethod <: AbstractStochasticSolverModel
end
# ------------------------------------------------------------------------------------------- #

# --- Contract models ----------------------------------------------------------------------- #
mutable struct MyEuropeanCallContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyEuropeanCallContractModel() = new()
end

mutable struct MyEuropeanPutContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyEuropeanPutContractModel() = new()
end

mutable struct MyAmericanCallContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyAmericanCallContractModel() = new()
end

mutable struct MyAmericanPutContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyAmericanPutContractModel() = new()
end

mutable struct MyEquityModel <: AbstractAssetModel

    # data -
    ticker::String
    purchase_price::Float64
    current_price::Float64
    direction::Int64
    number_of_shares::Int64

    # constructor -
    MyEquityModel() = new()
end

mutable struct MySingleIndexModel <: AbstractReturnModel

    # model -
    α::Float64          # firm specific unexplained return
    β::Float64          # relationship between the firm and the market
    r::Float64          # risk free rate of return 
    ϵ::Distribution     # random shocks 

    # constructor -
    MySingleIndexModel() = new()
end
# -------------------------------------------------------------------------------------------- #

# --- Term structure of interest rates and fixed income types -------------------------------- #

"""
    mutable struct MyUSTreasuryZeroCouponBondModel <: AbstractTreasuryDebtSecurity

A mutable struct that represents a [U.S. Treasury zero coupon security](https://www.treasurydirect.gov/marketable-securities/treasury-bills/). 

### Fields
- `par::Float64`: The face or par value of the bond
- `rate::Union{Nothing, Float64}`: Effective annual interest rate (discount rate specified as a decimal)
- `T::Union{Nothing,Float64}`: Duration in years of the instrument, measured as a 365 day or a 52 week year
- `n::Int`: Number of compounding periods per year (typically 2)
- `price::Union{Nothing, Float64}`: Price of the bond or note (computed property)
- `cashflow::Union{Nothing, Dict{Int,Float64}}`: Cashflow dictionary (computed property) where the `key` is the period and the `value` is the discounted cashflow in a period
- `discount::Union{Nothing, Dict{Int,Float64}}`: Discount factor dictionary (computed property) where the `key` is the period and the `value` is the discount factor in that period
"""
mutable struct MyUSTreasuryZeroCouponBondModel <: AbstractTreasuryDebtSecurity
    
    # data -
    par::Float64                                    # Par value of the bill
    rate::Union{Nothing, Float64}                   # Annual interest rate
    T::Union{Nothing,Float64}                       # Duration in years, measured as a 365 day or a 52 week year
    price::Union{Nothing, Float64}                  # Price of the bond or note
    n::Int                                          # Number of compounding periods per year (typically 2)
    cashflow::Union{Nothing, Dict{Int,Float64}}     # Cashflow
    discount::Union{Nothing, Dict{Int,Float64}}     # discount factors
    
    # constructor -
    MyUSTreasuryZeroCouponBondModel() = new()
end

"""
    mutable struct MyUSTreasuryCouponSecurityModel <: AbstractTreasuryDebtSecurity

A mutable struct that represents a [U.S. Treasury coupon bond](https://www.treasurydirect.gov/marketable-securities/treasury-bonds/). 
This type of security (note or bond) pays the holder of the instrument a fixed interest rate at regular intervals over the life of the security.

### Fields
- `par::Float64`: Par value of the bond
- `rate::Union{Nothing, Float64}`: Annualized effective discount rate
- `coupon::Union{Nothing, Float64}`: Coupon interest rate
- `T::Union{Nothing,Float64}`: Duration in years of the note or bond, measured as a 365 day or a 52 week year
- `λ::Int`: Number of coupon payments per year (typically 2)
- `price::Union{Nothing, Float64}`: Price of the bond or note
- `cashflow::Union{Nothing, Dict{Int,Float64}}`: Cashflow dictionary (computed property) where the `key` is the period and the `value` is the discounted cashflow in a period
- `discount::Union{Nothing, Dict{Int,Float64}}`: Discount factor dictionary(computed property) where the `key` is the period and the `value` is the discount factor in that period
"""
mutable struct MyUSTreasuryCouponSecurityModel <: AbstractTreasuryDebtSecurity

    # data -
    par::Float64                                    # Par value of the bill
    rate::Union{Nothing, Float64}                   # Annualized effective interest rate
    coupon::Union{Nothing, Float64}                 # Coupon rate
    T::Union{Nothing,Float64}                       # Duration in years, measured as a 365 day or a 52 week year
    λ::Int                                          # Number of coupon payments per year (typcially 2)
    price::Union{Nothing, Float64}                  # Price of the bond or note
    cashflow::Union{Nothing, Dict{Int,Float64}}     # Cashflow
    discount::Union{Nothing, Dict{Int,Float64}}     # discount factors

    # consturctor -
    MyUSTreasuryCouponSecurityModel() = new();
end

"""
    struct DiscreteCompoundingModel <: AbstractCompoundingModel

Immutable type that represents discrete compounding.
This type has no fields and is passed as an argument to various functions to indicate that discrete compounding should be used in calculations.
"""
struct DiscreteCompoundingModel <: AbstractCompoundingModel 
    DiscreteCompoundingModel() = new()
end

"""
    struct ContinuousCompoundingModel <: AbstractCompoundingModel
        
Immutable type that represents continuous compounding. 
This type has no fields and is passed as an argument to various functions to indicate that continuous compounding should be used in calculations.
"""
struct ContinuousCompoundingModel <: AbstractCompoundingModel 
    ContinuousCompoundingModel() = new()
end

struct RealWorldBinomialProbabilityMeasure <: AbstractProbabilityMeasure
    RealWorldBinomialProbabilityMeasure() = new()
end

struct RiskNeutralBinomialProbabilityMeasure <: AbstractProbabilityMeasure
    RiskNeutralBinomialProbabilityMeasure() = new()
end

# nodes
mutable struct MyBinaryInterestRateLatticeNodeModel

    # data -
    probability::Float64
    rate::Float64
    price::Float64

    # constructor -
    MyBinaryInterestRateLatticeNodeModel() = new();
end

# tree
mutable struct MySymmetricBinaryInterestRateLatticeModel <: AbstractInterestRateTreeModel
    
    # data -
    u::Float64      # up-factor
    d::Float64      # down-factor
    p::Float64      # probability of an up move
    rₒ::Float64     # root value
    T::Int64        # number of levels in the tree (zero based)
    
    connectivity::Union{Nothing,Dict{Int64, Array{Int64,1}}}    # holds the connectivity of the tree
    levels::Union{Nothing,Dict{Int64,Array{Int64,1}}} # nodes on each level of the tree
    data::Union{Nothing, Dict{Int64, MyBinaryInterestRateLatticeNodeModel}} # holds data in the tree

    # constructor -
    MySymmetricBinaryInterestRateLatticeModel() = new()
end

mutable struct MyMarkowitzRiskyAssetOnlyPortfiolioChoiceProblem <: AbstractStochasticChoiceProblem

    # data -
    Σ::Array{Float64,2}
    μ::Array{Float64,1}
    bounds::Array{Float64,2}
    R::Float64
    initial::Array{Float64,1}

    # constructor
    MyMarkowitzRiskyAssetOnlyPortfiolioChoiceProblem() = new();
end

mutable struct MyMarkowitzRiskyRiskFreePortfiolioChoiceProblem <: AbstractStochasticChoiceProblem

    # data -
    Σ::Array{Float64,2}
    μ::Array{Float64,1}
    bounds::Array{Float64,2}
    R::Float64
    initial::Array{Float64,1}
    risk_free_rate::Float64

    # constructor -
    MyMarkowitzRiskyRiskFreePortfiolioChoiceProblem() = new();
end

# Lattice model -
mutable struct MyBiomialLatticeEquityNodeModel

    # data -
    price::Float64
    probability::Float64
    intrinsic::Union{Nothing,Float64} # these are needed *only* for option pricing
    extrinsic::Union{Nothing,Float64} # these are needed *only* for option pricing

    # constructor -
    MyBiomialLatticeEquityNodeModel() = new();
end

# """
# MyBinomialEquityPriceTree
# """
mutable struct MyBinomialEquityPriceTree <: AbstractEquityPriceTreeModel

    # data -
    u::Float64
    d::Float64
    p::Float64
    μ::Union{Nothing,Float64} # this is needed *only* for option pricing
    T::Union{Nothing,Float64}

    # we compute these values -
    connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}
    levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}
    ΔT::Union{Nothing,Float64}
    data::Union{Nothing, Dict{Int64, MyBiomialLatticeEquityNodeModel}} # holds data in the tree
    
    # constructor 
    MyBinomialEquityPriceTree() = new()
end
# -------------------------------------------------------------------------------------------- #