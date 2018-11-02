struct StackedDict{T,S} <: AbstractDict{T,S}
    keys::Vector{T}
    vals::Vector{S}

    function StackedDict{T,S}(pairs::Pair{<:T,<:S}...) where {T,S}
        keys = Vector{T}(undef, length(pairs))
        vals = Vector{S}(undef, length(pairs))
        for i in eachindex(pairs)
            keys[i] = first(pairs[i])
            vals[i] = last(pairs[i])
        end
        return new{T,S}(keys, vals)
    end
end
StackedDict(pairs::Pair{T,S}...) where {T,S} = StackedDict{T,S}(pairs...)

Base.length(d::StackedDict) = length(d.keys)
Base.iterate(d::StackedDict) = iterate(zip(d.keys, d.vals))
Base.iterate(d::StackedDict, x) = iterate(zip(d.keys, d.vals), x)

struct __Sentinel__ end

function Base.getindex(d::StackedDict, key)
    val = get(d, key, __Sentinel__)
    if val === __Sentinel__
        throw(KeyError(key))
    else
        return val
    end
end

function Base.get(d::StackedDict, key, default)
    idx = findlast(isequal(key), d.keys)
    idx === nothing && return default
    return d.keys[idx]
end

function Base.push!(d::StackedDict{T,S}, pair::Pair{<:T,<:S}) where {T,S}
    push!(d.keys, first(pair))
    push!(d.vals, last(pair))
    return d
end

function Base.pop!(d::StackedDict{T,S}, key::T) where {T,S}
    idx = findlast(isequal(key), d.keys)
    idx === nothing && throw(KeyError(key))
    val = d.vals[idx]
    deleteat!(d.keys, idx)
    deleteat!(d.vals, idx)
    return val
end

function Base.pop!(d::StackedDict{T,S}, pair::Pair{<:T,<:S}) where {T,S}
    idx = findlast(x -> isequal(pair[1], x[1]) && isequal(pair[2], x[2]), collect(zip(d.keys, d.vals)))
    idx === nothing && throw(KeyError(pair))
    deleteat!(d.keys, idx)
    deleteat!(d.vals, idx)
    return pair[2]
end

function popall!(d::StackedDict{T,S}, key::T) where {T,S}
    indices = findall(isequal(key), d.keys)
    deleteat!(d.keys, indices)
    deleteat!(d.vals, indices)
    return d
end

function Base.empty!(d::StackedDict)
    Base.empty!(d.keys)
    Base.empty!(d.vals)
    return d
end
