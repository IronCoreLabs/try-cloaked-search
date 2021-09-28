# Try Cloaked Search (in ~5 Minutes)

Cloaked Search is a proxy for Elasticsearch that protects the indexed data from prying eyes. Cloaked Search's API is the same as the underlying Elasticsearch API.

In about 5 minutes, you will have:

- Elasticsearch running on your local machine
- Cloaked Search running on your local machine
- sample data indexed with `summary` and `body` as protected fields
- query results from sample queries using the protected `summary` and `body` fields

All stored data is on a temporary volume inside of docker. No changes will be made to your machine outside the directory where you cloned the `try-cloaked-search` repo.

## Dependencies

To try Cloaked Search you just need a basic \*nix installation and `docker` + `docker-compose`. Some of the commands below also use `jq` for JSON formatting. If you don't have `jq`, you can safely remove those portions of the command.

## Get Cloaked Search Running

Clone the [try-cloaked-search](https://github.com/IronCoreLabs/try-cloaked-search) git repo.

```bash
git clone https://github.com/IronCoreLabs/try-cloaked-search.git
```

All other commands are assumed be run from within directory where you cloned the repo.

### Start Cloaked Search and Elasticsearch

_Note: This example install uses ports 9200 (Elasticsearch) and 8675 (Cloaked Search). Be sure you don't have an existing Elasticsearch running on port 9200 before beginning._

```bash
docker-compose up
```

**Note: Future commands will be targeting Cloaked Search on port 8675**

## Indexing

`try-cloaked-search` includes some test data. Since Cloaked Search uses a different key per (tenant, index, field),
documents with protected fields must be tagged with the tenant to which they belong.
Half of the articles in the test dataset are associated with `tenant-1`, and the other half are not associated with any tenant.
Only documents belonging to `tenant-1` will be encrypted. To better understand Cloaked Search's key management, refer to the
[configuration documentation](https://ironcorelabs.com/docs/saas-shield/cloaked-search/configuration).

```bash
./populate_index.sh
```

### (optional) Look at an encrypted index

_Note that we are making this request directly to Elasticsearch (port 9200) so we can see what's actually stored._

Let's get all the documents belonging to `tenant-1` and see what's in the index!

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\"" localhost:9200/try_cloaked_search/_search | jq
```

We are protecting the `body` and `summary` fields from the original document. These fields are no longer attached to the document;
instead, the blind index tokens for `body` and `summary` are stored in the `protected_body` and `protected_summary` fields, respectively.
You will also notice an `_encrypted_source` field; this contains an encrypted version of the entire document, which allows Cloaked Search
to return the original versions of any protected fields.

```
"protected_summary": "7B76C95A 616544A2 B41FA81E 85933317 E30236D5 ...",
```

The data not associated with any tenant is readable in the clear. If we do a very generic query, some documents with no tenant will come back.

```bash
curl -s -G --data-urlencode "q=title:list" localhost:9200/try_cloaked_search/_search | jq
```

## Querying Protected Fields

### Sample Queries

These are a couple examples of simple term queries. They are still querying on the `title` field, which is unprotected.

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND title:Japan" localhost:8675/try_cloaked_search/_search | jq
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND title:cup" localhost:8675/try_cloaked_search/_search | jq
```

Compare these results to the ones returned by querying Elasticsearch directly. The same documents are returned, but the contents are much different.
You can see how Cloaked Search transparently handles the decryption of the document to allow you to see the data in the fields that were protected, `summary` and `body`.

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND title:Japan" localhost:9200/try_cloaked_search/_search | jq
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND title:cup" localhost:9200/try_cloaked_search/_search | jq
```

Now try querying on a protected field:

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND summary:glasgow" localhost:8675/try_cloaked_search/_search | jq
```

Term queries can also be combined with ORs or ANDs, and you can mix protected and unprotected fields. For example,

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND (title:cup OR title:Japan)" localhost:8675/try_cloaked_search/_search | jq
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND (summary:cup OR title:Japan)" localhost:8675/try_cloaked_search/_search | jq
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND (summary:cup OR body:Japan)" localhost:8675/try_cloaked_search/_search | jq
```

Phrases can also be searched using quoted queries like this:

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND summary:\"Cheerleading in Japan\"" localhost:8675/try_cloaked_search/_search | jq
```

Finally, here is an example of a prefix query:

```bash
curl -s -G --data-urlencode "q=+tenant_id:\"tenant-1\" AND summary:list*" localhost:8675/try_cloaked_search/_search | jq
```

You can replace the query with anything you like. Make sure you leave the `tenant_id` portion.
We currently support a subset of Elasticsearch's query language, but are continuing to add support.

## Next Steps

You will want to try out Cloaked Search on some of your own data in a more real environment.

Use the [Kubernetes template](kubernetes) in this repository to make a simple Kubernetes deployment.

See the [configuration docs](https://ironcorelabs.com/docs/saas-shield/cloaked-search/configuration/) for info on how to configure and deploy Cloaked Search.

If you are interested in the underlying technology or in the security of the underlying Elasticsearch index, see the [What Is Encrypted Search](https://ironcorelabs.com/docs/saas-shield/cloaked-search/what-is-encrypted-search/) page.
