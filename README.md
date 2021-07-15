## Try Cloaked Search (in ~5 Minutes)

Cloaked Search is a proxy for Elasticsearch that protects the indexed data from prying eyes. Cloaked Search's API is the same as the underlying Elasticsearch API.

In about 5 minutes, you will have:
* Elasticsearch running on your local machine
* Cloaked Search running on your local machine
* sample data indexed with `title` as a protected field
* query results from sample queries using the protected `title` field

All stored data is on a temporary volume inside of docker. No changes will be made your machine beyond `try-cloaked-search` repo.

## Dependencies

To try Cloaked Search you just need a basic *nix installation and `docker` + `docker-compose`. Some of the commands below also use `jq` for JSON formatting. If you don't have `jq`, you can safely remove those portions of the command.

## Get Cloaked Search Running

Clone the [try-cloaked-search](https://github.com/IronCoreLabs/try-cloaked-search) git repo.

```bash
git clone https://github.com/IronCoreLabs/try-cloaked-search.git
```

All other commands are assumed be run from within the cloned repo.

### Start Cloaked Search and Elasticsearch

_Note: This example install uses ports 9200 (Elasticsearch) and 8675 (Cloaked Search). Be sure you don't have an existing Elasticsearch running on port 9200 before beginning._

```bash
docker-compose up
```

**Note: Future commands will be targeting Cloaked Search on port 8675**

## Indexing

`try-cloaked-search` includes some test data. Since Cloaked Search uses a different key per (tenant, index, field), documents with protected fields must be tagged with the tenant they belong to. Half of the articles in the test dataset are associated with `tenant-1`, and the other half are not associated with any tenant. Only documents belonging to `tenant-1` will be encrypted. To better understand Cloaked Search's key management, refer to the [configuration documentation](/docs/saas-shield/cloaked-search/configuration).

```bash
./populate_index.sh
```

### (optional) Look at an encrypted index

_Note that we are making this request directly to Elasticsearch (port 9200) so we can see what's actually stored._

Let's get all the documents belonging to `tenant-1` and see what's in the index!

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\"" localhost:9200/try_cloaked_search/_search | jq
```

We are protecting the `title` field from the original document. `title` is no longer attached to the document, and the blind tokens for `title` are stored in a `protected_title` field. You will also notice an `_encrypted_source` field that allows Cloaked Search to return the original versions of any protected fields.

```
"protected_title": "994F058B 4FDFCA73 3EDFFA5E A8BE4DB0 91518C0A",
```

The data not associated with any tenant is readable in the clear. If we do a very generic query, some documents with no tenant will come back.

```bash
curl -s -G --data-urlencode "q=title:list" localhost:9200/try_cloaked_search/_search | jq
```

## Querying Protected Fields

### Sample Queries

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND title:Japan" localhost:8675/try_cloaked_search/_search | jq
```

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND title:cup" localhost:8675/try_cloaked_search/_search | jq
```

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND (title:cup OR title:Japan)" localhost:8675/try_cloaked_search/_search | jq
```

You can replace the query with anything you like. Make sure you leave the `tenant_id` portion.
We currently support a subset of Elasticsearch's query language, but are continuing to add support. 

## Next Steps
You will want to try out Cloaked Search on some of your own data in a more real environment.

See the [configuration docs](https://ironcorelabs.com/docs/saas-shield/cloaked-search/configuration/) for info on how to configure and deploy Cloaked Search.

If you are interested in the underlying technology, or the security of the underlying Elasticsearch index, see the [What Is Encrypted Search](https://ironcorelabs.com/docs/saas-shield/cloaked-search/what-is-encrypted-search/) page.
