# helper functions
function plot_crimisini_on_array(img, inds, psize)
  fimg = Float64.(Gray.(img))
  mask = falses(size(fimg))
  mask[inds...] .= true
  fimg[mask] .= NaN
  out = inpaint(fimg, mask, Crimisini(psize))
  return Gray.(out)
end

@testset "ImageInpainting.jl" begin
  @testset "Plain arrays" begin
    @test_reference "references/Blobs.png" plot_crimisini_on_array(blobs, (50:150,50:150), (11,11))
    @test_reference "references/LightHouse.png" plot_crimisini_on_array(lighthouse, (50:350,300:400), (30,30))
  end
end
