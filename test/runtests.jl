using ImageInpainting
using ColorTypes
using TestImages
using ReferenceTests
using Test, Pkg

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
visualtests = !istravis || (istravis && islinux)

# list of tests
testfiles = [
  "criminisi.jl"
]

@testset "ImageInpainting.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
