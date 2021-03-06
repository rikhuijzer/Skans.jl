"""
    Page

Abstract supertype for web pages and mock web pages.
All Page subtypes are assumed to define a `url::String`.
"""
abstract type Page end

"""
    WebPage(url::AbstractString; selector::Function=clean) <: Page

WebPage to be scanned with `url`.
The `selector` is a function which can be used to scan only a specific region of the page for changes.
By default, only the `body` is taken into account.
To take the full page, pass `selector=identity`.
"""
struct WebPage <: Page
    url::String
    selector::Function

    function WebPage(url::AbstractString; selector=clean)
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

    function MockPage(url::AbstractString, html::String; selector::Function=clean)
        return new(string(url)::String, html, selector)
    end
end

"""
    PageScan(page::Page, content::String)

Store scanned `content` of `page`.
"""
struct PageScan
    page::Page
    content::String

    function PageScan(page::Page, content)
        return new(page, string(content)::String)
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
