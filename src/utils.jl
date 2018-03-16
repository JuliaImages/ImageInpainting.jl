# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    imfilter_cpu(img, kern)

Perform filtering on `img` with kernel `kern` using the FFT algorithm.
"""
function imfilter_cpu{T<:Real,K<:Real,N}(img::AbstractArray{T,N}, kern::AbstractArray{K,N})
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

  D = abs.(A² - 2AB + B²)

  # always return a plain simple array
  parent(D)
end

"""
    selectpatch(imgs, psize, p)

Helper function to extract a patch of size
`psize` from `imgs` centered at index `p`.
"""
function selectpatch(imgs, psize, p)
  imsize = size(imgs[1])

  # patch center
  i, j = ind2sub(imsize, p)

  # patch corners
  iₛ = i - (psize[1]-1) ÷ 2
  jₛ = j - (psize[2]-1) ÷ 2
  iₑ = i + psize[1] ÷ 2
  jₑ = j + psize[2] ÷ 2

  [view(img, iₛ:iₑ, jₛ:jₑ) for img in imgs]
end
