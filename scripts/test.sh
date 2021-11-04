#!/usr/bin/env bash

RESULT=$(npm test 2>&1  | tail -n +4 | tr -s "\n" " ")
echo "\nTests Results:\n${RESULT}\n"

SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
# UNIQUE_KEY="zlobnikov, ${VERSION}"
UNIQUE_KEY="zlobnikov, v0.4.5" #########################
echo "Unique Key: ${UNIQUE_KEY}\n"

TICKET_URL=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r ".[].self"
)
echo "Ticket URL: ${TICKET_URL}"

RESPONSE=$(
  curl -so dev/null -w '%{http_code}' -X POST "${TICKET_URL}/comments" \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header "Content-Type: application/json" \
  --data-raw '{
      "text": "'"${RESULT}"'"
  }'
)
echo "Response: ${RESPONSE}."

# TODO: process response code
