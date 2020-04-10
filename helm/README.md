TODO: add attribute descriptions from [values.yaml](./values.yaml),
in the meantime, see [values.yaml](./values.yaml)

> NOTE: tested with Helm 3

## Installing the Chart

Pre-create namespace you are planning on installing this chart into.

```sh
helm3 install ${CF_ZONE_NAME} \
  --namespace=get-cloudflare-logs \
  --set config.cloudflare.zoneId=${CF_ZONE_ID} \
  --set config.cloudflare.authEmail=${CF_AUTH_EMAIL} \
  --set config.cloudflare.authKey=${CF_AUTH_KEY} \
  --set config.elasticsearch.host="${ES_HOST}" \
  --set config.elasticsearch.username=${ES_USERNAME} \
  --set config.elasticsearch.password=${ES_PASSWORD} \
  --set config.elasticsearch.index.name="cloudflare-${CF_ZONE_NAME}" \
  --set config.elasticsearch.index.shards=5 \
  --set config.elasticsearch.index.replicas=0 \
  --set config.elasticsearch.index.refreshInterval=30s \
  .
```
