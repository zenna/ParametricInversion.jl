module Util

export cattype

cattype(::Type{F}, ::Type{Tuple{T1}}) where {F, T1} = Tuple{F, T1}
cattype(::Type{F}, ::Type{Tuple{T1, T2}}) where {F, T1, T2} = Tuple{F, T1, T2}
cattype(::Type{F}, ::Type{Tuple{T1, T2, T3}}) where {F, T1, T2, T3} = Tuple{F, T1, T2, T3}
cattype(::Type{F}, ::Type{Tuple{T1, T2, T3, T4}}) where {F, T1, T2, T3, T4} = Tuple{F, T1, T2, T3, T4}
# cattype(::Type{F}, ::Type{NTuple{N, T}}) where {F, N, T} = Tuple{F, T1, T2, T3}

end