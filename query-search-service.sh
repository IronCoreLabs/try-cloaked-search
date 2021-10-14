#!/bin/bash
#Checks to see if we're running opensearch, which requires https and a user
is_opensearch() {
    (curl -s --insecure -u admin:admin https://localhost:9200/_cluster/health 2>&1 > /dev/null)
    echo $?
}
should_https=$(is_opensearch)
function usage () {
  echo "Makes queries to a local version of the search service."
  echo "Usage:"
  echo " $0 [query]"
  echo ""
  echo "Ex:"
  echo "  $0 \"+tenant_id:tenant-1 AND title:fred\""
  exit 1
}

if [ $# -ne 1 ] ; then
  usage
fi

if [[ $should_https == "0" ]] ; then
  curl -s --insecure -u admin:admin -G --data-urlencode "q=$1" "https://localhost:9200/try_cloaked_search/_search"
else
  curl -s -G --data-urlencode "q=$1" "localhost:9200/try_cloaked_search/_search"
fi
