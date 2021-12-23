
@testset "select" begin
    html = """
        <!doctype html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">

            <link rel="stylesheet" href="/css/foo.css">
            <link rel="icon" href="/assets/favicon.png">
            <title> Home - Site.xyz</title>

            <meta property="og:title" content="Home" />

            <meta property="og:description" content="description" />

            <meta name="twitter:title" content="Home" />

            <script defer type="text/javascript" src="lorem" id="ipsum"></script>
        </head>
        <body>
            <header>
                <div class="name"><a href="/">NAME</a></div>
                <nav>
                    <ul>
                        <li><a href="/about/">About</a></li>
                    </ul>
                </nav>
            </header>

        <div class="lorem">
        lorem ipsum
        </div>
        """

    doc = parsehtml(html)
    # Smoke test.
    map!(identity, doc)

    expected = """
        <!-- This HTML document was cleaned up (simplified) by `Skans.clean`. -->
        <!DOCTYPE html><HTML lang="en">
          <head>
            <meta/>
            <meta/>
            <link/>
            <link/>
            <title>
              Home - Site.xyz
            </title>
            <meta content="Home" property="og:title"/>
            <meta content="description" property="og:description"/>
            <meta content="Home" name="twitter:title"/>
            <script></script>
          </head>
          <body>
            <header>
              <div>
                <a href="/">
                  NAME
                </a>
              </div>
              <nav>
                <ul>
                  <li>
                    <a href="/about/">
                      About
                    </a>
                  </li>
                </ul>
              </nav>
            </header>
            <div>
              lorem ipsum
            </div>
          </body>
        </HTML>
        """

    actual = Skans.clean(html)

    println("expected:")
    print(expected)

    println("actual:")
    print(actual)
    println()

    @test strip(expected) == strip(actual)
end

