# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Crimisini(psize)

Examplar-based inpainting based on confidence
and isophote maps. `psize` is the patch size
as a tuple of integers.

## References

Crimisini, A., Pérez, P., Toyama, K., 2004. Region Filling
and Object Removal by Examplar-based Image Inpainting.
"""
struct Crimisini <: InpaintAlgo
  psize::Tuple # patch size
end

function inpaint_impl(img::AbstractArray, mask::BitArray, algo::Crimisini)
  # patch size
  psize = algo.psize

  # already filled region
  ϕ = .!mask

  # initialize confidence map
  C = Float64.(ϕ)

  # pad arrays
  kern = centered(ones(psize))
  padimg = parent(padarray(img, Pad(:symmetric)(kern)))
  ϕ = parent(padarray(ϕ, Fill(true, kern)))
  C = parent(padarray(C, Fill(0.0,  kern)))

  # inpainting frontier
  ϕ⁺ = dilate(ϕ)
  δΩ = find(ϕ⁺ - ϕ)

  while !isempty(δΩ)
    # update confidence values in frontier
    for p in δΩ
      c, b = selectpatch([C, ϕ], psize, p)
      C[p] = sum(c[b]) / prod(psize)
    end

    # isophote map
    G = pointgradients(padimg, δΩ)
    N = pointgradients(ϕ, δΩ)
    D = vec(abs.(sum(G.*N, 2)))
    D /= maximum(D)

    # select patch in frontier
    idx = indmax(C[δΩ].*D)
    p = δΩ[idx]
    ψₚ, bₚ = selectpatch([padimg, ϕ], psize, p)

    # compute distance to all other patches
    Δ = convdist(padimg, ψₚ, weights=bₚ)

    # only consider patches in filled region
    Δ[mask] = Inf

    # find index in padded arrays
    idx = indmin(Δ)
    sub = ind2sub(size(Δ), idx)
    padsub = [sub[i] + (psize[i]-1)÷2 for i in 1:length(psize)]
    q = sub2ind(size(padimg), padsub...)

    # select best candidate
    ψᵦ, bᵦ = selectpatch([padimg, ϕ], psize, q)

    # paste patch and mark pixels as painted
    b = bᵦ .& .!bₚ
    ψₚ[b] = ψᵦ[b]
    bₚ[b] = true

    # update frontier
    ϕ⁺ = dilate(ϕ)
    δΩ = find(ϕ⁺ - ϕ)
  end

  padimg
end
