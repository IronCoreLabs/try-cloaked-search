#!/usr/bin/env bash
xargs_c='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   xargs_c='xargs'
elif [[ "$unamestr" == 'FreeBSD' || "$unamestr" == 'Darwin' ]]; then
   xargs_c='xargs -S 20000'
else
   echo "Unknown platform"
   exit 2
fi

# Create the index in the search service
curl -u admin:admin\
  --request PUT \
  --url http://localhost:8675/try_cloaked_search \
  --header 'Content-Type: application/json' \
  --data '{
    "mappings": {
      "dynamic_templates": [
        {
          "protected_fields": {
            "match_mapping_type": "string",
            "path_match": "*_icl_p_*",
            "mapping": {
              "type": "text"
            }
          }
        }
      ],
      "properties": {
        "_icl_encrypted_source": { "enabled": false },
        "_icl_search_key_id": { "type": "keyword" }
      }
    }
  }'

# Configure the parallelism of the index
NUM_THREADS=5

# Break the input up into individual wikipedia articles
# Then call curl to index for up to NUM_THREADS at a time
echo ""
echo "Num indexed: "
tr \\n \\0 < wikipedia-articles-1000-1.json | $xargs_c -0 -P$NUM_THREADS -I '{}' curl -u admin:admin -s -X POST -H Content-Type:application/json http://localhost:8675/try_cloaked_search/_doc -d '{}' | grep -o seq_no | wc -l
