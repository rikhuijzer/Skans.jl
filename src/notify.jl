issue_title() = "Skan updates"

function github_headers(repo)
    token = repo.token
    return [
        "Accept" => "application/vnd.github.v3+json",
        "Authorization" => "token $token"
    ]
end

function create_issue!(repo::GitHubRepo)::Int
    repository = repo.repo
    url = "https://api.github.com/repos/$repository/issues"
    headers = github_headers(repo)
    body = """
        This issue is automatically created by [Skans.jl](https://github.com/rikhuijzer/Skans.jl) and receives a new comment when a web page has changed. Skans uses the title to find this issue back, so do not change the title.

        If you were watching this repository, then you should already be subscribed and, hence, getting notifications for new comments on this issue. If you do not get notifications yet, click on "Subscribe".
        """
    dic = Dict(:title => issue_title(), :body => body)
    js = json(dic)
    response = post(url, headers, js)
    dic = jsonparse(String(response.body))
    return dic["number"]
end

"""
    list_issues(repo::GitHubRepo) -> Vector{Dict{String,Any}}

Return a list of issues for `repo`.
Note that closed issues are ignored.
"""
function list_issues(repo::GitHubRepo)::Vector{Dict{String,Any}}
    repository = repo.repo
    url = "https://api.github.com/repos/$repository/issues"
    headers = github_headers(repo)
    response = get(url, headers)
    js = String(response.body)
    parsed = jsonparse(js)::Vector{Any}
    issues = convert(Vector{Dict{String,Any}}, parsed)
    return issues
end

function skans_issue_number(issues::Vector{Dict{String,Any}})::Int
    title = issue_title()
    for issue in issues
        if issue["title"] == title
            return issue["number"]
        end
    end
    return -1
end

href(url::String) = "<$url>"

hli(text) = "- $text"

function md(changed::Vector{BeforeAfter})
    items = map(changed) do ba
        cleaned = cleandiff(diff(ba))
        block = code_block(cleaned, "diff")
        url = href(string(ba.new.page.url))
        item = """
            ### $url:

            $block
            """
    end
    text = join(items, '\n')
    return """
        The following pages changed:

        $text
        """
end

"""
    skans_issue_number(repo::GitHubRepo)

Finds the issue created by Skans by selecting the first issue with `issue_title()`.
"""
function skans_issue_number(repo::GitHubRepo)
    issues = list_issues(repo)
    return skans_issue_number(issues)
end

function post_issue_comment!(repo::GitHubRepo, num::Int, changed::Vector{BeforeAfter})
    repository = repo.repo
    url = "https://api.github.com/repos/$repository/issues/$num/comments"
    headers = github_headers(repo)
    text = md(changed)
    dic = Dict(:body => text)
    js = json(dic)
    return post(url, headers, js)
end

function post_issue_comment!(repo::GitHubRepo, changed::Vector{BeforeAfter})
    issues = list_issues(repo)
    num = skans_issue_number(issues)
    if num == -1
        num = create_issue!(repo)
    end
    return post_issue_comment!(repo, num, changed)
end

