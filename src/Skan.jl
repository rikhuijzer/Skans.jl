module Skan

using HTTP:
    Form,
    get,
    post
using TOML:
    parse as tomlparse,
    print as tomlprint
using WeakRefStrings:
    String31,
    String255

include("webpage.jl")
include("state.jl")
include("mail.jl")
include("skan.jl")
include("git.jl")

export WebPage
export GitHubRepo
export skan!

end # module
