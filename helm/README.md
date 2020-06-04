# Feron / Get-Cloudflare-Logs Helm chart

> NOTE: tested with Helm 3

## Installing the Chart

Pre-create namespace you are planning on installing this chart into.

To install the chart with the release name `my-release` (i.e. `${CF_ZONE_NAME}`):

```sh
helm install my-release \
  --namespace=get-cloudflare-logs \
  --set config.cloudflare.sampleRate="0.01" \
  --set config.cloudflare.zoneId="${CF_ZONE_ID}" \
  --set config.cloudflare.authEmail="${CF_AUTH_EMAIL}" \
  --set config.cloudflare.authKey="${CF_AUTH_KEY}" \
  --set config.elasticsearch.host="${ES_HOST}" \
  --set config.elasticsearch.username="${ES_USERNAME}" \
  --set config.elasticsearch.password="${ES_PASSWORD}" \
  --set config.elasticsearch.index.name="cloudflare-${CF_ZONE_NAME}" \
  --set config.elasticsearch.index.template.shards=5 \
  --set config.elasticsearch.index.template.replicas=0 \
  --set config.elasticsearch.index.template.refreshInterval=30s \
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
`image.tag`                     | Image tag                              | `0.6.0` (same as `.Chart.AppVersion`)
`image.pullSecrets`             | Specify image pull secrets             | `[]`
`terminationGracePeriodSeconds` | Termination grace period (in seconds)  | `15`
`revisionHistoryLimit`          | How many old ReplicaSets for this Deployment you want to retain | `10`
`affinity`                      | Node/pod affinities                    | `{}`
`nodeSelector`                  | Node labels for pod assignment         | `{}`
`resources`                     | Pod resource requests & limits         | `{}`
`tolerations`                   | List of node taints to tolerate        | `[]`
`config.cloudflare.sampleRate`  | CF logs sample rate (0.01 = 1%)        | `0.01`
`config.cloudflare.zoneId`      | CF Zone ID to pull logs for            | `51e241f08e014feb95d1b2760228d12a` (fake)
`config.cloudflare.authEmail`   | CF Auth Email                          | `admin@example.com` (fake)
`config.cloudflare.authKey`     | CF Auth Key                            | `51e241f08e014feb95d1b2760228d12a2df50` (fake)
`config.elasticsearch.host`     | Elasticsearch host URL                 | `http://elasticsearch:9200`
`config.elasticsearch.username` | Elasticsearch connection username      | `nil`
`config.elasticsearch.password` | Elasticsearch connection password      | `nil`
`config.elasticsearch.index.name`     | Elasticsearch dst index          | `cloudflare-access`
`config.elasticsearch.index.template.shards`   | Elasticsearch dst index shards   | `5`
`config.elasticsearch.index.template.replicas` | Elasticsearch dst index replicas | `0`
`config.elasticsearch.index.template.refreshInterval` | Elasticsearch dst index refresh interval | `10s`
`config.elasticsearch.ilm.enabled`      | Enables ILM use | `true`
`config.elasticsearch.ilm.policyYAML`   | Specifies policy via YAML | see [`values.yaml`][values]
`config.elasticsearch.ilm.policyJSON`   | Specifies policy via literal JSON | see [`values.yaml`][values]
`config.elasticsearch.ilm.policyFile`   | Specifies a file on local filesystem to use as ILM policy | `files/ilm-default-policy.json`
`config.elasticsearch.pipeline.enabled` | Enables Ingest Pipeline | `true` (at the moment, has no effect)
`config.elasticsearch.pipeline.default` | Enables use of default Ingest Pipeline | `true`


## Advanced Configuration

### ILM Policy

By default, ILM policy setup is enabled, and policy defined with
`config.elasticsearch.ilm.policyYAML` (same as one included in Docker image)
will be used.
To customize ILM policy, change `config.elasticsearch.ilm.policyYAML`.

> ILM policy is stored as ConfigMap, and passed to the pods via read-only mount.
> It is mounted under `/opt/extra-config/ilm-policy.json` inside the pod.

ILM policy can be defined using any of the following attributes, listed in the
order of precedence.
- `config.elasticsearch.ilm.policyYAML` - inline, convenient for tweaking individual phases
- `config.elasticsearch.ilm.policyJSON` - inline, convenient when copying from ES
- `config.elasticsearch.ilm.policyFile` - from local file, convenient when copying from ES

If `policyYAML` is unset, or evaluates to `false`, `policyJSON` will be used.
If both `policyYAML`, and `policyJSON` are unset, or evaluate to `false`,
`policyFile` will be used


Read more about ILM and ILM policy in [Elasticsearch docs][ilm-docs].

### Ingest Pipeline

By default, Ingest Pipeline included in Docker image is created, and enabled as
["default pipeline"][index-docs]. Read more about Pipelines and pipeline
processors in [Elasticsearch docs][pipeline-docs].

Default pipeline is configured with following processors:
- `user_agent` - to process `cloudflare.ClientRequestUserAgent`
- `geoip` - to process `cloudflare.ClientIP`



[ link reference ]::
[ilm-docs]: https://www.elastic.co/guide/en/elasticsearch/reference/current/index-lifecycle-management.html
[pipeline-docs]: https://www.elastic.co/guide/en/elasticsearch/reference/current/pipeline.html
[index-docs]: https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#dynamic-index-settings
[values]: ./values.yaml
