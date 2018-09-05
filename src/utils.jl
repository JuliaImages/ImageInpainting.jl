# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    imfilter_cpu(img, kern)

Perform filtering on `img` with kernel `kern` using the FFT algorithm.
"""
function imfilter_cpu(img::AbstractArray{T,N}, kern::AbstractArray{K,N}) where {T<:Real,K<:Real,N}
  imfilter(img, centered(kern), Inner(), Algorithm.FFT())
end

"""
    convdist(img, kern; [weights])

Compute distance between all subimages of `img` and `kern`.
Optionally, activate/deactivate pixels in the kern using `weights`.
"""
function convdist(img::AbstractArray, kern::AbstractArray; weights=nothing)
  # default to uniform weights
  weights == nothing && (weights = ones(kern))

  wkern = weights.*kern

  A² = imfilter_cpu(img.^2, weights)
  AB = imfilter_cpu(img, wkern)
  B² = sum(abs2, wkern)

  D = abs.(A² .- 2AB .+ B²)

  # always return a plain simple array
  parent(D)
end

"""
    selectpatch(imgs, tilesize, center)

Helper function to extract a patch of size
`tilesize` from `imgs` centered at Cartesian
index `center`.
"""
function selectpatch(imgs, tilesize, center)
  N = length(tilesize)

  # patch corners
  start  = ntuple(i -> center[i] - (tilesize[i]-1) ÷ 2, N)
  finish = ntuple(i -> center[i] +     tilesize[i] ÷ 2, N)

  [view(img, [start[i]:finish[i] for i=1:N]...) for img in imgs]
end
