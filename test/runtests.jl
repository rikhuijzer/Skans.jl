using Skans
using Skans:
    TRIPLEQUOTE
using Test
using TOML:
    parse as tomlparse

notify = false

const PAGES = [
    Skans.MockPage("url1", "a"),
    Skans.MockPage("url2", "b")
]

function pages2state(pages::Vector{<:Skans.Page})
    scans = Skans.scan.(pages)
    return Skans.State(scans)
end

@testset "select" begin
    @test body("<html> <body>foo") == "<body>foo</body>"

    actual = Skans.filter_tag("<head></head><body>bar</body>", :body)
    @test actual == "<!DOCTYPE ><HTML><head></head></HTML>"

    @test !contains(noscript("<html><script>foo</script>"), "script")
end

@testset "strip whitespace" begin
    page = Skans.MockPage("u", "        lorem\n     ipsum")
    state = pages2state([page])
    @test state.scans["u"].content == "lorem\nipsum"
end

@testset "skan! updating" begin
    state = pages2state(PAGES)

    repo = Skans.MockRepo(state)

    changed = skan!(repo, PAGES; notify)
    @test isempty(changed)

    page = Skans.MockPage("url1", "c")
    pagescan = Skans.scan(page)
    changed = skan!(repo, [page, PAGES[2]]; notify)
    @test length(changed) == 1
    @test first(changed).content == "c"
    state = Skans.retrieve(repo)
    @test state.scans["url1"].content == "c"
end

@testset "HTTP get" begin
    url = "http://example.com"
    page = WebPage(url)

    repo = Skans.MockRepo()

    changed = skan!(repo, [page]; notify)
    @test !isempty(changed)
end

@testset "Clone and pull GitHub repo" begin
    repo = GitHubRepo(;
        user="",
        token="",
        repo="githubtraining/hellogitworld",
        branch="master"
    )
    Skans.pull_or_clone!(repo)
    @test !isempty(readdir(repo.dir))
    # Second time goes through pull logic.
    Skans.pull_or_clone!(repo)
end

@testset "Store and read MockFileRepo" begin
    repo = Skans.MockFileRepo()
    changed = skan!(repo, PAGES; notify)
    @test length(changed) == 2
    @test first(changed).content == "a"

    changed = skan!(repo, PAGES; notify)
    @test isempty(changed)
end

@testset "Multiline TOML" begin
    state = pages2state(PAGES)
    expected = """
        "url1" = $TRIPLEQUOTE
        a$TRIPLEQUOTE
        "url2" = $TRIPLEQUOTE
        b$TRIPLEQUOTE"""
    actual = Skans.toml(state.scans)
    @test expected == actual

    trouble = raw"userAgent.match(/Firefox[\/\s](\d+\.\d+)/)"
    page = Skans.MockPage("u", trouble)
    state = pages2state([page])
    # Smoke test.
    tomlparse(Skans.toml(state.scans))

    trouble = raw"(/[^a-z0-9\-#$%&'*+.\^_`|~]"
    page = Skans.MockPage("u", trouble)
    state = pages2state([page])
    # Smoke test.
    tomlparse(Skans.toml(state.scans))
end
