#!/bin/sh

function usage () {
  echo "Usage:"
  echo " $0 [query]"
  echo ""
  echo "Ex:"
  echo "  $0 title:Japan"
  exit 1
}

if [ $# -ne 1 ] ; then
  usage
fi

./query.sh "tenant_id:tenant-1 AND ($1)"

