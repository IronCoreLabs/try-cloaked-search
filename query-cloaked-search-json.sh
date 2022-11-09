#!/bin/bash

function usage () {
  echo "Makes queries to a local version of the Cloaked Search proxy using the JSON syntax."
  echo "Searches the protected \`summary\` field using the provided query and tenant_id."
  echo "Usage:"
  echo " $0 [query] [tenant_id]"
  echo ""
  echo "Ex:"
  echo "  $0 japan tenant-1"
  exit 1
}

if [ $# -ne 2 ] ; then
  usage
fi

curl --url http://localhost:8675/try_cloaked_search/_search --header 'Content-Type: application/json' \
--data \
"{
  \"query\": {
    \"bool\": {
      \"must\": {
        \"match\": { \"summary\": \"$1\" }
      },
      \"filter\": { \"term\": { \"tenant_id.keyword\":\"$2\" } }
    }
  }
}"
