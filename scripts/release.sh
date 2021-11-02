#!/usr/bin/env bash

VERSION = $(git tag --sort version:refname | tail -1 | head -1)
PREVIOUS_VERSION = $(git tag --sort version:refname | tail -2 | head -1)

AUTHOR = $(git show "$VERSION" --pretty=format:"%an" --no-patch)
DATE = $(git show "$VERSION" --pretty=format:"%ad" --no-patch)
CHANGELOG = $(git log ${PREVIOUS_VERSION}.. --pretty=format:"%s | %an, %ad" --date=short)

CREATE_TASK_URL="https://api.tracker.yandex.net/v2/issues/"

SUMMARY="Release ${VERSION} by ${AUTHOR_NAME}, ${DATE}"
DESCRIPTION="${CHANGELOG}"
UNIQUE_KEY="pivacik/${LAST_RELEASE_TAG}"

RESPONSE=$(
  curl -so dev/null -w '%{http_code}' -X POST ${CREATE_TASK_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "summary": "'${SUMMARY}'",
      "description": "'${DESCRIPTION}'",
      "queue": "TMP",
      "unique": "'${VERSION}'"
  }'
)

if [ ${RESPONSE} = 201 ]; then
  echo "Created"
  exit 0
elif [ ${RESPONSE} = 404 ]; then
  echo "Not found"
  exit 1
elif [ ${RESPONSE} = 409 ]; then
  echo "Already exists"
  exit 2
fi