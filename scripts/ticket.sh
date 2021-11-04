#!/usr/bin/env bash

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
PREVIOUS_VERSION=$(git tag --sort version:refname | tail -2 | head -1)
echo "\nCurrent version: ${VERSION}"

AUTHOR=$(git show "$VERSION" --pretty=format:"%an" --no-patch)
DATE=$(git show "$VERSION" --pretty=format:"%ad" --no-patch)
echo "\nAuthor: ${AUTHOR}, date: ${DATE}"

CHANGELOG=$(git log ${PREVIOUS_VERSION}.. --pretty=format:"%s | %an, %ad\n" --date=short | tr -s "\n" " ")
SUMMARY="Release ${VERSION} by ${AUTHOR}, ${DATE}"
echo "\nChangelog:\n${CHANGELOG}"

CREATE_TASK_URL="https://api.tracker.yandex.net/v2/issues/"
UNIQUE_KEY="zlobnikov, ${VERSION}"

REQUEST='{
  "summary": "'"${SUMMARY}"'",
  "description": "'"${CHANGELOG}"'",
  "queue": "TMP",
  "unique": "'"${UNIQUE_KEY}"'"
}'

RESPONSE=$(
  curl -so dev/null -w '%{http_code}' -X POST ${CREATE_TASK_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header "Content-Type: application/json" \
  --data "${REQUEST}"
)
echo "\nStatus code: ${RESPONSE}\n"

if [ ${RESPONSE} = 201 ]; then
  echo "Created"
  exit 0
elif [ ${RESPONSE} = 403 ]; then
  echo "Auth Error"
  exit 1
elif [ ${RESPONSE} = 404 ]; then
  echo "Not Found"
  exit 2
elif [ ${RESPONSE} = 409 ]; then
  echo "Already Exists"
  exit 3
fi