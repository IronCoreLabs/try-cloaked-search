#!/usr/bin/env bash

function usage () {
  echo "Makes queries to a local version of the search service."
  echo "Usage:"
  echo " $0 [query]"
  echo ""
  echo "Ex:"
  echo "  $0 \"+tenant_id.keyword:tenant-1 AND title:fred\""
  exit 1
}

if [ $# -ne 1 ] ; then
  usage
fi

curl -s -G --data-urlencode "q=$1" "localhost:9200/try_cloaked_search/_search"
