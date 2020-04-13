Test Pipeline with following

```
POST _ingest/pipeline/cloudflare/_simulate
{ "docs" : [{
  "_index": "cloudflare-test",
  "_id": "id",
  "_source": {
    "cloudflare": {
      "ClientIP":"8.8.8.8",
      "ClientRequestUserAgent":"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:75.0) Gecko/20100101 Firefox/75.0"
    }
  }
}]}
```
