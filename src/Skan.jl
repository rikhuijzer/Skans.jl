module Skan

using HTTP: get
using TOML:
    parse as tomlparse,
    print as tomlprint
using WeakRefStrings:
    String31,
    String255

include("webpage.jl")
include("state.jl")
include("skan.jl")

export WebPage
export skan!

end # module
