# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    imfilter_cpu(img, kern)

Perform filtering on `img` with kernel `kern` using the FFT algorithm.
"""
imfilter_cpu(img::AbstractArray{T,N}, kern::AbstractArray{K,N}) where {T<:Real,K<:Real,N} =
  imfilter(img, centered(kern), Inner(), Algorithm.FFT())

"""
    convdist(img, patch, weights)

Compute distance between all patches of `img` and a single `patch`
using `weights` for each pixel in the `patch`.
"""
function convdist(img::AbstractArray, patch::AbstractArray, weights::AbstractArray)
  wpatch = weights.*patch

  A² = imfilter_cpu(img.^2, weights)
  AB = imfilter_cpu(img, wpatch)
  B² = sum(abs2, wpatch)

  D = abs.(A² .- 2AB .+ B²)

  parent(D)
end

"""
    selectpatch(img, patchsize, center)

Helper function to extract a patch of size
`patchsize` from `img` centered at Cartesian
index `center`.
"""
function selectpatch(img, patchsize, center)
  start  = CartesianIndex(@. center.I - (patchsize-1)÷2)
  finish = CartesianIndex(@. center.I + (patchsize  )÷2)
  view(img, start:finish)
end
