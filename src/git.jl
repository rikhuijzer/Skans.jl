clone_dir(repo) = joinpath(homedir(), repo.dir)

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

function pull!(repo::Repo)
    dir = repo.dir
    if isdir(dir)
        cd(dir) do
            run(`git pull`)
        end
    else
        clone!(repo)
    end
end

function commit!(repo::Repo)
    dir = repo.dir
    cd(dir) do
        run(`git add .`)
        run(`git commit -m '[Bot] Update stored pages'`)
        run(`git push`)
    end
end

