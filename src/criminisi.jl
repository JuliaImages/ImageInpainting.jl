# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Criminisi(px, py)

Examplar-based inpainting based on confidence
and isophote maps. `(px, py)` is the patch size
as a tuple of integers.

## Notes

The Criminisi algorithm is defined for 2D images.

## References

Criminisi, A., Pérez, P., Toyama, K., 2004. Region Filling
and Object Removal by Examplar-based Image Inpainting.
"""
struct Criminisi <: InpaintAlgo
  px::Int
  py::Int
end

# implementation follows the notation in the paper
function inpaint_impl(img::AbstractArray{T,2}, mask::BitArray{2}, algo::Criminisi) where {T}
  # use all CPU cores in FFT
  set_num_threads(cpucores())

  # patch (or tile) size
  patchsize = algo.px, algo.py

  # rotation matrix gradient -> isophote
  # (this line makes the implementation 2D)
  R = [cos(π/2) sin(π/2)
       -sin(π/2) cos(π/2)]

  # already filled region
  ϕ = .!mask

  # initialize confidence map
  C = Float64.(ϕ)

  # pad arrays
  prepad  = @. (patchsize - 1) ÷ 2
  postpad = @. (patchsize    ) ÷ 2
  I = parent(padarray(img, Pad(:symmetric, prepad, postpad)))
  ϕ = parent(padarray(ϕ, Fill(true, prepad, postpad)))
  C = parent(padarray(C, Fill(0.0,  prepad, postpad)))

  # fix any invalid pixel value in masked region
  replace!(I, NaN => 0)

  # inpainting frontier
  δΩ = findall(dilate(ϕ) .& .!ϕ)

  while !isempty(δΩ)
    # update confidence values in frontier
    for p in δΩ
      c = selectpatch(C, patchsize, p)
      b = selectpatch(ϕ, patchsize, p)
      C[p] = sum(c[b]) / prod(patchsize)
    end

    # isophote map
    ∇I = pointgradients(I, δΩ) * R
    nϕ = pointgradients(ϕ, δΩ)
    D  = vec(abs.(sum(∇I .* nϕ, dims=2)))
    D /= maximum(D)

    # select patch in frontier
    p  = δΩ[argmax(C[δΩ].*D)]
    ψₚ = selectpatch(I, patchsize, p)
    bₚ = selectpatch(ϕ, patchsize, p)

    # compute distance to all other patches
    Δ = convdist(I, ψₚ, bₚ)

    # only consider patches in filled region
    Δ[mask] .= Inf

    # find index in padded arrays
    sub = argmin(Δ)
    q = CartesianIndex(@. sub.I + (patchsize-1)÷2)

    # select best candidate
    ψᵦ = selectpatch(I, patchsize, q)
    bᵦ = selectpatch(ϕ, patchsize, q)

    # paste patch and mark pixels as painted
    b = bᵦ .& .!bₚ
    ψₚ[b] .= ψᵦ[b]
    bₚ[b] .= true

    # update frontier
    δΩ = findall(dilate(ϕ) .& .!ϕ)
  end

  # return unpadded image
  start  = CartesianIndex(1 .+ prepad)
  finish = CartesianIndex(size(I) .- postpad)
  view(I, start:finish)
end
