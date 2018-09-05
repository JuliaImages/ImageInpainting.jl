# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Crimisini(tilesize)

Examplar-based inpainting based on confidence
and isophote maps. `tilesize` is the patch size
as a tuple of integers.

## References

Crimisini, A., Pérez, P., Toyama, K., 2004. Region Filling
and Object Removal by Examplar-based Image Inpainting.
"""
struct Crimisini{N} <: InpaintAlgo
  tilesize::Dims{N} # patch size
end

Crimisini(tilesize::Vararg{Int,N}) where {N} = Crimisini{N}(tilesize)

# implementation follows the notation in the paper
function inpaint_impl(img::AbstractArray{T,N}, mask::BitArray{N}, algo::Crimisini{N}) where {T,N}
  # use all CPU cores in FFT
  set_num_threads(cpucores())

  # patch (or tile) size
  tilesize = algo.tilesize

  # already filled region
  ϕ = .!mask

  # initialize confidence map
  C = Float64.(ϕ)

  # pad arrays
  prepad  = [(tilesize[i]-1) ÷ 2 for i=1:N]
  postpad = [(tilesize[i])   ÷ 2 for i=1:N]
  padimg = parent(padarray(img, Pad(:symmetric, prepad, postpad)))
  ϕ = parent(padarray(ϕ, Fill(true, prepad, postpad)))
  C = parent(padarray(C, Fill(0.0,  prepad, postpad)))

  # fix any invalid pixel value (e.g. NaN) inside of the mask
  padimg[isnan.(padimg)] .= zero(T)

  # inpainting frontier
  δΩ = findall(dilate(ϕ) .& .!ϕ)

  while !isempty(δΩ)
    # update confidence values in frontier
    for p in δΩ
      c, b = selectpatch((C, ϕ), tilesize, p)
      C[p] = sum(c[b]) / prod(tilesize)
    end

    # isophote map
    grads = pointgradients(padimg, δΩ)
    direc = pointgradients(ϕ, δΩ)
    D = vec(abs.(sum(grads.*direc, dims=2)))
    D /= maximum(D)

    # select patch in frontier
    idx = argmax(C[δΩ].*D)
    p = δΩ[idx]
    ψₚ, bₚ = selectpatch((padimg, ϕ), tilesize, p)

    # compute distance to all other patches
    Δ = convdist(padimg, ψₚ, weights=bₚ)

    # only consider patches in filled region
    Δ[mask] .= Inf

    # find index in padded arrays
    sub = argmin(Δ)
    q = ntuple(i -> sub[i] + (tilesize[i]-1)÷2, N)

    # select best candidate
    ψᵦ, bᵦ = selectpatch((padimg, ϕ), tilesize, q)

    # paste patch and mark pixels as painted
    b = bᵦ .& .!bₚ
    ψₚ[b] .= ψᵦ[b]
    bₚ[b] .= true

    # update frontier
    δΩ = findall(dilate(ϕ) .& .!ϕ)
  end

  view(padimg, [1+prepad[i]:size(padimg,i)-postpad[i] for i=1:N]...)
end
