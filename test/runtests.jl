using Skann
using Test

notify = false

@testset "skan! updating" begin
    pages = [
        Skann.MockPage("url1", "a"),
        Skann.MockPage("url2", "b")
    ]
    scans = Skann.scan.(pages)
    state = Skann.State(scans)

    repo = Skann.MockRepo(state)

    changed = skan!(repo, pages; notify)
    @test isempty(changed)

    page = Skann.MockPage("url1", "c")
    pagescan = Skann.scan(page)
    changed = skan!(repo, [page, pages[2]]; notify)
    @test length(changed) == 1
    @test first(changed).content == "c"
    state = Skann.retrieve(repo)
    @test state.scans["url1"].content == "c"
end

@testset "HTTP get" begin
    url = "http://example.com"
    page = WebPage(url)

    repo = Skann.MockRepo()

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
    Skann.pull_or_clone!(repo)
    @test !isempty(readdir(repo.dir))
    # Second time goes through pull logic.
    Skann.pull_or_clone!(repo)
end

@testset "Store and read MockFileRepo" begin
    pages = [
        Skann.MockPage("url1", "a"),
        Skann.MockPage("url2", "b")
    ]

    repo = Skann.MockFileRepo()
    changed = skan!(repo, pages; notify)
    @test length(changed) == 2
    @test first(changed).content == "a"

    changed = skan!(repo, pages; notify)
    @test isempty(changed)
end
