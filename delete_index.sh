#!/bin/sh

# Delete the test index in elastic search
curl -s -X DELETE "localhost:8675/try_cloaked-search/?pretty"

