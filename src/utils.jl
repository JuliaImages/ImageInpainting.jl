# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    convdist(img, patch, weights)

Compute distance between all patches of `img` and a single `patch`
using `weights` for each pixel in the `patch`.
"""
function convdist(img::AbstractArray, patch::AbstractArray, weights::AbstractArray)
  wpatch = weights.*patch

  A² = imfilter(img.^2, centered(weights), Inner())
  AB = imfilter(img, centered(wpatch), Inner())
  B² = sum(wpatch .* patch)

  abs.(A² .- 2AB .+ B²)
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
