#!/usr/bin/env bash

RESULT=$(npm test 2>&1 | tr -s "\n" "\\n")
# RESULT=$(npm test 2>&1)
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

# TICKET_DESC=$(
#   curl -s -X POST ${SEARCH_URL} \
#   --header "Authorization: OAuth ${OAuth}" \
#   --header "X-Org-ID: ${OrgId}" \
#   --header 'Content-Type: application/json' \
#   --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r ".[].description"
# )
  # --data "{\"filter\": {\"unique\": \"$UNIQUE_KEY\"} }" | jq -r ".[].description" | tr -s "\n" " "

echo "Ticket URL: ${TICKET_URL}"
# echo "Desc:\n${TICKET_DESC}\n"

# UPDATED_DESC=$("${TICKET_DESC} Tests Results: ${RESULT}")
# UPDATED_DESC="new info here ${TICKET_DESC}"
# echo "\nUPDATED DESC:\n${UPDATED_DESC}\n"

# RESPONSE=$(
#   curl -s -X PATCH ${TICKET_URL} \
#   --header "Authorization: OAuth ${OAuth}" \
#   --header "X-Org-ID: ${OrgId}" \
#   --header "Content-Type: application/json" \
#   --data "{\"description\": \"${UPDATED_DESC}\"}"
# )

RESPONSE=$(
  curl -so dev/null -w '%{http_code}' -X POST "${TICKET_URL}/comments" \
  --header "Authorization: OAuth ${OAuth}" \
  --header "X-Org-ID: ${OrgId}" \
  --header "Content-Type: application/json" \
  --data "{\"text\": \"${RESULT}\"}"
)
echo "Response: ${RESPONSE}."

# TODO: process response code
