#!/bin/bash
NEW_RELIC_USER_KEY=${1:-KEY}
for i in `seq 1 100`; do
  echo "try #$i";
  RES=$(curl -X POST https://api.newrelic.com/graphql -H 'Content-Type: application/json' -H 'API-Key: '${NEW_RELIC_USER_KEY} --data @scripts/running1stPod.query)
  echo $RES
  if [ -z `echo $RES | grep \"count\":1` ]; then
    echo "No pod running yet";
  else
    echo "Some Pod Running";
    break;
  fi;
  sleep 30;
done

curl -X POST https://api.newrelic.com/graphql -H 'Content-Type: application/json' -H 'API-Key: '${NEW_RELIC_USER_KEY} --data @scripts/change_tracking.query