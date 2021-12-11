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
    cd(dir) do
        run(`git config --global user.email "skanbot@example.com"`)
        run(`git config --global user.name "skanbot"`)
        if git_unchanged()
            println("Nothing changed")
        else
            run(`git add .`)
            run(`git commit -m '[Bot] Update stored pages'`)
            # Required for first push on new branch.
            run(`git push --set-upstream origin $branch`)
        end
    end
end

