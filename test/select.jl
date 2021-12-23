
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

    expected = """
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
        </body>
        </html>
        """

    actual = Skans.clean(html)
    lines_actual = split(actual, '\n')
    lines_expected = split(expected, '\n')
    n_lines = maximum(length(lines_actual), length(lines_expected))
    # Using loop for easier debugging in tests.
    for i in n_lines
        @test lines_actual[i] == lines_expected[i]
    end
end

