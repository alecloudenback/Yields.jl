# NS and NSS
## Originally developed by leeyuntien <leeyuntien@gmail.com>

"""
    NelsonSiegel(rates::AbstractVector, maturities::AbstractVector; τ_initial=1.0)

Return the NelsonSiegel fitted parameters. The rates should be zero spot rates. If `rates` are not `Rate`s, then they will be interpreted as `Continuous` `Rate`s.

    NelsonSiegel(β₀, β₁, β₂, τ₁)

Parameters of Nelson and Siegel (1987) parametric model:

- β₀ represents a long-term interest rate
- β₁ represents a time-decay component
- β₂ represents a hump
- τ₁ controls the location of the hump

# Examples

```julia-repl
julia> β₀, β₁, β₂, τ₁ = 0.6, -1.2, -1.9, 3.0
julia> nsm = Yields.NelsonSiegel.(β₀, β₁, β₂, τ₁)

# Extend Help

## References
- https://onriskandreturn.com/2019/12/01/nelson-siegel-yield-curve-model/
- https://www.bis.org/publ/bppdf/bispap25.pdf

```
"""
struct NelsonSiegel{T} <: AbstractYieldModel
    τ₁::T
    β₀::T
    β₁::T
    β₂::T

    function NelsonSiegel(τ₁::T, β₀::T, β₁::T, β₂::T) where {T<:Real}
        (τ₁ <= 0) && throw(DomainError("Wrong tau parameter ranges (must be positive)"))
        return new{T}(τ₁, β₀, β₁, β₂)
    end
end

function NelsonSiegel(τ₁=1.0)
    return NelsonSiegel(τ₁, 1.0, 0.0, 0.0)
end

function Base.zero(ns::NelsonSiegel, t)
    if iszero(t)
        # zero rate is undefined for t = 0
        t += eps()
    end
    Continuous.(ns.β₀ .+ ns.β₁ .* (1.0 .- exp.(-t ./ ns.τ₁)) ./ (t ./ ns.τ₁) .+ ns.β₂ .* ((1.0 .- exp.(-t ./ ns.τ₁)) ./ (t ./ ns.τ₁) .- exp.(-t ./ ns.τ₁)))
end
FinanceCore.discount(ns::NelsonSiegel, t) = discount.(zero.(ns, t), t)

"""
    NelsonSiegelSvensson(τ₁, τ₂, β₀, β₁, β₂, β₃)
    NelsonSiegelSvensson(τ₁=1.0, τ₂=1.0)

Return the NelsonSiegelSvensson yield curve. The rates should be continuous zero spot rates. If `rates` are not `Rate`s, then they will be interpreted as `Continuous` `Rate`s.

Parameters of Svensson (1994) parametric model:

- τ₁ controls the location of the hump 
- τ₁ controls the location of the second hump 
- β₀ represents a long-term interest rate
- β₁ represents a time-decay component
- β₂ represents a hump
- β₃ represents a second hum

# Examples

```julia-repl
julia> β₀, β₁, β₂, β₃, τ₁, τ₂ = 0.6, -1.2, -2.1, 3.0, 1.5
julia> nssm = NelsonSiegelSvensson.NelsonSiegelSvensson.(β₀, β₁, β₂, β₃, τ₁, τ₂)

## References
- https://onriskandreturn.com/2019/12/01/nelson-siegel-yield-curve-model/
- https://www.bis.org/publ/bppdf/bispap25.pdf

```
"""
struct NelsonSiegelSvensson{T} <: AbstractYieldModel
    τ₁::T
    τ₂::T
    β₀::T
    β₁::T
    β₂::T
    β₃::T

    function NelsonSiegelSvensson(τ₁::T, τ₂::T, β₀::T, β₁::T, β₂::T, β₃::T) where {T<:Real}
        (τ₁ <= 0 || τ₂ <= 0) && throw(DomainError("Wrong tau parameter ranges (must be positive)"))
        return new{T}(τ₁, τ₂, β₀, β₁, β₂, β₃)
    end
end

NelsonSiegelSvensson(τ₁=1.0, τ₂=1.0) = NelsonSiegelSvensson(τ₁, τ₂, 0.0, 0.0, 0.0, 0.0)

function Base.zero(nss::NelsonSiegelSvensson, t)
    if iszero(t)
        # zero rate is undefined for t = 0
        t += eps()
    end
    Continuous.(nss.β₀ .+ nss.β₁ .* (1.0 .- exp.(-t ./ nss.τ₁)) ./ (t ./ nss.τ₁) .+ nss.β₂ .* ((1.0 .- exp.(-t ./ nss.τ₁)) ./ (t ./ nss.τ₁) .- exp.(-t ./ nss.τ₁)) .+ nss.β₃ .* ((1.0 .- exp.(-t ./ nss.τ₂)) ./ (t ./ nss.τ₂) .- exp.(-t ./ nss.τ₂)))
end
FinanceCore.discount(nss::NelsonSiegelSvensson, t) = discount.(zero.(nss, t), t)