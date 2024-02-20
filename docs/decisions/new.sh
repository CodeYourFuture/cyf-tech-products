#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
	echo "usage: ./new.sh 'title'"
	exit 1
fi

NAME="$1"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LABEL='adr'
REPO='CodeYourFuture/tech-team'

if [[ -n "$(git status --porcelain --untracked-files no)" ]]; then
	echo 'Cannot apply to unclean repo, commit or stash your changes.'
	exit 1
fi

echo 'Updating repository'
git checkout master
git pull

if ! type gh >/dev/null 2>&1 || ! gh auth status >/dev/null 2>&1; then
	echo 'Please install and authenticate the GitHub CLI: https://cli.github.com/'
	exit 1
fi

function kebab() {
	LOWERCASE="${1,,}"
	echo "${LOWERCASE// /-}"
}

function lastPullRequest() {
	HEAD_REF="$(gh pr list \
		--jq '.[0].headRefName' \
		--json 'headRefName' \
		--label "$LABEL" \
		--limit 1 \
		--repo "$REPO" \
		--state all)"
	if [[ ! "$HEAD_REF" =~ ^adr/[0-9]{4}- ]]; then
		echo "cannot infer ADR # from previous branch name $HEAD_REF"
		exit 1
	fi
	echo "$((10#${HEAD_REF:4:4}))"
}
NUMBER="$(printf '%04d' "$(($(lastPullRequest) + 1))")"
FILENAME="$NUMBER-$(kebab "$NAME")"

echo "Creating template $FILENAME.md"
if ! cp -n "$HERE/adr-template.md" "$HERE/$FILENAME.md"; then
	echo "$FILENAME.md already exists in docs/decisions/"
	exit 1
fi

BRANCH="adr/$FILENAME"
echo "Creating commit on $BRANCH"
git branch "$BRANCH"
git switch "$BRANCH"
git add "$HERE/$FILENAME.md"
git commit --message "Create draft ADR $NAME"
git push --set-upstream origin "$BRANCH"

echo 'Creating draft Pull Request'
gh pr create \
	--body "Creating new ADR: $NAME. See rendered version at https://github.com/$REPO/blob/$BRANCH/docs/decisions/$FILENAME.md" \
	--draft \
	--head "$BRANCH" \
	--label "$LABEL" \
	--title "ADR-$NUMBER: $NAME"
