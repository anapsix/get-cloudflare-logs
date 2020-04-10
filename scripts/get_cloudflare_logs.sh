#!/usr/bin/env bash

RANDOM_ID="$(od -x /dev/urandom | head -1 | awk '{print $2$4}')"

set -u

: ${CF_ZONE_ID:='_unset_'}
: ${CF_AUTH_EMAIL:='_unset_'}
: ${CF_AUTH_KEY:='_unset_'}


: ${CHUNK_FILE:="/tmp/cf_log_${RANDOM_ID}.chunk"}
: ${CURSOR_FILE:="/tmp/cf_log_${RANDOM_ID}.cursor"}

if [[ "$(uname -s)" == "Darwin" ]]; then
  date="gdate"
else
  date="date"
fi

info() {
  if [[ ${QUIET:-0} -eq 0 ]] || [[ ${DEBUG:-0} -eq 1 ]]; then
    echo >&2 -e "\e[92mINFO:\e[0m $@"
  fi
}

warn() {
  if [[ ${QUIET:-0} -eq 0 ]] || [[ ${DEBUG:-0} -eq 1 ]]; then
    echo >&2 -e "\e[33mWARNING:\e[0m $@"
  fi
}

debug(){
  if [[ ${DEBUG:-0} -eq 1 ]]; then
    echo >&2 -e "\e[95mDEBUG:\e[0m $@"
  fi
}

error(){
  local msg="$1"
  local exit_code="${2:-1}"
  echo >&2 -e "\e[91mERROR:\e[0m $1"
  if [[ "${exit_code}" != "-" ]]; then
    exit ${exit_code}
  fi
}

getval() {
  local x="${1%%=*}"
  if [[ "$x" = "$1" ]]; then
    echo "${2}"
    return 2
  else
    echo "${1##*=}"
    return 1
  fi
}

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

usage() {
cat <<EOM
This script retrieved Cloudflare Access, or Security logs

Usage: $0 [FLAGS] [OPTIONS]

  FLAGS and OPTIONS:
    -h | --help | --usage   displays usage
    -q | --quiet            enabled quiet mode, no output except errors
    -d | --debug            enables debug mode, ignores quiet mode
    -a | --access-logs      get access logs, mutualy exclusive with "-s"
    -s | --security-events  get security events, mutualy exclusive with "-a"
    --start                 start time
    --end                   end time
    --sample                sample percent
    --count                 number of events
    --all-fields            get all fields
    --rule                  only this rule ID

  following options can be set via ENVIRONMENT
    --cf-zone-id            Cloudflare Zone ID to get logs for
    --cf-auth-email         Cloudflare Auth Email
    --cf-auth-key           Cloudflare Auth Key (Global API key)

  ENVIRONMENT:
    CF_ZONE_ID              Cloudflare Zone ID to get logs for, required
    CF_AUTH_EMAIL           Cloudflare Auth Email, required
    CF_AUTH_KEY             Cloudflare Auth Key (Global API key), required

EOM
}

## Get CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|--usage)
      usage
      exit 0
    ;;

    -d|--debug)
      DEBUG=1
      shift 1
    ;;

    -q|--quiet)
      QUIET=1
      shift 1
    ;;

    -a|--access-logs)
      MODE="access"
      shift 1
    ;;

    -s|--security-events)
      MODE="security"
      shift 1
    ;;

    --start|--start=*)
      START="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --end|--end=*)
      END="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --sample|--sample=*)
      SAMPLE="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --count|--limit|--count=*|--limit=*)
      COUNT="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --all-fields)
      ALL_FIELDS=1
      shift 1
    ;;

    --rule|--rule=*|--rule-id|--rule-id=*)
      RULE_ID="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --cf-zone-id|--cf-zone-id=*)
      CF_ZONE_ID="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --cf-auth-email|--cf-auth-email=*)
      CF_EMAIL="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    --cf-auth-key|--cf-auth-key=*)
      CF_TOKEN="$(getval "$1" "${2:-}")"
      shift $?
    ;;

    *)
      error "Unexpected option \"$1\"" -
      usage
      exit 1
    ;;
  esac
done

if [[ -z "${MODE:-}" ]]; then
  usage
  exit 1
fi

if [[ "${CF_ZONE_ID}" == "_unset_" ]]; then
  error "Required parameter CF_ZONE_ID is unset" -
  usage
  exit 1
fi
if [[ "${CF_AUTH_EMAIL}" == "_unset_" ]]; then
  error "Required parameter CF_AUTH_EMAIL is unset" -
  usage
  exit 1
fi
if [[ "${CF_AUTH_KEY}" == "_unset_" ]]; then
  error "Required parameter CF_AUTH_KEY is unset" -
  usage
  exit 1
