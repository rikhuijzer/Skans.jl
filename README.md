# Skans.jl

[![CI Test][ci-img]][ci-url]
[![Website][site-img]][site-url]

[ci-img]: https://github.com/rikhuijzer/Skans.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/rikhuijzer/Skans.jl/actions?query=workflow%3ACI+branch%3Amain

[site-img]: https://img.shields.io/badge/Skans-website-blue.svg
[site-url]: https://skans.dev

Monitor web pages and get notified when a page has changed.

## Features

- Scan a list of web pages for changes
- For each page, specify which region of the page has to be checked
- Run the checks on a schedule (specified via a CRON job; powered by GitHub Actions)
- Get notified when a page has changed

## Use-cases

Monitor pages for:

- New job offers
- Availability (error detection)
- Updated product pricing
- New (financial) reports or other news
- Updates to legislation
