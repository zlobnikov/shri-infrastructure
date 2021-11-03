#!/usr/bin/env bash

RESULT=$(npm test 2>&1)
echo "Tests Results:\n${RESULT}"

echo "getting release version"

SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
UNIQUE_KEY="zlobnikov, ${VERSION}"

echo "forming search request"

# SEARCH_REQUEST=${
#   "filter": {
#     "unique":"'"${UNIQUE_KEY}"'"
#   }
# }
# echo "search request:"
# echo ${SEARCH_REQUEST}

TICKET=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }")
)
echo "Ticket: ${TICKET}"
