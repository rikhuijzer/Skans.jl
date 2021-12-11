clone_dir(repo) = joinpath(homedir(), repo.dir)

clone!(repo::MockRepo) = nothing
clone!(repo::MockFileRepo) = nothing

function clone!(repo::GitHubRepo)
    user = string(repo.user)
    token = string(repo.token)
    repository = string(repo.repo)
    branch = string(repo.branch)
    dir = clone_dir(repo)
    url = if token == ""
        "https://github.com/$repository.git"
    else
        "https://$user:$pass@github.com/$repository.git"
    end
    run(`git clone --branch=$branch $url $dir`)
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

function commit!(repo::Repo)
    dir = clone_dir(repo)
    cd(dir) do
        run(`git add .`)
        run(`git commit -m '[Bot] Update stored pages'`)
        run(`git push`)
    end
end

