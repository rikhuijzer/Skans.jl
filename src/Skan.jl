module Skan

using HTTP:
    Form,
    get,
    post
using JSON:
    json,
    parse as jsonparse
using TOML:
    parse as tomlparse,
    print as tomlprint
using WeakRefStrings:
    String31,
    String255

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
