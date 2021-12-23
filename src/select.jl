"""
    filter_tag(content::String, t::Symbol)

Return a copy of `content`, but without all elements having tag `t`.
"""
function filter_tag(content::String, t::Symbol)
    doc = parsehtml(content)
    for elem in PreOrderDFS(doc.root)
        if elem isa HTMLElement
            children = elem.children
            for i in 1:length(children)
                child = elem.children[i]
                if child isa HTMLElement && tag(child) == t
                    elem.children[i] = HTMLText("")
                end
            end
        end
    end
    return string(doc)::String
end

"""
    body(content::String)

Return only the body from the HTML `content`.
"""
function body(content::String)
    doc = parsehtml(content)
    for elem in PreOrderDFS(doc.root)
        if elem isa HTMLElement && tag(elem) == :body
            return string(elem)::String
        end
    end
    @warn "Couldn't find body in content:\n$content"
    return content
end

noscript(content::String) = filter_tag(content, :script)

"""
    clean(content::String)

Return only the parts of the HTML which are visible in the rendered page.
This assumes that a page has changed when a reader can see a change, which seems like a reasonable assumption.
Note that this assumption may be violated when a elements are updated on the fly via Javascript.
"""
function clean(content::String)
    # Don't turn this around or empty headers and stuff will be added.
    return body(noscript(content))
end
