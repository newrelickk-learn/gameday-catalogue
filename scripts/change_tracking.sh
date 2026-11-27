#!/bin/bash
# usage: change_tracking.sh <USER_KEY> [REGION: US|JP] [APP_NAME]
NEW_RELIC_USER_KEY=${1:-KEY}
NEW_RELIC_REGION=$(echo "${2:-${NEW_RELIC_REGION:-US}}" | tr '[:lower:]' '[:upper:]')
APP_NAME=${3:-${APP_NAME:-catalogue}}
case "${NEW_RELIC_REGION}" in
  US) NERDGRAPH_URL=https://api.newrelic.com/graphql ;;
  JP) NERDGRAPH_URL=https://api.jp.newrelic.com/graphql ;;
  *) echo "Unknown region: ${NEW_RELIC_REGION} (use US or JP)"; exit 1 ;;
esac
sed -i.bak "s/APP_NAME/${APP_NAME}/" scripts/change_tracking.query && rm -f scripts/change_tracking.query.bak

curl -X POST ${NERDGRAPH_URL} -H 'Content-Type: application/json' -H 'API-Key: '${NEW_RELIC_USER_KEY} --data @scripts/change_tracking.query
