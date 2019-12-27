#!/usr/bin/env bash
set -e

CRATES_INDEX_PATH="/tmp/crates-index.js"
BRANCH="gh-pages"

build() {
  echo "Starting building crates-index..."
  cd rust
  cargo run ${CRATES_INDEX_PATH}
  cd ..
  echo "{\"version\": $(date +%s)}" > /tmp/version.json
}

upload() {
  echo "Starting uploading crates-index..."
  git config --global url."https://".insteadOf git://
  git config --global url."https://github.com/".insteadOf git@github.com:

  git checkout ${BRANCH}
  if [[ ! -d "crates" ]]
  then
    mkdir crates
  fi
  cp "${CRATES_INDEX_PATH}" /tmp/version.json crates/

  git config user.name "GitHub Actions"
  git config user.email "github-actions-bot@users.noreply.github.com"
  git add crates/
  git commit --amend -m "Upload latest crates index"
  git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" ${BRANCH}:${BRANCH} -f

  echo "Upload complete"
}

build
upload