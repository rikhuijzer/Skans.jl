using Skan
using Test

@testset "skan" begin
    pages = [
        Skan.MockPage("url1", "a"),
        Skan.MockPage("url2", "b")
    ]
    scans = Skan.scan.(pages)
    state = Skan.State(scans)

    repo = Skan.MockRepo(state)

    changed_pages = skan!(repo, pages)
    @test isempty(changed_pages)

    page = Skan.MockPage("url1", "c")
    pagescan = Skan.scan(page)
    @show pagescan
    repo = Skan.update!(repo, pagescan)
    changed_pages = skan!(repo, pages)
    @test !isempty(changed_pages)
    # @test repo.state.scans["url1"].content == "c"
end
