#!/bin/sh

# Create the index in elastic search
curl -s -X PUT localhost:8675/try_cloaked_search/

# Configure the parallelism of the index
NUM_THREADS=10

# Break the input up into individual wikipedia articles
# Then call curl to index for up to NUM_THREADS at a time
echo "Num indexed: "
tr "\n" "\0" < ./wikipedia-articles-1000-1.json | \
  xargs -0 -S 20000 -E "\n" -n 1 -P$NUM_THREADS -I '{}' \
  curl -s -X POST -H Content-Type:application/json http://localhost:8675/try_cloaked_search/_doc -d '{}' | \
  grep -o seq_no | wc -l
