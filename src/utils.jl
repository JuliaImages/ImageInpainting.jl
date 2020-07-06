# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    imfilter_fft(img, kern)

Perform filtering on `img` with kernel `kern` using the FFT algorithm.
"""
imfilter_fft(img::AbstractArray{T,N}, kern::AbstractArray{K,N}) where {T<:Real,K<:Real,N} =
  imfilter(img, centered(kern), Inner(), Algorithm.FFT())

imfilter_fft(img::AbstractArray{<:AbstractGray}, kern::AbstractArray) = 
  imfilter(img, centered(Float64.(kern)), Inner(), Algorithm.FFT())


"""
    convdist(img, patch, weights)

Compute distance between all patches of `img` and a single `patch`
using `weights` for each pixel in the `patch`.
"""
function convdist(img::AbstractArray, patch::AbstractArray, weights::AbstractArray)
  wpatch = weights.*patch

  A² = imfilter_fft(img.^2, weights)
  AB = imfilter_fft(img, wpatch)
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
