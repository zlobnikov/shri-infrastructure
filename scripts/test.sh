#!/usr/bin/env bash

RESULT=$(npm test)
echo "Tests Results:\n${RESULT}"

SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
UNIQUE_KEY="zlobnikov, ${VERSION}"

SEARCH_REQUEST=${
  "filter": {
    "unique": "'"${UNIQUE_KEY}"'"
  }
}

TICKET=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "${SEARCH_REQUEST}"
)
echo "Ticket: ${TICKET}"
