module Skans

import Base: map!

using AbstractTrees:
    PreOrderDFS,
    StatelessBFS
using HTTP:
    Form,
    get,
    post
using Gumbo:
    HTMLDocument,
    HTMLElement,
    HTMLText,
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

export body, clean
export WebPage
export urls
export GitHubRepo
export skan!

end # module
