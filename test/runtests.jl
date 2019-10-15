using ImageInpainting
using ColorTypes
using TestImages
using Plots, VisualRegressionTests
using Test, Pkg

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

# helper functions
function plot_before_after(before, mask, after)
  gr(size=(800,400),yflip=true,colorbar=false,ticks=false)
  B = copy(before); B[mask] .= NaN
  p1 = heatmap(B,title="before")
  p2 = heatmap(after,title="after")
  plot(p1, p2, aspect_ratio=:equal)
end

# list of tests
testfiles = [
  "criminisi.jl"
]

@testset "ImageInpainting.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
