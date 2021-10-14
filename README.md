# Try Cloaked Search (in ~5 Minutes)

_Note: This example install uses ports 9200 (Elasticsearch/OpenSearch) and 8675 (Cloaked Search). Be sure you don't have an existing search service running on port 9200 before beginning._

```bash
docker-compose -f elastic-search/docker-compose.yml up # for elastic search
```

or

```bash
docker-compose -f open-search/docker-compose.yml up # for open search
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

_Note that all queries made with `./query-search-service.sh` are being made directly to your search service. We are using a script to detect if you're running open search or elastic search, but there is no involvement from cloaked search. Since these requests go directly to the search service (port 9200) so we can see what's actually stored._

Let's get all the documents belonging to `tenant-1` and see what's in the index!

```bash
./query-search-service.sh "+tenant_id:"tenant-1""
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
./query-search-service.sh "title:list"
```

## Querying Protected Fields

### Sample Queries

These are a couple examples of simple term queries. They are still querying on the `title` field, which is unprotected.

```bash
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND title:Japan'
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND title:cup'
```

Compare these results to the ones returned by querying Elasticsearch directly. The same documents are returned, but the contents are much different.
You can see how Cloaked Search transparently handles the decryption of the document to allow you to see the data in the fields that were protected, `summary` and `body`.

```bash
./query-search-service.sh '+tenant_id:"tenant-1" AND title:Japan'
./query-search-service.sh '+tenant_id:"tenant-1" AND title:cup'
```

Now try querying on a protected field:

```bash
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND summary:glasgow'
```

Term queries can also be combined with ORs or ANDs, and you can mix protected and unprotected fields. For example,

```bash
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND (title:cup OR title:Japan)'
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND (summary:cup OR title:Japan)'
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND (summary:cup OR body:Japan)'
```

Phrases can also be searched using quoted queries like this:

```bash
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND summary:"Cheerleading in Japan"'
```

Finally, here is an example of a prefix query:

```bash
./query-cloaked-search.sh '+tenant_id:"tenant-1" AND summary:list*'
```

You can replace the query with anything you like. Make sure you leave the `tenant_id` portion.
We currently support a subset of the search service's query language, but are continuing to add support.

## Next Steps

You will want to try out Cloaked Search on some of your own data in a more real environment.

Use the [Kubernetes template](kubernetes) in this repository to make a simple Kubernetes deployment.

See the [configuration docs](https://ironcorelabs.com/docs/saas-shield/cloaked-search/configuration/) for info on how to configure and deploy Cloaked Search.

If you are interested in the underlying technology or in the security of the underlying search service index, see the [What Is Encrypted Search](https://ironcorelabs.com/docs/saas-shield/cloaked-search/what-is-encrypted-search/) page.
