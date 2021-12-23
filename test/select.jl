
@testset "select" begin
    @test body("<html> <body>foo") == "<body>foo</body>"

    actual = Skans.filter_tag("<head></head><body>bar</body>", :body)
    @test actual == "<!DOCTYPE ><HTML><head></head></HTML>"

    @test !contains(noscript("<html><script>foo</script>"), "script")
end

