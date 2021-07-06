# Try Encrypted Search

Please see the getting started steps and explanations at https://ironcorelabs.com/docs/saas-shield/encrypta/try-encrypta/

## Quick Start for the Impatient

Get things started by running the following two commands from this repo's directory but in separate terminal windows:

```
docker compose up
./populate_index.sh
```

Then play with the shell scripts to see what happens with commands like this:

```
# View the encrypted fields with "cup" in the title
./query_encrypted_docs.sh title:cup |grep title.:

# View the unencrypted fields with "cup" in the title
./query_unencrypted_docs.sh title:cup |grep title.:

# View unencrypted docs directly from elasticsearch
./peek_index.sh title:cup |grep title.:

# View mix of encrypted and unencrypted docs directly from elasticsearch
./peek_index.sh summary:cup |grep title.:
```

Note: the summary for document with ID "GO2jfXoBbx-yxGP8Hyrb" differs from its title and doesn't have the word "cup" in it ("1989 Women's European Cricket" without the trailing "Cup" on the end), which is why that result doesn't show up when peeking in the index and searching by the summary field.

## Files In This Repo

* Setup
    * **README.md** -- this file
    * **docker-compose.yml** -- used by `docker compose up` to setup a basic elasticsearch service and encrypted search proxy that can talk to each other
    * **populate_index.sh** -- will add the 1000 sample wikipedia articles to the search server and encrypt the titles of ones with tenant_ids
    * **try-encrypta-conf.yml** -- specifies the fields to encrypt and is mounted into the search proxy's container
    * **wikipedia-articles-1000-1.json** -- the source for the documents populated into the index
* Querying
    * **query_encrypted_docs.sh** -- will set the tenant-id to 1 and pass through queries with title fields encrypted
    * **query_unencrypted_docs.sh** -- will set the tenant-id to anything but tenant-1; queries not encrypted
    * **peek_index.sh** -- will query elasticsearch directly so you can see the what's stored
    * **query.sh** -- building block for the above and may be used to make advanced queries
* Cleanup
    * **delete_index.sh** -- will reset the search service to remove the index (restarting the containers will do the same, but this is faster)

## Next Steps

* Play with the curl commands directly
* Use your own data source
* Encrypt more fields
* Add more tenants
* Give us feedback, make feature requests, or report bugs by adding an issue in our Github

