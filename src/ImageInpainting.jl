# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

__precompile__()

module ImageInpainting

using ImageMorphology
using ImageFiltering

include("utils.jl")
include("pointgradients.jl")
include("inpaint.jl")

export
  # main function
  inpaint,

  # algorithms
  Crimisini

end
