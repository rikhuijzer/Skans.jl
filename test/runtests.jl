using Skans
using Skans:
    TRIPLEQUOTE
using Test

notify = false

const PAGES = [
    Skans.MockPage("url1", "a\""),
    Skans.MockPage("url2", "b")
]

@testset "skan! updating" begin
    scans = Skans.scan.(PAGES)
    state = Skans.State(scans)

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
    @test first(changed).content == "a\""

    changed = skan!(repo, PAGES; notify)
    @test isempty(changed)
end

@testset "Multiline TOML" begin
    scans = Skans.scan.(PAGES)
    state = Skans.State(scans)
    expected = """
        "url1" = $TRIPLEQUOTE
        a\\\"$TRIPLEQUOTE
        "url2" = $TRIPLEQUOTE
        b$TRIPLEQUOTE"""
    actual = Skans.toml(state.scans)
    @test expected == actual
end
