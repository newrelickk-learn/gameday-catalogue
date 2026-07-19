#!/bin/bash
NEW_RELIC_USER_KEY=${1:-KEY}
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

curl -X POST https://api.newrelic.com/graphql -H 'Content-Type: application/json' -H 'API-Key: '${NEW_RELIC_USER_KEY} --data @scripts/change_tracking.query