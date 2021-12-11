module Skan

using HTTP: get
using WeakRefStrings: String255

include("webpage.jl")
include("state.jl")
include("skan.jl")

export WebPage
export skan!

end # module
