module Skans

using HTTP:
    Form,
    get,
    post
using JSON:
    json,
    parse as jsonparse
using TOML:
    parse as tomlparse

const TRIPLEQUOTE = "\"\"\""

include("webpage.jl")
include("state.jl")
include("git.jl")
include("notify.jl")
include("skan.jl")

export WebPage
export urls
export GitHubRepo
export skan!

end # module
