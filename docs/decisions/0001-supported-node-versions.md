---
status: proposed
date: 2024-02-19
deciders: Jon, Karen
consulted: Andrei, Pedro, Raj
informed: N/A
---
# Supported Node versions

## Context and Problem Statement

The applications within the CYF ecosystem all run and/or build on Node.js.
Multiple versions of Node (ranging from October 2019's [12.13.0](https://nodejs.org/en/blog/release/v12.13.0) to January 2024's [20.11.0](https://nodejs.org/en/blog/release/v20.11.0)) are currently in use across the various repos.
This causes problems for our security posture and makes it difficult for developers to work across multiple repos (especially a problem for the API/Dashboard/Forms/ITD team).
Although we have identified and fixed these issues in the past, it takes a long time to resolve and has never become a business-as-usual process.

## Decision Drivers

* Containers built on older versions of Node have multiple known CVEs (e.g. [`node:14-alpine`](https://hub.docker.com/layers/library/node/14-alpine/images/sha256-4e84c956cd276af9ed14a8b2939a734364c2b0042485e90e1b97175e73dfd548?context=explore) has 19 vulnerabilities, including 1 rated critical)
* Slow delivery and long review cycles within product teams
* Node releases a new version every 6 months which spends 6 months as the "current" version, and alternate (even-numbered) versions then spend 12 months in "active" LTS and a further 18 months in "maintenance" LTS:

    [![](https://raw.githubusercontent.com/nodejs/Release/main/schedule.svg?sanitize=true)](https://nodejs.org/en/about/previous-releases)

## Considered Options

* Pin a canonical Node version
* Use floating active LTS version
* Use latest Node version

## Decision Outcome

Chosen option: "Use floating active LTS version", because it strikes the best balance of security and maintainability.

### Consequences

* Good, because we get security updates every time we release
* Good, because changes are only needed ~once a year on a predictable schedule (the "active" LTS usually switches in October)
* Good, because developers can use an obvious single Node version across the ecosystem (`nvm install --lts` or pick the _"Recommended For Most Users"_ version on https://nodejs.org/en)
* Bad, because the same commit built twice on the same day could use different versions of Node and/or npm, which may cause issues
* Bad, because some coordination is required across different product teams

### Confirmation

- Every repo should have an explicit `engines` setting in each `package.json` file, allowing the active and maintenance LTS versions (e.g. `"engines": { "node": "^18.12 || ^20.9" }`)
- Every repo should have a `.npmrc` setting `engine-strict = true` alongside each package file, and this should be copied into the container (e.g. `COPY package*.json .npmrc ./`) prior to dependency install where relevant
- If a repo has a `.nvmrc`, that should contain a simple major version (e.g. `20`)
- If a repo has a `Dockerfile` it should use an official `node:` image and may either:
  - take the Node version as a build argument (e.g. `node:$NODE_RELEASE-slim`), where a `.nvmrc` is used to supply the value;
  - set a simple major version (e.g. `node:20-alpine`); or
  - set `lts` (e.g. `node:lts`); and
  - **not** pin e.g. Alpine/Ubuntu versions
- If a repo has a `.circleci/config.yml`, that should use `cimg/node:lts`
- If a repo has a `.github/workflows/*.yml`, that should use `actions/setup-node` with `node-version: lts`

## Pros and Cons of the Options

### Pin a canonical Node version

We would use a single specific version, e.g. `20.11.0` (latest active LTS release at time of writing) across every repo.

* Good, because we get consistent, reproducible builds
* Good, because we'd be using relatively mature Node versions
* Neutral, because developers can use a single version across the ecosystem
* Bad, because we don't get security releases without changing this version
* Bad, because it requires a high level of coordination across the product teams

### Use floating active LTS version

  We would use a "floating" major version, e.g. `^20.9` (active LTS at time of writing) across every repo.

* Good, because we get all security updates
* Good, because we get an 18-month buffer on our maintenance updates
* Good, because we'd be using relatively mature Node versions
* Neutral, because developers can use a single version across the ecosystem
* Bad, because we don't get reproducible builds
* Bad, because some maintenance is needed

### Use latest Node version

We wouldn't pin the Node version at all, e.g. using `FROM node:latest` in Docker files.

* Good, because we get all security updates
* Good, because we don't need to make any code/config changes in the future
* Neutral, because developers can use a single version across the ecosystem (`nvm install node` or _"Latest Features"_ on the Node homepage)
* Bad, because we don't get reproducible builds
* Bad, because we would be using actively developed and less stable Node versions
* Bad, because there's no consistency between environments

## More Information

Current Node version usage:

- API (CodeYourFuture/tech-team#721):
  - CI: uses `cimg/node:20.11.0`
  - Dockerfile: uses `node:20.11.0-bookworm-slim`
  - Package: `"engines": { "node": "^20.11.0" }`
- Class Planner (CodeYourFuture/classplanner#97):
  - CI: uses `node-version: 14`
  - Dockerfile: uses `node:14{,-alpine}`
  - Frontend: `"engines": { "node": "^12.13||^14.17||^16.17" }`
  - Backend: _no engines_
- Dashboard:
  - CI: uses `node-version: 14`
  - Package: `"engines: { ""node": "^12.13||^14.17" }`
- Forms:
  - CI: uses `cypress/base:16.17.1` and `cimg/node:16.17.1`
  - Package: `"engines": { "node": ^16.7.1" }`
- Good PR:
  - Dockerfile: uses `node:18-alpine`
  - Package: _no engines_
- ITD:
  - CI: uses `circleci/node:12.13.0`
  - Package: `"engines": { "node": "^12.13.0" }`
- Project Rainbird (CodeYourFuture/project-rainbird#109):
  - Dockerfile: uses content of `.nvmrc`, currently 20.11.1
  - Package: `"engines": { "node": "^20.7.0", "npm": "^10" }`
