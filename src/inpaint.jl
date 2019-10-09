# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    InpaintAlgo

An inpainting algorithm with given parameters.
"""
abstract type InpaintAlgo end

"""
    inpaint(img, mask, algo)

Inpaint `img` on pixels marked as `true` in `mask` using
algorithm `algo`.
"""
function inpaint(img::AbstractArray{T,N}, mask::AbstractArray{Bool,N},
                 algo::InpaintAlgo) where {N,T}
  # sanity checks
  @assert size(img) == size(mask) "image and mask must have same size"

  # dispatch appropriate implementation
  inpaint_impl(img, mask, algo)
end

#------------------
# IMPLEMENTATIONS
#------------------
include("criminisi.jl")
