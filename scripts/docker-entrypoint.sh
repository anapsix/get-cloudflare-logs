#!/usr/bin/env bash

set -e
set -u
set -o pipefail

: ${CF_ZONE_ID:?required}
: ${CF_AUTH_EMAIL:?required}
: ${CF_AUTH_KEY:?required}
: ${CF_LOGS_DIRECTORY:='/logs'}

: ${FILEBEAT_USER:=filebeat} # set during docker build
: ${FILEBEAT_CONFIG:='/opt/filebeat/filebeat.yml'}
: ${INDEX_TEMPLATE_FILE:='/opt/filebeat/index-template.json.tpl'}
: ${SAMPLE_RATE:='0.01'}

: ${ES_HOST:='http://elasticsearch:9200'}
: ${ES_USERNAME:='_unset_'}
: ${ES_PASSWORD:='_unset_'}

: ${ES_INDEX:='cloudflare-test'}

: ${ES_TEMPLATE_ENABLED:='true'}
: ${ES_TEMPLATE_OVERWRITE:='true'}
: ${ES_TEMPLATE_INDEX_SHARDS:=6}
: ${ES_TEMPLATE_INDEX_REPLICAS:=0}
: ${ES_TEMPLATE_INDEX_REFRESH:='10s'}

: ${ES_TEMPLATE_JSON_ENABLED:='true'}
: ${ES_TEMPLATE_JSON_FILE:='/opt/filebeat/index-template.json'}

: ${ES_ILM_ENABLED:='true'}
: ${ES_ILM_OVERWRITE:='true'}
: ${ES_ILM_POLICY_FILE:='_unset_'}
: ${ES_ILM_DEFAULT_POLICY_FILE:='/opt/filebeat/ilm-default-policy.json'}
: ${ES_ILM_DEFAULT_POLICY_ENABLED:='true'}

: ${ES_PIPELINE_ENABLED:='true'}
: ${ES_PIPELINE_DEFAULT:='cloudflare'}
: ${ES_PIPELINE_DEFAULT_FILE:='/opt/filebeat/ingest-default-pipeline.json'}
: ${ES_PIPELINE_DEFAULT_ENABLED:='true'}

export TZ='UTC'
export CF_AUTH_EMAIL CF_AUTH_KEY CF_ZONE_ID CF_LOGS_DIRECTORY
export FILEBEAT_CONFIG
export ES_INDEX ES_INDEX_SHARDS ES_INDEX_REPLICAS ES_INDEX_REFRESH

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * ) printf -v o '%%%02x' "'$c" ;;
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

install_pipeline() {
  local ES_CREDENTIALS
  if [[ ! -r "${ES_PIPELINE_DEFAULT_FILE}" ]]; then
    echo >&2 "ERROR: default index pipeline cannot be read at \"${ES_PIPELINE_DEFAULT_FILE}\""
    exit 1
  fi
  if [[ "${ES_USERNAME}" != "_unset_" ]] && [[ "${ES_PASSWORD}" != "_unset_" ]]; then
    ES_CREDENTIALS="$(rawurlencode "${ES_USERNAME}"):$(rawurlencode "${ES_PASSWORD}")@"
  fi
  local ES_URL="${ES_HOST%%/*}//${ES_CREDENTIALS:-}${ES_HOST##*/}/_ingest/pipeline/${ES_PIPELINE_DEFAULT}"
  curl \
    -sS \
    -X PUT \
    -H "Content-Type: application/json" \
    -d @"${ES_PIPELINE_DEFAULT_FILE}" \
    "${ES_URL}"
}

generate_index_template() {
  jq \
    --arg idx "${ES_INDEX}" \
    --arg ip "${ES_INDEX}-*" \
    --arg shards "${ES_TEMPLATE_INDEX_SHARDS}" \
    --arg replicas "${ES_TEMPLATE_INDEX_REPLICAS}" \
    --arg refresh_interval "${ES_TEMPLATE_INDEX_REFRESH}" \
    --arg default_pipeline "${ES_PIPELINE_DEFAULT}" \
    --arg default_pipeline_enabled "${ES_PIPELINE_DEFAULT_ENABLED}" \
    '
    .index_patterns = $ip |
    .settings.index.lifecycle.name = $idx |
    .settings.index.lifecycle.rollover_alias = $idx |
    .settings.index.number_of_shards = $shards |
    .settings.index.number_of_replicas = $replicas |
    .settings.index.refresh_interval = $refresh_interval |
    if ($default_pipeline_enabled == "true") then
      .settings.index.default_pipeline = $default_pipeline
    else
      .
    end' \
    "${INDEX_TEMPLATE_FILE}" \
    > "${ES_TEMPLATE_JSON_FILE}"
}

