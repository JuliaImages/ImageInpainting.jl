# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module ImageInpainting

using ImageCore
using ImageMorphology
using ImageFiltering
using FFTW: set_num_threads
using CpuId: cpucores

include("utils.jl")
include("pointgradients.jl")
include("inpaint.jl")

export
  # main function
  inpaint,

  # algorithms
  Criminisi

end
