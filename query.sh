#!/bin/sh

function usage () {
  echo "Usage:"
  echo " $0 [query]"
  echo ""
  echo "Ex:"
  echo "  $0 \"tenant_id:tenant-1 AND title:fred\""
  echo "  $0 \"-tenant_id:tenant-1 AND title:fred\""
  echo ""
  echo "Queries through the proxy by default. Set PORT to redirect."
  exit 1
}

if [ $# -ne 1 ] ; then
  usage
fi

if [ -z "$PORT" ] ; then
  PORT=8675
fi

echo "Query being made:"
echo "curl -s -G --data-urlencode \"q=$1\" \"localhost:$PORT/try_cloaked_search/_search?size=1000\""

if type jq >/dev/null 2>&1 ; then
  curl -s -G --data-urlencode "q=$1" "localhost:$PORT/try_cloaked_search/_search?size=1000" | jq 
else
  curl -s -G --data-urlencode "q=$1" "localhost:$PORT/try_cloaked_search/_search?size=1000&pretty"
fi
