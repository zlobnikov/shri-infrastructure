#!/usr/bin/env bash

# VERSION=$(git tag --sort version:refname | tail -1 | head -1)
VERSION="v0.4.5"
IMAGE_NAME="zlobnikov:${VERSION}"

docker build . --file DockerFile -t ${IMAGE_NAME}

if [ $? != 0 ]; then
  STATUS=$?
  echo "Something is wrong"
  exit ${STATUS}
fi

RESULT="Docker image built (${IMAGE_NAME})"
echo "\nResult: ${RESULT}"

UNIQUE_KEY="zlobnikov, ${VERSION}"
SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

TICKET_URL=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r ".[].self"
)

RESPONSE=$(
  curl -so dev/null -w '%{http_code}' -X POST "${TICKET_URL}/comments" \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header "Content-Type: application/json" \
  --data-raw '{
      "text": "'"${RESULT}"'"
  }'
)
echo "\nStatus code: ${RESPONSE}."
