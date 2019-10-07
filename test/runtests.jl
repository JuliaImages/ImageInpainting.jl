using ImageInpainting
using ColorTypes
using TestImages
using Test, ReferenceTests

# test images
blobs = testimage("blobs")
lighthouse = testimage("lighthouse")

# list of tests
testfiles = [
  "crimisini.jl"
]

@testset "ImageInpainting.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