fi

if [[ -z "${START:-}" ]]; then
  START="6 minutes ago"
fi

if [[ -z "${END:-}" ]]; then
  END="1 minute ago"
fi

set -e
set -o pipefail

# check dependencies
DEPS=( jq curl $date )
check_dep() {
  if ! which $1 2>&1 >/dev/null; then
    error "dependency missing - \"${1}\", exiting.."
  fi
}
for dep in ${DEPS[*]}; do
  check_dep $dep
done

function _exit {
  if [[ ${DEBUG:-0} -eq 1 ]]; then
    debug "CHUNK_FILE: ${CHUNK_FILE}"
    debug "CURSOR_FILE: ${CURSOR_FILE}"
    return
  fi
  if [[ -e "${CHUNK_FILE}" ]]; then
    rm "${CHUNK_FILE}"
  fi
  if [[ -e "${CURSOR_FILE}" ]]; then
    rm "${CURSOR_FILE}"
  fi
}
trap _exit EXIT

get_fields() {
  curl -s \
    -H "X-Auth-Email: ${CF_AUTH_EMAIL}" \
    -H "X-Auth-Key: ${CF_AUTH_KEY}" \
    "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/logs/received/fields" \
    | jq '. | to_entries[] | .key' -r | paste -sd "," -
}

get_access_logs() {
  local OPTS="${SAMPLE:+&sample=$SAMPLE}${COUNT:+&count=$COUNT}"
  local START_TIME="$($date +%s -d "${START}")"
  local END_TIME="$($date +%s -d "${END}")"
  debug "START_TIME: ${START_TIME}"
  debug "END_TIME: ${END_TIME}"

  curl -s \
    -H "X-Auth-Email: ${CF_AUTH_EMAIL}" \
    -H "X-Auth-Key: ${CF_AUTH_KEY}" \
    "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/logs/received?start=${START_TIME}&end=${END_TIME}${OPTS}${FIELDS:+&fields=$FIELDS}" \
    | jq -cM 'del(.[] | select(.==""))'
}

get_security_events() {
  local OPTS="${COUNT:+&limit=$COUNT}${RULE_ID:+&rule_id=$RULE_ID}"
  local START_TIME="$(TZ=UTC $date +%FT%TZ -d "${START}")"
  local END_TIME="$(TZ=UTC $date +%FT%TZ -d "${END}")"
  local response
  local cursor
  local cursor_after_orig
  local cursor_direction="before"

  debug "START_TIME: ${START_TIME}"
  debug "END_TIME: ${END_TIME}"

  if [[ -z "${RULE_ID:-}" ]]; then
    ACTION="&action=drop"
  fi

  while
    if curl -s \
      -H "X-Auth-Email: ${CF_AUTH_EMAIL}" \
      -H "X-Auth-Key: ${CF_AUTH_KEY}" \
     "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/security/events?kind=firewall${ACTION:-}&since=${START_TIME}&until=${END_TIME}${OPTS:-}${cursor:+&cursor=$cursor}" | \
      tee "${CHUNK_FILE}" | \
      jq -r '.result_info.cursors' > "${CURSOR_FILE}"
    then
      jq -c '.result|.[]' "${CHUNK_FILE}"
    else
      echo >&2 "failed to get events, exiting.."
      exit 1
    fi

    cursor="$(jq -r .before "${CURSOR_FILE}")"

    # if [[ "${cursor_direction}" == "before" ]]; then
    #   cursor="$(jq -r .before "${CURSOR_FILE}")"
    #   cursor_after_orig="$(jq -r .after "${CURSOR_FILE}")"
    # else
    #   if [[ "${cursor_after_orig:-_unset_}" != "_unset_" ]]; then
    #     debug "first time using cursor_after_orig"
    #     cursor="${cursor_after_orig}"
    #     unset cursor_after_orig
    #   else
    #     cursor="$(jq -r .after "${CURSOR_FILE}")"
    #   fi
    # fi
    # debug "CURSOR DIRECTION: ${cursor_direction}"

    debug "CURSOR: ${cursor}"

    # if [[ "${cursor:-null}" == "null" ]] && [[ "${cursor_direction}" == "before" ]]; then
    #   cursor_direction="after"
    #   debug "changing cursor direction before -> after"
    #   continue
    # fi

    if [[ -z "${cursor}" ]] || [[ "${cursor}" == "null" ]]; then
      exit 0
    fi
  do :; done
}

case $MODE in
  access)
    if [[ ${ALL_FIELDS:-0} -eq 1 ]]; then
      FIELDS="$(get_fields)"
    fi
    get_access_logs
  ;;
  security)
    get_security_events
  ;;
  *)
    error "unknown mode \"${MODE}\", exiting.."
esac
