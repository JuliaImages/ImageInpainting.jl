using ImageInpainting
using ImageCore
using TestImages, Test, ReferenceTests

datadir = joinpath(@__DIR__, "data")

# list of tests
testfiles = [
  "criminisi.jl"
]

@testset "ImageInpainting.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
