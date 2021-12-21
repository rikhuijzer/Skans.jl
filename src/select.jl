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
