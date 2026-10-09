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
NAMESPACE=catalogue
DEPLOYMENT_LABEL=catalogue-web
IMAGE=$(grep -m1 'image:' deployment.yaml | sed 's/.*image: *//')

for i in `seq 1 100`; do
  echo "try #$i";
  RUNNING_COUNT=$(kubectl get pods -n ${NAMESPACE} -l name=${DEPLOYMENT_LABEL} --field-selector=status.phase=Running -o json \
    | jq -r --arg img "${IMAGE}" '[.items[] | select(.spec.containers[].image == $img)] | length')
  echo "Running pods with image ${IMAGE}: ${RUNNING_COUNT}"
  if [ "${RUNNING_COUNT}" -ge 1 ]; then
    echo "Some Pod Running";
    break;
  else
    echo "No pod running yet";
  fi;
  sleep 30;
done

sed -i.bak "s/APP_NAME/${APP_NAME}/" scripts/change_tracking.query && rm -f scripts/change_tracking.query.bak

curl -X POST ${NERDGRAPH_URL} -H 'Content-Type: application/json' -H 'API-Key: '${NEW_RELIC_USER_KEY} --data @scripts/change_tracking.query
