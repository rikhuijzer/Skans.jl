# Skan.jl

**<WORK IN PROGRESS.>**

Scan web pages for changes

## Example

To check the BBC homepage for changes in a GitHub Action, use:

```
- run: julia --project -e '
    using Skan;
    repo = GitHubRepo();
    page = WebPage("https://bbc.com");
    skan!(repo, [page]);
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This will add or update the branch `skan` in the GitHub repository from which `skan!` is called.
This `skan` branch stores the downloaded pages to be able to compare them on the next run.

## Features

- Scan a list of web pages for changes compared to the previous check
- For each page, specify which region of the page has to be checked
- Run the checks via scheduled GitHub Actions
- Send an email when a page has changed
