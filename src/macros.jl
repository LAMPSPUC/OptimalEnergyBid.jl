#
# Helper macro
# ------------

"""
@kwdef mutable structdef
This is a helper macro that automatically defines a keyword-based constructor for the type
declared in the expression `typedef`, which must be a `struct` or `mutable struct`
expression. The default argument is supplied by declaring fields of the form `field::T =
default`. If no default is provided then the default is provided by the `kwdef_val(T)`
function.
```julia
@kwdef struct Foo
a::Cint            # implied default Cint(0)
b::Cint = 1        # specified default
z::Cstring         # implied default Cstring(C_NULL)
y::Bar             # implied default Bar()
end
```
"""
macro kwdef(expr)
    @static if VERSION >= v"0.7"
        expr = macroexpand(__module__, expr) # to expand @static
    else
        expr = macroexpand(expr) # to expand @static
    end
    T = expr.args[2]
    params_ex = Expr(:parameters)
    call_ex = Expr(:call, T)
    _kwdef!(expr.args[3], params_ex, call_ex)
    quote
        Base.@__doc__($(esc(expr)))
        $(esc(Expr(:call,T,params_ex))) = $(esc(call_ex))
    end
end

# @kwdef helper function
# mutates arguments inplace
function _kwdef!(blk, params_ex, call_ex)
    for i in eachindex(blk.args)
        ei = blk.args[i]
        isa(ei, Expr) || continue
        if ei.head == :(=)
            # var::Typ = defexpr
            dec = ei.args[1]  # var::Typ
            var = dec.args[1] # var
            def = ei.args[2]  # defexpr
            push!(params_ex.args, Expr(:kw, var, def))
            push!(call_ex.args, var)
            blk.args[i] = dec
        elseif ei.head == :(::)
            dec = ei # var::Typ
            var = dec.args[1] # var
            def = :(kwdef_val($(ei.args[2])))
            push!(params_ex.args, Expr(:kw, var, def))
            push!(call_ex.args, dec.args[1])
        elseif ei.head == :block
            # can arise with use of @static inside type decl
            _kwdef!(ei, params_ex, call_ex)
        end
    end
    blk
end

"""
    kwdef_val(T)
The default value for a type for use with the `@kwdef` macro. Returns:
 - null pointer for pointer types (`Ptr{T}`, `Cstring`, `Cwstring`)
 - zero for integer types
 - no-argument constructor calls (e.g. `T()`) for all other types
"""
function kwdef_val end

kwdef_val(::Type{Ptr{T}}) where {T} = Ptr{T}(C_NULL)
kwdef_val(::Type{Cstring}) = Cstring(C_NULL)
kwdef_val(::Type{Cwstring}) = Cwstring(C_NULL)

kwdef_val(::Type{T}) where {T<:Real} = zero(T)

kwdef_val(::Type{T}) where {T} = T()
kwdef_val(::Type{IOStream}) = IOStream("tmp")
kwdef_val(::Type{T}) where {T<:Array{Array{Int32,1},1}} = [Int32[]]
kwdef_val(::Type{Array{Array{Int32,1},1}}) = [Int32[]]


kwdef_val(::Type{T}) where {T<:String} = ""
kwdef_val(::Type{T}) where {T<:Symbol} = :NULL

@static if VERSION >= v"0.7"
    kwdef_val(::Type{Array{T,N}}) where {T,N} = Array{T}(undef, zeros(Int,N)...)
else
    kwdef_val{T,N}(::Type{Array{T,N}})::Array{T,N} = Array{T}(tuple(zeros(Int,N)...))
end