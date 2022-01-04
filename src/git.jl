clone_dir(repo) = joinpath(homedir(), repo.dir)

clone!(repo::MockRepo) = nothing
clone!(repo::MockFileRepo) = nothing

function clean_repo!(dir)
    paths = readdir(dir; join=true)
    for path in paths
        if !endswith(path, ".git")
            rm(path; force=true, recursive=true)
        end
    end
    return nothing
end

function clone!(repo::GitHubRepo)
    user = string(repo.user)
    token = string(repo.token)
    repository = string(repo.repo)
    branch = string(repo.branch)
    dir = clone_dir(repo)
    url = if token == ""
        "https://github.com/$repository.git"
    else
        "https://$user:$token@github.com/$repository.git"
    end
    run(`git clone $url $dir`)
    cd(dir) do
        try
            run(`git checkout $branch`)
        catch
            run(`git checkout --orphan $branch`)
            clean_repo!(dir)
        end
    end
    return dir
end

pull_or_clone!(repo::MockFileRepo) = nothing
pull_or_clone!(repo::MockRepo) = nothing

function pull_or_clone!(repo::Repo)
    dir = repo.dir
    if isdir(dir) && ".git" in readdir(dir)
        cd(dir) do
            run(`git pull`)
        end
    else
        clone!(repo)
    end
end

commit!(repo::MockRepo) = nothing
commit!(repo::MockFileRepo) = nothing

git_unchanged() = read(`git status --porcelain`, String) == ""

function commit!(repo::Repo)
    dir = clone_dir(repo)
    branch = repo.branch
    dif = diff()
    cd(dir) do
        if "CI" in keys(ENV)
            run(`git config --global user.email "skansbot@example.com"`)
            run(`git config --global user.name "skansbot"`)
        end
        if git_unchanged()
            println("Nothing changed")
        else
            run(`git add .`)
            run(`git commit -m '[Bot] Update stored pages'`)
            # Required for first push on new branch.
            run(`git push --set-upstream origin $branch`)
        end
    end
    return dif
end

"""
    diff(dir::AbstractString=pwd())

Return the output of `git diff` inside `dir`.
"""
function diff(dir::AbstractString=pwd())
    cd(dir) do
        cmd = `git diff`
        return read(cmd, String)
    end
end

"""
    startswith_one(s::AbstractString, c::Char)::Bool

Return `true` if and only if `c` is at the first position in `s` and not the second.
"""
function startswith_one(s::AbstractString, c::Char)::Bool
    if length(s) == 0
        return false
    elseif length(s) == 1
        return s[1] == c
    else
        return s[1] == c && s[2] != c
    end
end

"""
    diff(old::AbstractString, new::AbstractString)

Return a diff comparing `old` to `new`.
"""
function diff(old::AbstractString, new::AbstractString)
    mktempdir() do dir
        old_path = joinpath(dir, "old.txt")
        new_path = joinpath(dir, "new.txt")
        write(old_path, old * '\n')
        write(new_path, new * '\n')
        cmd = `git diff --no-index $old_path $new_path`
        return read(ignorestatus(cmd), String)
    end
end

"""
    cleandiff(uncleaned::AbstractString)

Return the output of a cleaned up `git diff` inside `dir`.
This keeps only lines starting with `+` or `-` except `+++` or `---` lines.
"""
function cleandiff(uncleaned::AbstractString)
    sep = '\n'
    lines = split(uncleaned, sep)
    filtered = filter(lines) do line
        startswith_one(line, '+') || startswith_one(line, '-')
    end
    threshold = 22
    if threshold < length(filtered)
        filtered = first(filtered, threshold)
        push!(filtered, "[...]")
    end
    return join(filtered, sep)
end

function code_block(s::AbstractString, class::AbstractString)
    return """
        ```$class
        $s
        ```
        """
end
