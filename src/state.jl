"""
    State(scans::Vector{PageScan})

State of the scans.
"""
struct State
    scans::Dict{String255,PageScan}

    function State(scans::Vector{PageScan})
        urls = [scan.page.url for scan in scans]
        if !(length(scans) == length(unique(urls)))
            msg = """
                Not all URLs were unique.
                Cannot store multiple scans for one page.
                """
            error(msg)
        end
        dic = Dict(zip(urls, scans))
        return new(dic)
    end
end

"""
    Repo

Abstract type for repositories.
These Git repositories are used to store the state.
Of course, a database would be better but repositories are available when running in a CI job and databases are not.
"""
abstract type Repo end

"""
    MockRepo(state=State(PageScan[])) <: Repo

Mock repository used for testing.
"""
struct MockRepo <: Repo
    state::State

    function MockRepo(state=State(PageScan[]))
        return new(state)
    end
end

struct MockFileRepo <: Repo
    dir::String

    MockFileRepo(dir=mktempdir()) = new(dir)
end

"""
    GitHubRepo(;
        user=ENV["GITHUB_ACTOR"],
        token=ENV["GITHUB_TOKEN"],
        repo=ENV["GITHUB_REPOSITORY"],
        branch="skan"
    )

Assuming that we run on a GitHub Runner, then no extra information is needed.
The token and repo can be obtained via `GITHUB_TOKEN` and `GITHUB_REPOSITORY`.
For public repositories, set `token` to the empty string `""`.
`repo` is of the form `octocat/Hello-World`.
"""
struct GitHubRepo <: Repo
    dir::String
    user::String255 # octocat
    token::String255
    repo::String255 # octocat/Hello-World
    branch::String255

    function GitHubRepo(;
            dir=mktempdir(),
            user=ENV["GITHUB_ACTOR"],
            token=ENV["GITHUB_TOKEN"],
            repo=ENV["GITHUB_REPOSITORY"],
            branch="skan"
        )
        return new(
            dir,
            String255(user),
            String255(token),
            String255(repo),
            String255(branch)
        )
    end
end

store!(repo::MockRepo, state::State) = MockRepo(state; branch=repo.branch)

state_path(repo::Repo) = joinpath(repo.dir, "state.toml")

function store!(repo::Repo, state::State)
    path = state_path(repo)
    open(path, "w") do io
        tomlprint(io, state.scans) do x
            x isa PageScan && return x.content
            error("unhandled type $(typeof(x))")
        end
    end
    return repo.dir
end

retrieve(repo::MockRepo)::State = repo.state

"""
    retrieve(repo::Repo) -> State

Return state from `repo`.
"""
function retrieve(repo::Repo)
    path = state_path(repo)
    pull!(repo)
    if isfile(path)
        data = read(path, String)
        dic = tomlparse(data)
        scans = [PageScan(WebPage(k), dic[k]) for k in keys(dic)]
        return State(scans)
    else
        return State(PageScan[])
    end
end

function retrieve(state::State, page::Page)::Union{PageScan,Nothing}
    # State could be a dict to speed things up but this is good enough for now.
    dic = state.scans
    key = page.url
    if key in keys(dic)
        return dic[key]
    else
        return nothing
    end
end

function update!(repo::MockRepo, state::State, scan::PageScan)
    key = scan.page.url
    repo.state.scans[key] = scan
    return repo
end

function update!(repo::MockRepo, state::State, scans::Vector)
    filter!(!isnothing, scans)
    foreach(scan -> update!(repo, state, scan), scans)
    return repo
end

function update!(repo::Repo, state::State, scans::Vector)
    for scan in scans
        key = scan.page.url
        state.scans[key] = scan
    end
    store!(repo, state)
    commit!(repo)
    return repo
end

