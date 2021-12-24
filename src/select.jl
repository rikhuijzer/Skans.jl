"""
    pretty(doc)

Pretty print the parsed HTML `doc`.
"""
function pretty(doc)
    io = IOBuffer()
    print(io, doc; pretty=true)
    return String(take!(io))
end

function map!(f::Function, doc::HTMLDocument)
    for elem in PreOrderDFS(doc.root)
        if elem isa HTMLElement
            # Changing elem directly doesn't work, so we loop direct children.
            children = elem.children
            for i in 1:length(children)
                elem.children[i] = f(elem.children[i])
            end
        end
        # else (isa HTMLText) is handled by the fact that we loop direct children.
    end
    return doc
end

function clean(elem::HTMLElement{T}) where T
    children = elem.children
    parent = elem.parent
    attributes = Dict{AbstractString,AbstractString}()
    return HTMLElement{T}(children, parent, attributes)
end

function remove_extra_href_info(entry::Pair)
    url = last(entry)
    symbol_loc = findfirst(r"\?|#", url)
    if isnothing(symbol_loc)
        return entry
    else
        symbol_loc_start = first(findfirst(r"\?|#", url))
        stripped = url[1:symbol_loc_start] * "[...]"
        new_entry::Pair = first(entry) => stripped
        return new_entry
    end
end

function remove_extra_href_info(dic::Dict)::Dict
    pairs = [remove_extra_href_info(entry) for entry in dic]
    return Dict(pairs)
end

function clean(elem::HTMLElement{:a})
    children = elem.children
    parent = elem.parent
    attributes = filter(entry -> first(entry) == "href", elem.attributes)
    updated_attributes = remove_extra_href_info(attributes)
    return HTMLElement{:a}(children, parent, updated_attributes)
end

function clean(elem::T) where T<:Union{HTMLElement{:style},HTMLElement{:script}}
    children = []
    parent = elem.parent
    attributes = Dict{AbstractString,AbstractString}()
    return T(children, parent, attributes)
end

function contains_title_description(entry)
    text = string(entry)::String
    return contains(text, r"title|description")
end

function clean(elem::HTMLElement{:meta})
    children = elem.children
    parent = elem.parent
    A = elem.attributes
    K = keys(A)
    if !any(contains_title_description(A))
        A = Dict{AbstractString,AbstractString}()
    end
    return HTMLElement{:meta}(children, parent, A)
end

function clean_tree(elem::HTMLElement)
    return clean(elem)
end

function clean_tree(elem::HTMLText)
    return elem
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

"""
    clean(content::String)

Return only the parts of the HTML which are visible in the rendered page.
This assumes that a page has changed when a reader can see a change, which seems like a reasonable assumption.
Note that this assumption may be violated when a elements are updated on the fly via Javascript.
"""
function clean(content::String)
    doc = parsehtml(content)
    map!(clean_tree, doc)
    text = pretty(doc)
    return """
        <!-- This HTML document was cleaned up (simplified) by `Skans.clean`. -->
        $text
        """
end
