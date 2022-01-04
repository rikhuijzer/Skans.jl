"""
    skan!(repo::Repo, pages::Vector{<:Page}; notify=true) -> Vector{PageScan}

Compare the `pages` to the stored state in `repo`.
Return a vector of changed `pages` and update the repo for each changed page.
When no pages changed, the vector is empty.
"""
function skan!(repo, pages::Vector{<:Page}; notify=true)::Vector{PageScan}
    pull_or_clone!(repo)
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
    # Without this, filtered may become a `Vector{Union{Nothing, Skans.PageScan}}`.
    filtered = convert(Array{PageScan}, changed)

    _, dif = update!(repo, state, filtered)

    if notify && !isempty(filtered)
        post_issue_comment!(repo, filtered, dif)
    end

    return changed
end

function mail(changed::Vector{PageScan})
    error("Not implemented yet")
end
