---
status: proposed
date: 2024-03-04
deciders: Jon, Karen
consulted: Andrei, Raj
informed: N/A
---
# Migrate from Create React App to Vite

## Context and Problem Statement

Several of our React client applications use [Create React App](https://create-react-app.dev/)/`react-scripts`, at various versions (`3.4.4`, `4.0.1` and `5.0.1`/latest).
This project has seemingly been abandoned - the last release was published on 2022/4/12, almost two years ago, and [the updated React docs](https://react.dev/) no longer recommend its use.

Some of the vulnerabilities identified in our repos are via `react-scripts`, which has a large surface area due to the large number of dependencies (a brand new CRA app brings in 1,559 packages).
Some of these can be fixed by applying patches to the dependency tree (Dependabot-created or otherwise) or using the latest version of CRA, but at least two (one high, one moderate) cannot.
Although the maintainers [reasonably point out](https://github.com/facebook/create-react-app/issues/11174) that this doesn't necessarily impact end users, its inclusion in `dependencies` (as some of the things it installs _are_ part of the bundled code we ship) makes it hard to determine the right course of action for a given vulnerability.

## Decision Drivers

* CRA/`react-scripts` is out of support
* Currently two unfixable vulnerabilities, more may emerge
* React documentation no longer references CRA
    * Now references (among others) [Vite](https://vitejs.dev/) and [Next.js](https://nextjs.org/)
    * CYF is also moving away from CRA ([to Vite](https://curriculum.codeyourfuture.io/react/prep/#check-you-can-create-a-react-app-with-vite))
* Good PR is already using Next.js

## Considered Options

* Retain CRA
* Migrate to Vite (and [Vitest](https://vitest.dev))
* Migrate to Next.js
* Migrate to hand-rolled Webpack etc.

## Decision Outcome

Chosen option: "Migrate to Vite", because it comes out best (see below).

<!-- This is an optional element. Feel free to remove. -->
### Consequences

* Good, because we resolve the vulnerabilities
* Good, because we rely on tooling that's still actively maintained
* Good, because we reduce our surface area (223 packages for a new Vite/React app)
* Bad, because four repos need changes

<!-- This is an optional element. Feel free to remove. -->
### Confirmation

`react-scripts` will no longer exist in the `dependencies`/`devDependencies` in any of our applications.

<!-- This is an optional element. Feel free to remove. -->
## Pros and Cons of the Options

### Retain CRA

We keep CRA, but upgrade all applications using it to v5.0.1

* Good, because only two repos (Dashboard, ITD) need any changes
* Neutral, because no substantial architectural changes are required
* Neutral, because we gain no improved functionality
* Bad, because we cannot resolve the vulnerabilities
* Bad, because we retain a large surface area
* Bad, because we rely on tooling that no longer gets updates

### Migrate to Vite

We replace CRA with Vite, which is close to a drop-in replacement

* Good, because we resolve the vulnerabilities
* Good, because we rely on tooling that's still actively maintained
* Good, because we reduce our surface area (223 packages for a new Vite/React app)
* Neutral, because we gain no additional functionality
* Neutral, because no substantial architectural changes are required
* Bad, because four repos need changes

### Migrate to Next.js

We replace CRA with Next.js (in [static export mode](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)), which is a different approach to building frontend apps

* Good, because we resolve the vulnerabilities
* Good, because we rely on tooling that's still actively maintained
* Good, because we reduce our surface area (308 packages for a new Next.js app)
* Good, because we gain some additional functionality (e.g. page pre-rendering)
* Bad, because it requires subsantial architectural changes (and learning)
* Bad, because four repos need changes

### Migrate to hand-rolled Webpack etc.

We use the same setup already in Project Rainbird for the currently-CRA client apps

* Good, because we resolve the vulnerabilities
* Good, because we reduce our surface area
* Neutral, because we gain no additional functionality
* Neutral, because no substantial architectural changes are required
* Bad, because we have to maintain that tooling ourselves
* Bad, because four repos need changes

<!-- This is an optional element. Feel free to remove. -->
## More Information

Unfixable vulnerabilities via `react-scripts`:
- 🔴 High - `nth-check` https://github.com/advisories/GHSA-rp65-9cf3-cjxr
- 🟡 Moderate - `post-css` https://github.com/advisories/GHSA-7fh5-64p2-3v2j

Current versions:

- API
    - _N/A_ (no React client code)
- Class Planner
    - `"^5.0.1"` -> `5.0.1`
- Dashboard
    - `"^4.0.1"` -> `4.0.1`
- Forms
    - `"5.0.1"` -> `5.0.1`
- Good PR
    - _N/A_ (uses Next.js)
- ITD
    - `"^3.0.0"` -> `3.4.4`
- Project Rainbird
    - _N/A_ (uses Webpack etc. directly)
