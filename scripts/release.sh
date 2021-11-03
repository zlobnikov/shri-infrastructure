#!/usr/bin/env bash

VERSION = $(git tag --sort version:refname | tail -1 | head -1)
PREVIOUS_VERSION = $(git tag --sort version:refname | tail -2 | head -1)
echo "versions:"
echo ${VERSION}
echo ${PREVIOUS_VERSION}

AUTHOR=$(git show "$VERSION" --pretty=format:"%an" --no-patch)
DATE=$(git show "$VERSION" --pretty=format:"%ad" --no-patch)

CHANGELOG=$(git log ${PREVIOUS_VERSION}.. --pretty=format:"%s | %an, %ad" --date=short)
SUMMARY="Release ${VERSION} by ${AUTHOR_NAME}, ${DATE}"
echo "Author: ${AUTHOR}, DATE: ${DATE}"
echo "Changelog\n${CHANGELOG}"

CREATE_TASK_URL="https://api.tracker.yandex.net/v2/issues/"

RESPONSE=$(
  curl -so dev/null -w '%{http_code}' -X POST ${CREATE_TASK_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "summary": "'${SUMMARY}'",
      "description": "'${CHANGELOG}'",
      "queue": "TMP",
      "unique": "'${VERSION}'"
  }'
)

echo "Response: ${RESPONSE}"

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