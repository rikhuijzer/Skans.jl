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

Return cleaned up `content`.
With this cleaning, there is a lower chance that pages appear to have changed even though there nothing is visually different.
Specifically, this method removes invisible elements such as the header and script elements.
"""
function clean(content::String)
    # Don't turn this around or empty headers and stuff will be added.
    return body(noscript(content))
end
