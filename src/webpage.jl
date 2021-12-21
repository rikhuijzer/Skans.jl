"""
    Page

Abstract supertype for web pages and mock web pages.
All Page subtypes are assumed to define a `url::String`.
"""
abstract type Page end

"""
    WebPage(url::AbstractString; selector::Function=identity) <: Page

WebPage to be scanned with `url`.
The `selector` is a function which can be used to scan only a specific region of the page for changes.
"""
struct WebPage <: Page
    url::String
    selector::Function

    function WebPage(url::AbstractString; selector=identity)
        return new(string(url)::String, selector)
    end
end

"""
    MockPage(url::AbstractString, html::String; selector::Function=identity) <: Page

Mock web page used for testing.
"""
struct MockPage <: Page
    url::String
    html::String
    selector::Function

    function MockPage(url::AbstractString, html::String; selector::Function=identity)
        return new(string(url)::String, html, selector)
    end
end

function strip_whitespace(content::AbstractString)::String
    sep = '\n'
    lines = split(string(content)::String, sep)
    stripped = strip.(lines)
    return join(stripped, sep)
end

"""
    PageScan(page::Page, content::String)

Store scanned `content` of `page`.
"""
struct PageScan
    page::Page
    content::String

    function PageScan(page::Page, content)
        return new(page, strip_whitespace(content))
    end
end

urls(scans::AbstractVector{PageScan}) = [scan.page for scan in scans]

function scan(page::MockPage)::PageScan
    return PageScan(page, page.html)
end

function scan(page::WebPage)::PageScan
    url = string(page.url)::String
    response = get(url)
    content = String(response.body)
    selection = page.selector(content)
    return PageScan(page, selection)
end