init_message() {
local start_timestamp="$(date +%s%N)"
sleep 0.3
local end_timestamp="$(date +%s%N)"
cat <<EOM
{
  "CacheCacheStatus": "unknown",
  "CacheResponseBytes": 105964,
  "CacheResponseStatus": 200,
  "CacheTieredFill": false,
  "ClientASN": 15169,
  "ClientCountry": "us",
  "ClientDeviceType": "desktop",
  "ClientIP": "127.0.0.1",
  "ClientIPClass": "noRecord",
  "ClientRequestBytes": 1666,
  "ClientRequestHost": "www.example.com",
  "ClientRequestMethod": "GET",
  "ClientRequestPath": "/index.html",
  "ClientRequestProtocol": "HTTP/1.1",
  "ClientRequestReferer": "https://www.example.com",
  "ClientRequestURI": "/index.html",
  "ClientRequestUserAgent": "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
  "ClientSSLCipher": "AEAD-AES128-GCM-SHA256",
  "ClientSSLProtocol": "TLSv1.3",
  "ClientSrcPort": 45417,
  "ClientXRequestedWith": "test",
  "EdgeColoCode": "XXX",
  "EdgeColoID": 14,
  "EdgeEndTimestamp": 0000000000000000001,
  "EdgePathingOp": "wl",
  "EdgePathingSrc": "macro",
  "EdgePathingStatus": "se",
  "EdgeRateLimitAction": "test",
  "EdgeRateLimitID": 0,
  "EdgeRequestHost": "www.example.com",
  "EdgeResponseBytes": 17304,
  "EdgeResponseCompressionRatio": 0.01,
  "EdgeResponseContentType": "text/html",
  "EdgeResponseStatus": 200,
  "EdgeServerIP": "127.0.0.1",
  "EdgeStartTimestamp": 0000000010000000000,
  "FirewallMatchesActions": [ "simulate", "challenge" ],
  "FirewallMatchesRuleIDs": [ "47b718f2f84149e4a2973d6271c4aa6a", "1cb257e2891d4c108c0a9b527ab2a76d" ],
  "FirewallMatchesSources": [ "firewallRules", "firewallRules" ],
  "OriginIP": "127.0.0.1",
  "OriginResponseBytes": 0,
  "OriginResponseHTTPExpires": "Thu, 01 Jan 1970 01:00:00 GMT",
  "OriginResponseHTTPLastModified": "Thu, 01 Jan 1970 00:00:00 GMT",
  "OriginResponseStatus": 0,
  "OriginResponseTime": 0,
  "OriginSSLProtocol": "unknown",
  "ParentRayID": "00",
  "RayID": "57ed21bc2ef5e1e2",
  "SecurityLevel": "med",
  "WAFAction": "unknown",
  "WAFFlags": "0",
  "WAFMatchedVar": "test",
  "WAFProfile": "unknown",
  "WAFRuleID": "9e13347238744f94959389c168d33cb7",
  "WAFRuleMessage": "test",
  "WorkerCPUTime": 6154,
  "WorkerStatus": "unknown",
  "WorkerSubrequest": false,
  "WorkerSubrequestCount": 1,
  "ZoneID": 111111111
}
EOM
}

setup_cron() {
cat >/etc/crontabs/${FILEBEAT_USER} <<EOF
*/5 * * * *  /usr/local/bin/docker-entrypoint.sh --from-cron
EOF
}

get_logs() {
  local _end_utc="$(date '+%R %D' -d '1 minute ago')"
  local _end_epoch="$(date +%s -d "${_end_utc}")"
  local _start_epoch="$((${_end_epoch}-360))"
  local _suffix="$(date +%F_%H:%M:%S -d "@${_start_epoch}")"
  /usr/local/bin/feron \
    --fields=all \
    --sample="${SAMPLE_RATE}" \
    --start="${_start_epoch}" \
    --end="${_end_epoch}" \
    --exclude-empty \
    > ${CF_LOGS_DIRECTORY}/cloudflare_${_suffix}.log

  /usr/local/bin/get_cloudflare_logs.sh \
    --access-logs \
    --start="@${_start_epoch}" \
    --end="@${_end_epoch}" \
    --sample="${SAMPLE_RATE}" \
    --all-fields \
    > ${CF_LOGS_DIRECTORY}/cloudflare_${_suffix}.log
}

