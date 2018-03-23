using ImageInpainting
using ColorTypes
using TestImages
using Plots
using Base.Test
using VisualRegressionTests

# plot defaults
gr(size=(800,400), yflip=true, colorbar=false, ticks=false)

# setup GR backend for Travis CI
ENV["GKSwstype"] = "100"
ENV["PLOTS_TEST"] = "true"

# list of maintainers
maintainers = ["juliohm"]

# environment settings
istravis = "TRAVIS" ∈ keys(ENV)
ismaintainer = "USER" ∈ keys(ENV) && ENV["USER"] ∈ maintainers
datadir = joinpath(@__DIR__,"data")

# test images
blobs = testimage("blobs")
lighthouse = testimage("lighthouse")

# helper functions
function plot_crimisini_on_array(fname, img, inds, psize)
  fimg = Float64.(Gray.(img))
  mask = falses(fimg)
  mask[inds...] = true
  fimg[mask] = NaN
  fimg2 = inpaint(fimg, mask, Crimisini(psize))
  plt1 = heatmap(fimg, title="before inpainting")
  plt2 = heatmap(fimg2, title="after inpainting")
  plot(plt1, plt2)
  png(fname)
end

@testset "ImageInpainting.jl" begin
  @testset "Plain arrays" begin
    plot_blobs(fname) = plot_crimisini_on_array(fname, blobs, (50:150,50:150), (11,11))
    refimg = joinpath(datadir,"Blobs.png")
    @test test_images(VisualTest(plot_blobs, refimg), popup=!istravis) |> success

    plot_lighthouse(fname) = plot_crimisini_on_array(fname, lighthouse, (50:350,300:400), (30,30))
    refimg = joinpath(datadir,"LightHouse.png")
    @test test_images(VisualTest(plot_lighthouse, refimg), popup=!istravis) |> success
  end
end
