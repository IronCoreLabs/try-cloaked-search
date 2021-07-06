#!/bin/sh

function usage () {
  echo "Usage:"
  echo " $0 [query]"
  echo ""
  echo "Ex:"
  echo "  Encrypted Titles: $0 tenant_id:tenant-1 |grep title.:"
  echo "  Unencrypted Titles: $0 -tenant_id:tenant-1 |grep title.:"
  exit 1
}

if [ $# -ne 1 ] ; then
  usage
fi

PORT=9200 ./query.sh "$1"

