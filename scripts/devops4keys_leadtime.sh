#!/bin/bash

latestTag=$(git describe --tags --abbrev=0)
prevTag=$(git describe --tags $(git rev-list --tags --max-count=10) | grep -v "-" | head -n 2 | tail -n 1)
TZ=UTC0 git log $prevTag..$latestTag --date=format-local:"%Y-%m-%d %H:%M:%S"  --pretty=format:"%ad,%h,%an,%s" | grep -v "Merge branch" | tee /tmp/releaseCommits.csv
now=$(date +"%s")000
i=0
REQUEST_FILE=/tmp/request.json
echo -n "[" > $REQUEST_FILE
while read line; do
  dateStr=$(echo ${line} | cut -d , -f 1)
  hash=$(echo ${line} | cut -d , -f 2)
  user=$(echo ${line} | cut -d , -f 3)
  comment=$(echo ${line} | cut -d , -f 4)

  # 処理内容をここに記載
  committedAt=$(date -d "$dateStr" +"%s")000
  # $colX で読み込んだCSVファイルのテキストを参照
  if [[ "$i" -gt "0" ]]; then
    echo -n "," >> $REQUEST_FILE
  fi
  echo -n '{"eventType":"DevOps4KeysLeadTime","committedAt":'$committedAt',"deployedAt":'$now',"duration":'$((now - committedAt))',"hash":"'$hash'","contributor":"'$user'", "comment":"'$comment'", "version": "'$latestTag'"}' >> $REQUEST_FILE
  i=$((i+1))
done < "/tmp/releaseCommits.csv"
echo -n "]" >> $REQUEST_FILE
cat $REQUEST_FILE

gzip -c $REQUEST_FILE | curl -X POST -H "Content-Type: application/json" \
-H "Api-Key: $NEW_RELIC_LICENSE_KEY" -H "Content-Encoding: gzip" \
https://insights-collector.newrelic.com/v1/accounts/$NEW_RELIC_ACCOUNT_ID/events --data-binary @-