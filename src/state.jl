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
    MockRepo(state::State; branch="skan") <: Repo

Mock repository used for testing.
"""
struct MockRepo <: Repo
    state::State
    branch::String255

    function MockRepo(state::State; branch="skan")
        return new(state, String255(branch))
    end
end

"""
    GitHubRepo(; branch="skan") <: Repo

Assuming that we run on a GitHub Runner, then no extra information is needed.
The token and repo can be obtained via `GITHUB_TOKEN` and `GITHUB_REPOSITORY`.
"""
struct GitHubRepo <: Repo
    branch::String255

    function GitHubRepo(; branch="skan")
        return new(String255(branch))
    end
end

store(state::State, repo::MockRepo) = MockRepo(state; branch=repo.branch)

retrieve(repo::MockRepo) = repo.state

"""
    retrieve(repo::Repo) -> State

Return state from `repo`.
"""
function retrieve(repo::Repo)
    error("Not implemented")
end

function retrieve(state::State, page::Page)
    # State could be a dict to speed things up but this is good enough for now.
    dic = state.scans
    key = page.url
    if key in keys(dic)
        return dic[key]
    else
        error("Couldn't find $key in the state")
    end
end

function update!(repo::MockRepo, scan::PageScan)
    key = scan.page.url
    dic = repo.state.scans
    dic[key] = scan
    scans = [dic[k] for k in keys(dic)]
    return MockRepo(State(scans))
end

function update!(repo::Repo, scans::Vector)
    filter!(!isnothing, scans)
    foreach(scan -> update!(repo, scan), scans)
    return repo
end
