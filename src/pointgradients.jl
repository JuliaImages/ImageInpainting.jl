# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    pointgradients(img, points; [method])

Compute the gradients along all dimensions of N-dimensional `img`
at `points` using `method`. Default method is `:ando3`.
"""
function pointgradients(img::AbstractArray{T,N},
                        points::AbstractVector;
                        method=:ando3) where {N,T}
  dims = size(img)
  npts = length(points)

  # smoothing weights
  weights = (method == :sobel ? [1,2,1] :
             method == :ando3 ? [.112737,.274526,.112737] :
             error("Unknown gradient method: $method"))

  # pad input image
  padimg = padarray(img, Pad(:replicate, 1, 1))

  # gradient matrix
  G = zeros(npts, N)

  # compute gradient for all directions at specified points
  for i in 1:N
    # kernel = centered difference + perpendicular smoothing
    if dims[i] > 1
      # centered difference
      kern = reshape([-1,0,1], ntuple(k -> k == i ? 3 : 1, N))
      # perpendicular smoothing
      for j in setdiff(1:N, i)
        if dims[j] > 1
          wvec = reshape(weights, ntuple(k -> k == j ? 3 : 1, N))
          kern = broadcast(*, kern, wvec)
        end
      end

      A = zeros(size(kern))
      for (k, icenter) in enumerate(points)
        i1 = CartesianIndex(ntuple(i->1, N))
        for ii in CartesianIndices(A)
          A[ii] = padimg[ii + icenter - i1]
        end

        G[k,i] = sum(kern .* A)
      end
    end
  end

  G
end
