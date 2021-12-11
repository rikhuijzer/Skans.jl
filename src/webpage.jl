"""
    Page

Abstract supertype for web pages and mock web pages.
All Page subtypes are assumed to define a `url::String255`.
"""
abstract type Page end

"""
    WebPage(url::AbstractString; selector::Function=identity) <: Page

WebPage to be scanned with `url`.
The `selector` is a function which can be used to scan only a specific region of the page for changes.
"""
struct WebPage <: Page
    url::String255
    selector::Function

    function WebPage(url::AbstractString; selector=identity)
        return new(String255(url), selector)
    end
end

"""
    MockPage(url::AbstractString, html::String; selector::Function=identity) <: Page

Mock web page used for testing.
"""
struct MockPage <: Page
    url::String255
    html::String
    selector::Function

    function MockPage(url::AbstractString, html::String; selector::Function=identity)
        return new(String255(url), html, selector)
    end
end

"""
    PageScan(page::Page, content::String)

Store scanned `content` of `page`.
"""
struct PageScan
    page::Page
    content::String

    PageScan(page::Page, content) = new(page, string(content)::String)
end

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
