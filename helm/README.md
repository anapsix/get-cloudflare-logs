# Feron / Get-Cloudflare-Logs Helm chart

> NOTE: tested with Helm 3

## Installing the Chart

Pre-create namespace you are planning on installing this chart into.

To install the chart with the release name `my-release` (i.e. `${CF_ZONE_NAME}`):

```sh
helm install my-release \
  --namespace=get-cloudflare-logs \
  --set config.cloudflare.zoneId="${CF_ZONE_ID}" \
  --set config.cloudflare.authEmail="${CF_AUTH_EMAIL}" \
  --set config.cloudflare.authKey="${CF_AUTH_KEY}" \
  --set config.elasticsearch.host="${ES_HOST}" \
  --set config.elasticsearch.username="${ES_USERNAME}" \
  --set config.elasticsearch.password="${ES_PASSWORD}" \
  --set config.elasticsearch.index.name="cloudflare-${CF_ZONE_NAME}" \
  --set config.elasticsearch.index.shards=5 \
  --set config.elasticsearch.index.replicas=0 \
  --set config.elasticsearch.index.refreshInterval=30s \
  .
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

## Configuration

 Parameter                      | Description                            | Default
------------------------------- | -------------------------------------- | ---------
`image.pullPolicy`              | Image pull policy                      | `Always`
`image.repository`              | Image repository                       | `docker.io/anapsix/get-cloudflare-logs`
`image.tag`                     | Image tag                              | `v0.2.1` (same as `.Chart.AppVersion`)
`image.pullSecrets`             | Specify image pull secrets             | `[]`
`terminationGracePeriodSeconds` | Termination grace period (in seconds)  | `15`
`revisionHistoryLimit`          | How many old ReplicaSets for this Deployment you want to retain | `10`
`affinity`                      | Node/pod affinities                    | `{}`
`nodeSelector`                  | Node labels for pod assignment         | `{}`
`resources`                     | Pod resource requests & limits         | `{}`
`tolerations`                   | List of node taints to tolerate        | `[]`
`config.sampleRate`             | CF logs sample rate (0.01 = 1%)        | `0.01`
`config.cloudflare.zoneId`      | CF Zone ID to pull logs for            | `51e241f08e014feb95d1b2760228d12a` (fake)
`config.cloudflare.authEmail`   | CF Auth Email                          | `admin@example.com` (fake)
`config.cloudflare.authKey`     | CF Auth Key                            | `51e241f08e014feb95d1b2760228d12a2df50` (fake)
`config.elasticsearch.host`     | Elasticsearch host URL                 | `http://elasticsearch:9200`
`config.elasticsearch.username` | Elasticsearch connection username      | `nil`
`config.elasticsearch.password` | Elasticsearch connection password      | `nil`
`config.elasticsearch.index.name`     | Elasticsearch dst index          | `cloudflare-access`
`config.elasticsearch.index.shards`   | Elasticsearch dst index shards   | `5`
`config.elasticsearch.index.replicas` | Elasticsearch dst index replicas | `0`
`config.elasticsearch.index.refreshInterval` | Elasticsearch dst index refresh interval | `5s`
