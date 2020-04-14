Retrieving Cloudflare logs via [Logpull API][logpull] with [feron][feron], and pushing them
into Elasticsearch with [Filebeat][filebeat].

![Docker Pulls](https://img.shields.io/docker/pulls/anapsix/get-cloudflare-logs?style=flat-square) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/anapsix/get-cloudflare-logs?style=flat-square)


## Helm Chart

The whole shebang can be installed onto K8s cluster with included [Helm chart][helm-chart].


## Local Development

### Build

```sh
docker build -t get-logs .
```

### Launch

> Before launching, make sure to set your CF credentials as environment variables
> ```
> export CF_ZONE_ID=51e241f08e014feb95d1b2760228d12a
> export CF_AUTH_EMAIL=admin@example.com
> export CF_AUTH_KEY=51e241f08e014feb95d1b2760228d12a2df50
> ```
> or modify [`docker-compose.yaml`][docker-compose.yaml] appropriately (see docs on [`env_file`][compose-env-file], and [`environment`][compose-environment] usage)

After launching local environment, access Kibana via http://localhost:5601/app/kibana#/discover.


#### With Docker Compose

```sh
# launch Elasticsearch, Kibana, and get-logs container instances
docker-compose up -d

# keep an eye on the logs
docker-compose logs -f get-logs
```

#### Launch manually

```sh
# launch Elasticsearch container instance
docker run -d \
  --name es \
  -p 9200:9200 \
  -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.6.2

# launch Kibana container instance
docker run -d \
  --name ki \
  -p 5601:5601 \
  --link es:elasticsearch \
  docker.elastic.co/kibana/kibana:7.6.2

# launch Cloudflare Logpull container instance
docker run -it --rm \
  -e CF_AUTH_EMAIL \
  -e CF_AUTH_KEY \
  -e CF_ZONE_ID \
  -e SAMPLE_RATE="0.01" \
  -e ES_HOST="http://elasticsearch:9200" \
  -e ES_INDEX="cloudflare-test" \
  -e ES_INDEX_SHARD=6 \
  -e ES_INDEX_REPLICAS=0 \
  -e ES_INDEX_REFRESH=10s \
  --link es:elasticsearch \
  get-logs
```


## License

Open-sourced software licensed under the MIT license.


## Acknowledgments

This repo includes and relies on [go-tasks][go-tasks], created by [Martin Fabrizzio Vilche][mvilche]

[link reference]::
[logpull]: https://developers.cloudflare.com/logs/logpull-api/
[filebeat]: https://www.elastic.co/guide/en/beats/filebeat/master/filebeat-overview.html
[compose-env-file]: https://docs.docker.com/compose/compose-file/#env_file
[compose-environment]: https://docs.docker.com/compose/compose-file/#environment
[docker-compose.yaml]: ./docker-compose.yaml
[helm-chart]: ./helm
[feron]: https://github.com/anapsix/feron/
[go-tasks]: https://github.com/mvilche/go-tasks
[mvilche]: https://github.com/mvilche