if [[ "${1:-}" == "--from-cron" ]]; then

  set +e ## tolerate errors from this point on
  get_logs
  find ${CF_LOGS_DIRECTORY} -type f -name "cloudflare_*.log" -mmin +5 -delete

else

  if [[ ! -r "${FILEBEAT_CONFIG}" ]]; then
    echo >&2 "ERROR: unable to read filebeat config at \"${FILEBEAT_CONFIG}\", exiting.."
    exit 1
  fi

  if [[ ! -d "${CF_LOGS_DIRECTORY}" ]]; then
    mkdir "${CF_LOGS_DIRECTORY}"
  fi

  echo >&2 '## generating crontab entry'
  echo >&2
  setup_cron

  if [[ "${ES_ILM_ENABLED}" == "true" ]]; then
    echo >&2 '## ilm setup enabled'
    echo >&2
    if [[ "${ES_ILM_DEFAULT_POLICY_ENABLED}" == "true" ]]; then
      echo >&2 '### using default ilm policy'
      echo >&2
      ilm_policy_file_arg="-E setup.ilm.policy_file='${ES_ILM_DEFAULT_POLICY_FILE}'"
    elif [[ "${ES_ILM_POLICY_FILE}" != "_unset_" ]]; then
      echo >&2 "### using custom ilm policy from \"${ES_ILM_POLICY_FILE}\""
      echo >&2
      if [[ ! -r "{ES_ILM_POLICY_FILE}" ]]; then
        echo >&2 "ERROR: unable to read policy file \"${ES_ILM_POLICY_FILE}\""
        exit 1
      fi
      ilm_policy_file_arg="-E setup.ilm.policy_file='${ES_ILM_POLICY_FILE}'"
    else
      echo >&2 '### ilm policy is not specified'
      echo >&2
    fi
  else
    echo >&2 '## ilm setup disabled'
  fi

  if [[ "${ES_PIPELINE_ENABLED}" ]]; then
    echo >&2 '## ingest pipeline enabled'
    echo >&2
    if [[ "${ES_PIPELINE_DEFAULT_ENABLED}" == "true" ]]; then
      echo >&2 '### installing default pipeline'
      echo >&2
      install_pipeline
    else
      echo >&2 '### custom ingest pipeline is not supported at the moment'
      echo >&2 '### though you could overwrite $ES_PIPELINE_DEFAULT_FILE value'
      exit 1
    fi
  fi

  if [[ "${ES_TEMPLATE_ENABLED}" == "true" ]]; then
    echo >&2 '## template setup enabled'
    echo >&2
    if [[ "${ES_TEMPLATE_JSON_ENABLED}" == "true" ]]; then
      echo >&2 '### generating index template'
      echo >&2
      generate_index_template
    fi
  else
    echo >&2 '## template setup disabled'
    echo >&2
  fi

  echo >&2 '## running Filebeat setup'
  echo >&2
  filebeat \
    -c "${FILEBEAT_CONFIG}" \
    -E setup.ilm.enabled=${ES_ILM_ENABLED} \
    -E setup.ilm.overwrite=${ES_ILM_OVERWRITE} \
    ${ilm_policy_file_arg:-} \
    -E setup.template.enabled=${ES_TEMPLATE_ENABLED} \
    -E setup.template.overwrite=${ES_TEMPLATE_OVERWRITE} \
    -E setup.template.json.enabled=${ES_TEMPLATE_JSON_ENABLED} \
    setup --index-management

  echo >&2
  echo >&2 '## initializing index'
  init_message | jq -cM > ${CF_LOGS_DIRECTORY}/cloudflare_init.log

  echo >&2
  echo >&2 '## launching Filebeat'
  echo >&2
  filebeat -c "${FILEBEAT_CONFIG}" &

  sleep 10

  echo >&2
  echo >&2 '## launching process retrieving logs from Cloudflare..'
  echo >&2
  go-tasks --allow-unprivileged
fi

