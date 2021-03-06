##################################################
# Base
##################################################

for op in (:+, :-, :*, :&, :|, :!,
           :length, :size,
           :abs, :abs2, :complex, :conj, :exp, :imag, :inv,
           :log, :one, :oneunit, :real, :sqrt, :transpose, :zero,
           :cos, :sin, :tan, :sec, :csc, :cot,
           :acos, :asin, :atan, :asec, :acsc, :acot,
           :cosh, :sinh, :tanh, :sech, :csch, :coth,
           :acosh, :asinh, :atanh, :asech, :acsch, :acoth,
           :iseven, :isinf, :isnan, :isodd)
    @eval @register $(:(Base.$op)) 1
end
Base.adjoint(x::Sym) = combine(Symbol("'"), x)
Base.zero(::Type{Sym{TAG}}) where TAG = apply(zero, Sym(TAG))
Base.one(::Type{Sym{TAG}}) where TAG = apply(one, Sym(TAG))
Base.oneunit(::Type{Sym{TAG}}) where TAG = apply(oneunit, Sym(TAG))

# Two-arg operators
for op in (:-, :/, :\, ://, :^, :÷, :isless, :<, :&, :|, :(==))
    @eval @register $(:(Base.$op)) 2
end
Base.getindex(x::Sym, val::Symbol) = Base.getindex(promote(x, QuoteNode(val))...)
Base.getindex(x::Sym, vals...) = Base.getindex(promote(x, map(val -> val isa Symbol ? QuoteNode(val) : val, vals)...)...)
Base.getindex(x::Sym, val::Sym) = combine(:ref, x, val)
Base.getindex(x::Sym, vals::Sym...) = combine(:ref, x, vals...)

Base.getproperty(x::Sym, val::Symbol) = Base.getproperty(promote(x, QuoteNode(val))...)
Base.getproperty(x::Sym, val::Sym{Symbol}) = combine(:(.), x, val)

Base.in(x::Sym, y::Sym) = apply(in, x, y)

@register Base.:(:) --> Sym(:(:)) 2
@register Base.:(:) --> Sym(:(:)) 3

# Multi-arg operators
for op in (:+, :*)
    @eval @register $(:(Base.$op)) 2
    @eval $(:(Base.$op))(xs::Sym...) = apply($(:(Base.$op)), xs...)
end

##################################################
# Linear algebra
##################################################

# One-arg operators
for op in (:norm,)
    @eval @register $(:(LinearAlgebra.$op)) 1
end

# Two-arg operators
for op in (:dot, :cross)
    @eval @register $(:(LinearAlgebra.$op)) 2
end
