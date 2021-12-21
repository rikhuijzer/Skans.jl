module Skans

using AbstractTrees: PreOrderDFS
using HTTP:
    Form,
    get,
    post
using Gumbo:
    HTMLElement,
    parsehtml,
    tag
using JSON:
    json,
    parse as jsonparse
using TOML:
    parse as tomlparse

const TRIPLEQUOTE = "\"\"\""

include("select.jl")
include("webpage.jl")
include("state.jl")
include("git.jl")
include("notify.jl")
include("skan.jl")

export body
export WebPage
export urls
export GitHubRepo
export skan!

end # module
