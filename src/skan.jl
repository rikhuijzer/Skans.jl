"""
    skan!(repo::Repo, pages::Vector{<:Page}) -> Vector{PageScan}

Compare the `pages` to the stored state in `repo`.
Return a vector of changed `pages` and update the repo for each changed page.
When no pages changed, the vector is empty.
"""
function skan!(repo, pages::Vector{<:Page})::Vector{PageScan}
    state = retrieve(repo)

    changed = map(pages) do page
        oldscan = retrieve(state, page)::Union{PageScan,Nothing}
        newscan = scan(page)::PageScan
        if isnothing(oldscan) || oldscan.content != newscan.content
            return newscan
        else
            return nothing
        end
    end
    filter!(!isnothing, changed)

    update!(repo, state, changed)

    return changed
end

function mail(changed::Vector{PageScan})
    error("Not implemented yet")
end
