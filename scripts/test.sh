#!/usr/bin/env bash

RESULT=$(npm test 2>&1  | tail -n +4 | tr -s "\n" " ")
echo "\nTests results:\n${RESULT}"

SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
UNIQUE_KEY="zlobnikov, ${VERSION}"

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
echo "\nStatus code: ${RESPONSE}"
