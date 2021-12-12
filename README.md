# Skan.jl

**<WORK IN PROGRESS.>**

Monitor web pages and get notified when a page has changed.

## Example

To check the BBC homepage for changes, create a GitHub repository with two secrets:

- `RECIPIENT_MAIL`: Your email address to receive updates on.
- `RECIPIENT_NAME`: Your name (makes it less likely that the update is marked as spam).

See the [GitHub docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets) for more information about setting secrets.

And, add the following file:

`.github/workflows/CI.yml`

```
name: CI

on:
  push:
    branches:
      - main
  pull_request:
  workflow_dispatch:
  schedule:
    - cron: '00 16 * * *'

jobs:
  skan:
    name: Skan
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - shell: julia --color=yes {0}
        run: 'using Pkg; Pkg.add(; url="https://github.com/rikhuijzer/Skan.jl#main")'

      - shell: julia --color=yes {0}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          RECIPIENT_MAIL: ${{ secrets.RECIPIENT_MAIL }}
          RECIPIENT_NAME: ${{ secrets.RECIPIENT_NAME }}
        run: |
          using Skan

          repo = GitHubRepo()

          urls = [
              "https://bbc.com"
          ]
          pages = WebPage.(urls)

          changed = skan!(repo, pages)
          @show changed
```

This will add or update the branch `skan` in the GitHub repository from which `skan!` is called **and** will send an email if things have changed.
This `skan` branch stores the downloaded pages to be able to compare them on the next run.

## Features

- Scan a list of web pages for changes compared to the previous check
- For each page, specify which region of the page has to be checked
- Run the checks via scheduled GitHub Actions
- Send an email when a page has changed
