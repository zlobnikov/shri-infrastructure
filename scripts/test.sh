#!/usr/bin/env bash

RESULT=$(npm test 2>&1)
echo "Tests Results:\n${RESULT}\n"

SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
UNIQUE_KEY="zlobnikov, ${VERSION}"

TICKET_URL=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r '.[].self'
)

TICKET_DESC=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r '.[].description'
)

# TICKET_URL=$(jq ".[].self" ${TICKET})
# TICKET_DESC=$(${TICKET} | jq '.[].description')

echo "URL: ${TICKET_URL}"
echo "Desc: ${TICKET_DESC}"
