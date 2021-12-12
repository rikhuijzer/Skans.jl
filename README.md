# Skan.jl

**<WORK IN PROGRESS.>**

Monitor web pages and get notified when a page has changed.

## Features

- Scan a list of web pages for changes
- For each page, specify which region of the page has to be checked
- Run the checks on a schedule (specified via a CRON job; powered by GitHub Actions)
- Get notified when a page has changed

## Example

To check <http://example.com> and <https://bbc.com> for changes, create a new GitHub repository and copy the contents of

[.github/workflows/Skan.yml](https://github.com/rikhuijzer/Skan.jl/blob/main/.github/workflows/Skan.yml)

into your own repository.

After doing this, Skan will check the web pages for changes and add an issue comment in your repository every time a page changed.
The downloaded pages are stored in the `skan` branch of your repository to be able to compare them on the next run.

