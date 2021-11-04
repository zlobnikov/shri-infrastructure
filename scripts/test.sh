#!/usr/bin/env bash

RESULT=$(npm test 2>&1 | tr -s "\n" " ")
echo "\nTests Results:\n${RESULT}\n"

SEARCH_URL="https://api.tracker.yandex.net/v2/issues/_search"

VERSION=$(git tag --sort version:refname | tail -1 | head -1)
# UNIQUE_KEY="zlobnikov, ${VERSION}"
UNIQUE_KEY="zlobnikov, v0.4.5"
echo "Unique Key: ${UNIQUE_KEY}\n"

TICKET_URL=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r ".[].self"
)

TICKET_DESC=$(
  curl -s -X POST ${SEARCH_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header 'Content-Type: application/json' \
  --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r ".[].description" | tr -s "\n" " "
)

echo "Ticket URL: ${TICKET_URL}"
echo "Desc:\n${TICKET_DESC}\n"

UPDATED_DESC=$("${TICKET_DESC}\nTests Results:\n${RESULT}" | tr -s "\n" " ")
echo "\nUPDATED DESC:\n${UPDATED_DESC}\n"

RESPONSE=$(
  curl -s -X PATCH ${TICKET_URL} \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header "Content-Type: application/json" \
  --data "{\"description\": \"${UPDATED_DESC}\"}"
)

# TODO: process response code

if [ ${RESPONSE} = 200 ]; then
  echo "Published"
  exit 0
elif [ ${RESPONSE} = 401 ]; then
  echo "Auth Error"
  exit 1
elif [ ${RESPONSE} = 403 ]; then
  echo "Auth Error"
  exit 1
elif [ ${RESPONSE} = 404 ]; then
  echo "Not Found"
  exit 2
elif [ ${RESPONSE} = 409 ]; then
  echo "Conflict"
  exit 3
fi
