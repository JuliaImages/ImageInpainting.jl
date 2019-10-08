using ImageInpainting
using ColorTypes
using TestImages
using Plots, VisualRegressionTests
using Test, Pkg

# default plot settings
gr(size=(800,400),yflip=true,colorbar=false,ticks=false)

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__,"data")
visualtests = !istravis || (istravis && islinux)
if !istravis
  Pkg.add("Gtk")
  using Gtk
end

# test images
blobs = testimage("blobs")
lighthouse = testimage("lighthouse")

# helper functions
function plot_crimisini_on_array(fname, img, inds, psize)
  fimg = Float64.(Gray.(img))
  mask = falses(size(fimg))
  mask[inds...] .= true
  fimg[mask] .= NaN
  fimg2 = inpaint(fimg, mask, Crimisini(psize))
  plt1 = heatmap(fimg, title="before inpainting")
  plt2 = heatmap(fimg2, title="after inpainting")
  plot(plt1, plt2)
  png(fname)
end

# list of tests
testfiles = [
  "crimisini.jl"
]

@testset "ImageInpainting.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
