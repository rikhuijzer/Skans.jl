"""
    skan!(repo::Repo, pages::Vector{<:Page}) -> Vector{PageScan}

Compare the `pages` to the stored state in `repo`.
Return a vector of changed `pages` and update the repo for each changed page.
When no pages changed, the vector is empty.
"""
function skan!(repo, pages::Vector{<:Page})::Vector{PageScan}
    state = retrieve(repo)

    changed_scans = map(pages) do page
        oldscan = retrieve(state, page)::PageScan
        newscan = scan(page)::PageScan
        return oldscan.content != newscan.content ? newscan : nothing
    end
    filter!(!isnothing, changed_scans)

    update!(repo, changed_scans)

    return changed_scans
end
