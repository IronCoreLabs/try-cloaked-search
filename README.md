# Try Cloaked Search (in ~5 Minutes)

Cloaked Search is a proxy for Elasticsearch/OpenSearch that protects the indexed data from prying eyes. Cloaked Search's API is the same as the underlying search service API.

In about 5 minutes, you will have:

- Elasticsearch/OpenSearch running on your local machine
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

### Start Cloaked Search and a search service

_Note: This example install uses ports 9200 (Elasticsearch/OpenSearch) and 8675 (Cloaked Search). Be sure you don't have an existing search service running on port 9200 before beginning._

```bash
docker-compose -f elasticsearch/docker-compose.yml up # for Elasticsearch
```

or

```bash
docker-compose -f open-search/docker-compose.yml up # for Open Search
```

**Note: Future commands will be targeting Cloaked Search on port 8675**

## Indexing

`try-cloaked-search` includes some test data. Since Cloaked Search uses a different key per (tenant, index, field),
documents with protected fields must be tagged with the tenant to which they belong.
Half of the articles in the test dataset are associated with `tenant-1`, and the other half are associated with `tenant-2`.
To better understand Cloaked Search's key management, refer to the [configuration documentation](https://ironcorelabs.com/docs/saas-shield/cloaked-search/configuration).

```bash
./populate_index.sh
```

### (Optional) Look at an encrypted index

_Note that all queries made with `./query-search-service.sh` are being made directly to your search service. We are using a script to detect if you're running OpenSearch or Elasticsearch, but there is no involvement from Cloaked Search. Since these requests go directly to the search service (port 9200), we can see what's actually stored._

Let's get all the documents belonging to `tenant-1` and see what's in the index!

```bash
./query-search-service.sh '+tenant_id.keyword:"tenant-1"' | jq
```

We are protecting the `body` and `summary` fields from the original document. These fields are no longer attached to the document;
instead, the blind index tokens for `body` are stored in the `_icl_p_body`. Because we enabled `index_prefixes` for the `summary` field,
it has been translated to `_icl_p_summary._value` and `_icl_p_summary._index_prefix`.
You will also notice an `_icl_encrypted_source` field; this contains an encrypted version of the fields that have been protected, which allows Cloaked Search
to return them to their original versions.

```json
"_icl_p_summary": "7b76c95a 616544a2 b41fa81e 85933317 e30236d5 ...",
```

## Querying Protected Fields

### Sample Queries

These are a couple examples of simple term queries. They are still querying on the `title` field, which is unprotected.

```bash
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND title:Japan' | jq
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND title:cup' | jq
```

Compare these results to the ones returned by querying the search service directly. The same documents are returned, but the contents are very different.
You can see how Cloaked Search transparently handles the decryption of the document to allow you to see the data in the fields that were protected, `summary` and `body`.

```bash
./query-search-service.sh '+tenant_id.keyword:"tenant-1" AND title:Japan' | jq
./query-search-service.sh '+tenant_id.keyword:"tenant-1" AND title:cup' | jq
```

Now try querying on a protected field:

```bash
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND summary:glasgow' | jq
```

Queries can also be combined with ORs or ANDs, and you can mix protected and unprotected fields. For example,

```bash
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND (title:cup OR title:Japan)' | jq
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND (summary:cup OR title:Japan)' | jq
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND (summary:cup OR body:Japan)' | jq
```

Phrases can also be searched using quoted queries like this:

```bash
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND summary:"Cheerleading in Japan"' | jq
```

Finally, here is an example of a prefix query on the `summary` field (the field with `index_prefixes` enabled):

```bash
./query-cloaked-search.sh '+tenant_id.keyword:"tenant-1" AND summary:pro*' | jq
```

You can replace the query with anything you like. Make sure you have the `+tenant_id.keyword` in the query. `populate_index.sh` loaded 1000 documents, half are tagged with `tenant-1` and the others are tagged with `tenant-2`.

### JSON queries

Cloaked Search also supports requests other than Query String queries. For example,

```bash
./query-cloaked-search-json.sh 'japan' 'tenant-1' | jq
```

This searches for `Japan` in the protected `summary` field over all the documents belonging to `tenant-1`.

## Next Steps

You will want to try out Cloaked Search on some of your own data in a more real environment.

Use the [Kubernetes template](kubernetes) in this repository to make a simple Kubernetes deployment.

See the [configuration docs](https://ironcorelabs.com/docs/saas-shield/cloaked-search/configuration/) for info on how to configure and deploy Cloaked Search.

If you are interested in the underlying technology or in the security of the underlying search service index, see the [What Is Encrypted Search](https://ironcorelabs.com/docs/saas-shield/cloaked-search/what-is-encrypted-search/) page.
