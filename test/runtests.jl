using Skan
using Test

@testset "skan! updating" begin
    pages = [
        Skan.MockPage("url1", "a"),
        Skan.MockPage("url2", "b")
    ]
    scans = Skan.scan.(pages)
    state = Skan.State(scans)

    repo = Skan.MockRepo(state)

    changed = skan!(repo, pages)
    @test isempty(changed)

    page = Skan.MockPage("url1", "c")
    pagescan = Skan.scan(page)
    changed = skan!(repo, [page, pages[2]])
    @test length(changed) == 1
    @test first(changed).content == "c"
    state = Skan.retrieve(repo)
    @test state.scans["url1"].content == "c"
end

@testset "HTTP get" begin
    url = "http://example.com"
    page = WebPage(url)

    repo = Skan.MockRepo()

    changed = skan!(repo, [page])
    @test !isempty(changed)
end

@testset "Clone and pull GitHub repo" begin
    repo = GitHubRepo(;
        user="",
        token="",
        repo="githubtraining/hellogitworld",
        branch="master"
    )
    Skan.clone!(repo)
    @test !isempty(readdir(repo.dir))
    Skan.pull!(repo)
end

@testset "Store and read MockFileRepo" begin
    pages = [
        Skan.MockPage("url1", "a"),
        Skan.MockPage("url2", "b")
    ]

    repo = Skan.MockFileRepo()
    # changed = skan!(repo, pages)
    # @test length(changed) == 2
    # @test first(changed).content == "a"

    # changed = skan!(repo, pages)
    # @test isempty(changed)
end
