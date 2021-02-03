using ImageInpainting
using ColorTypes
using TestImages
using ReferenceTests
using Test, Pkg

# list of tests
testfiles = [
  "criminisi.jl"
]

@testset "ImageInpainting.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
