using ImageInpainting
using ImageCore
using TestImages, Test, ReferenceTests

# revoke when we use Pkg.test()
import CpuId
CpuId.cpucores() = 1 # force testing with 1 core
@info "set CPU cores to 1 to get reproducible results"

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
