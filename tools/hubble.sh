#!/usr/bin/env bash
set -eo pipefail

# hubble.sh — Market Data Batch Query Tool
# Usage: hubble.sh batch '<json>'
#
# All calls execute in parallel. Code format (symbol/tsCode/codes) is inferred.
# 404 → fail immediately, no retry.

###############################################################################
# Config
###############################################################################
BASE="${MARKET_API_BASE_URL%/}"
KEY="$MARKET_API_KEY"
if [[ -z "$BASE" || -z "$KEY" ]]; then
  echo '{"error":"MARKET_API_BASE_URL and MARKET_API_KEY must be set"}' >&2
  exit 1
fi

###############################################################################
# Blacklist
###############################################################################
is_blacklisted() {
  local ep="$1"
  case "$ep" in
    /api/v2/cnstock/klines|/api/v2/cnstock/industry/daily|/api/v2/cnstock/sector|\
    /api/v2/cnstock/industry|/api/v2/cnstock/summary|/api/v2/cnstock/financial|\
    /api/v2/cnstock/report|/api/v2/cnstock/profile|/api/v2/cnstock/info|\
    /api/v2/hkstock/daily) return 0 ;;
    *) return 1 ;;
  esac
}

###############################################################################
# A-share suffix: 6xxxxx→.SH, 0xxxxx/3xxxxx→.SZ, 8xxxxx/4xxxxx→.BJ
###############################################################################
cn_suffix() {
  local raw="$1"
  [[ "$raw" == *"."* ]] && { echo "$raw"; return; }
  case "${raw:0:1}" in
    6) echo "${raw}.SH" ;;
    0|3) echo "${raw}.SZ" ;;
    8|4) echo "${raw}.BJ" ;;
    *) echo "${raw}.SH" ;;
  esac
}

###############################################################################
# Infer code param: given endpoint + code, echo "param_name=formatted_value"
###############################################################################
infer_code_param() {
  local ep="$1" code="$2"
  # securities → codes (strip suffix)
  if [[ "$ep" == *"/securities" ]]; then
    echo "codes=${code%%.*}"
    return
  fi
  # Determine if we need suffix
  local need_suffix=1 formatted="$code"
  if [[ "$ep" == *"/usstock/"* || "$code" == *"."* ]]; then
    need_suffix=0
    formatted="$code"
  elif [[ "$ep" == *"/cnstock/"* ]]; then
    formatted=$(cn_suffix "$code")
  elif [[ "$ep" == *"/hkstock/"* ]]; then
    formatted="${code}.HK"
  fi
  # Pick param name
  local param_name
  if [[ "$ep" == *"/stocks" || "$ep" == *"/indicators"* ]]; then
    param_name="symbol"
  elif [[ "$ep" == *"/index/weight" ]]; then
    param_name="indexCode"
  else
    param_name="tsCode"
  fi
  echo "${param_name}=${formatted}"
}

###############################################################################
# Date helpers
###############################################################################
is_indicator_ep() { [[ "$1" == *"/indicators"* ]]; }

to_yyyymmdd() { echo "${1//-/}"; }

to_ymd() {
  local d="$1"
  [[ "$d" == *"-"* ]] && { echo "$d"; return; }
  echo "${d:0:4}-${d:4:2}-${d:6:2}"
}

###############################################################################
# Execute one API call → write JSON result to stdout
###############################################################################
execute_call() {
  local idx="$1" endpoint="$2" url_params="$3" post_body="$4" method="$5"
  local url="${BASE}${endpoint}"
  [[ -n "$url_params" ]] && url="${url}?${url_params}"

  local resp http_code
  if [[ "$method" == "POST" && -n "$post_body" ]]; then
    resp=$(curl -sS -w '\n%{http_code}' --max-time 30 \
      -H "X-API-Key: $KEY" -H "Content-Type: application/json" \
      -X POST "$url" -d "$post_body" 2>&1) || resp=$'curl_error\n0'
  else
    resp=$(curl -sS -w '\n%{http_code}' --max-time 30 \
      -H "X-API-Key: $KEY" -H "Content-Type: application/json" \
      "$url" 2>&1) || resp=$'curl_error\n0'
  fi

  http_code=$(echo "$resp" | tail -1)
  resp=$(echo "$resp" | sed '$d')

  [[ "$http_code" =~ ^[0-9]+$ ]] || { http_code=0; resp='{"error":"connection failed"}'; }

  if [[ "$http_code" == "404" ]]; then
    if is_blacklisted "$endpoint"; then
      echo "{\"endpoint\":\"$endpoint\",\"status\":404,\"error\":\"Forbidden endpoint (blacklisted)\",\"hint\":\"Check SKILL.md Endpoint Blacklist for alternatives\"}"
    else
      echo "{\"endpoint\":\"$endpoint\",\"status\":404,\"error\":\"Not found\",\"hint\":\"Check code format or endpoint path\"}"
    fi
    return
  fi

  # Wrap response
  if echo "$resp" | jq -e . >/dev/null 2>&1; then
    echo "$resp" | jq -c --arg ep "$endpoint" --argjson st "$http_code" \
      '{endpoint: $ep, status: $st, data: .}'
  else
    echo "{\"endpoint\":\"$endpoint\",\"status\":$http_code,\"raw\":$(echo "$resp" | jq -Rs .)}"
  fi
}

###############################################################################
# Build query string from call JSON
###############################################################################
build_query() {
  local ep="$1" call_json="$2"
  local parts=()

  # code → infer param
  local code
  code=$(echo "$call_json" | jq -r '.code // empty')
  if [[ -n "$code" ]]; then
    parts+=("$(infer_code_param "$ep" "$code")")
  fi

  # codes (securities batch, direct pass-through)
  local codes
  codes=$(echo "$call_json" | jq -r '.codes // empty')
  [[ -n "$codes" ]] && parts+=("codes=$codes")

  # market (indicators)
  local market
  market=$(echo "$call_json" | jq -r '.market // empty')
  [[ -n "$market" ]] && parts+=("market=$market")

  # Other params with date conversion
  local date_fmt="yyyymmdd"
  is_indicator_ep "$ep" && date_fmt="ymd"

  for key in limit interval exchange listStatus fields src version tradeDate startDate endDate suspendDate resumeDate; do
    local val
    val=$(echo "$call_json" | jq -r --arg k "$key" '.[$k] // empty')
    [[ -z "$val" ]] && continue
    # Skip code-related params already handled
    [[ "$key" == "symbol" || "$key" == "tsCode" || "$key" == "codes" || "$key" == "indexCode" ]] && [[ -n "$code" ]] && continue
    # Convert date format
    case "$key" in
      tradeDate|startDate|endDate|suspendDate|resumeDate)
        [[ "$date_fmt" == "ymd" ]] && val=$(to_ymd "$val") || val=$(to_yyyymmdd "$val") ;;
    esac
    parts+=("${key}=${val}")
  done

  # Indicator-specific date params (start/end)
  if is_indicator_ep "$ep"; then
    for key in start end; do
      local val
      val=$(echo "$call_json" | jq -r --arg k "$key" '.[$k] // empty')
      [[ -z "$val" ]] && continue
      parts+=("${key}=$(to_ymd "$val")")
    done
  fi

  local IFS='&'
  echo "${parts[*]}"
}

###############################################################################
# Build POST body for indicators
###############################################################################
build_indicator_body() {
  local call_json="$1"
  local code market_val interval limit start end
  code=$(echo "$call_json" | jq -r '.code // empty')
  market_val=$(echo "$call_json" | jq -r '.market // empty')
  interval=$(echo "$call_json" | jq -r '.interval // "1d"')
  limit=$(echo "$call_json" | jq -r '.limit // "100"')
  start=$(echo "$call_json" | jq -r '.start // empty')
  end=$(echo "$call_json" | jq -r '.end // empty')

  # Infer symbol format
  local symbol="$code"
  if [[ -n "$code" ]]; then
    local inferred
    inferred=$(infer_code_param "/api/v2/indicators" "$code")
    symbol="${inferred#*=}"
  fi

  # Build JSON
  local body="{\"market\":\"$market_val\",\"symbol\":\"$symbol\",\"interval\":\"$interval\",\"limit\":$limit"
  [[ -n "$start" ]] && body="$body,\"start\":\"$(to_ymd "$start")\""
  [[ -n "$end" ]] && body="$body,\"end\":\"$(to_ymd "$end")\""

  # Add indicators array
  local indicators
  indicators=$(echo "$call_json" | jq -c '.indicators // []')
  body="$body,\"indicators\":$indicators}"

  echo "$body" | jq -c .
}

###############################################################################
# cmd_batch
###############################################################################
cmd_batch() {
  local input="$1"

  # Validate
  echo "$input" | jq -e '.calls | type == "array" and length > 0' >/dev/null 2>&1 \
    || { echo '{"error":"Invalid input: need .calls non-empty array"}' >&2; exit 1; }

  local count
  count=$(echo "$input" | jq '.calls | length')
  local tmpdir
  tmpdir=$(mktemp -d)

  local start_time
  start_time=$(date +%s%3N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1000))')

  local pids=""
  # Launch all calls in parallel
  for (( i = 0; i < count; i++ )); do
    local call_json endpoint
    call_json=$(echo "$input" | jq -c ".calls[$i]")
    endpoint=$(echo "$call_json" | jq -r '.endpoint')

    # Blacklist check
    if is_blacklisted "$endpoint"; then
      echo "{\"endpoint\":\"$endpoint\",\"status\":404,\"error\":\"Forbidden endpoint (blacklisted)\",\"hint\":\"Check SKILL.md Endpoint Blacklist for alternatives\"}" \
        > "$tmpdir/$i.json"
      continue
    fi

    local method="GET" url_params="" post_body=""

    # Detect POST (indicators batch)
    if [[ "$endpoint" == "/api/v2/indicators" ]]; then
      method="POST"
      post_body=$(build_indicator_body "$call_json")
    else
      url_params=$(build_query "$endpoint" "$call_json")
    fi

    # HK limit protection
    if [[ "$endpoint" == "/api/v2/hkstock/stocks" ]]; then
      local has_start has_end has_limit
      has_start=$(echo "$call_json" | jq -r '.startDate // .start // empty')
      has_end=$(echo "$call_json" | jq -r '.endDate // .end // empty')
      has_limit=$(echo "$call_json" | jq -r '.limit // empty')
      if [[ -n "$has_limit" ]] && [[ -z "$has_start" || -z "$has_end" ]]; then
        local end_d start_d
        end_d=$(date +%Y%m%d)
        start_d=$(date -d "$end_d -120 days" +%Y%m%d 2>/dev/null || \
          python3 -c "from datetime import datetime,timedelta;print((datetime.now()-timedelta(days=120)).strftime('%Y%m%d'))")
        [[ -z "$has_start" ]] && url_params="${url_params}&startDate=${start_d}"
        [[ -z "$has_end" ]] && url_params="${url_params}&endDate=${end_d}"
        url_params=$(echo "$url_params" | sed 's/limit=[^&]*//;s/^&//;s/&&/&/;s/&$//')
      fi
    fi

    (
      execute_call "$i" "$endpoint" "$url_params" "$post_body" "$method" > "$tmpdir/$i.json"
    ) &
    pids="$pids $!"
  done

  # Wait for all
  for pid in $pids; do
    wait "$pid" 2>/dev/null || true
  done

  local end_time
  end_time=$(date +%s%3N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1000))')
  local elapsed=$((end_time - start_time))

  # Assemble results
  local results="{}"
  local success=0 failed=0
  for (( i = 0; i < count; i++ )); do
    local f="$tmpdir/$i.json"
    if [[ -f "$f" && -s "$f" ]]; then
      local st
      st=$(jq -r '.status // 0' "$f")
      if [[ "$st" -ge 200 && "$st" -lt 300 ]]; then
        success=$((success + 1))
      else
        failed=$((failed + 1))
      fi
      results=$(echo "$results" | jq -c --argjson idx "$i" --argjson val "$(cat "$f")" '. + {($idx|tostring): $val}')
    else
      failed=$((failed + 1))
      local ep_name
      ep_name=$(echo "$input" | jq -r ".calls[$i].endpoint // \"unknown\"")
      results=$(echo "$results" | jq -c --argjson idx "$i" --arg ep "$ep_name" \
        '. + {($idx|tostring): {endpoint: $ep, status: 0, error: "No response"}}')
    fi
  done

  local output
  output=$(jq -c --argjson results "$results" --argjson total "$count" --argjson success "$success" \
    --argjson failed "$failed" --argjson elapsed "$elapsed" \
    '{results: $results, summary: {total: $total, success: $success, failed: $failed, elapsed_ms: $elapsed}}')

  rm -rf "$tmpdir"
  echo "$output"
}

###############################################################################
# Usage & Main
###############################################################################
usage() {
  cat >&2 <<'EOF'
hubble.sh — Market Data Batch Query Tool

Usage:  hubble.sh batch '<json>'

Example:
  hubble.sh batch '{
    "calls": [
      {"endpoint": "/api/v2/cnstock/stocks", "code": "600519", "limit": 100},
      {"endpoint": "/api/v2/cnstock/securities", "codes": "600519,000001"},
      {"endpoint": "/api/v2/cnstock/company", "code": "600519"},
      {"endpoint": "/api/v2/indicators", "code": "600519", "market": "cn",
        "indicators": [{"type": "rsi", "params": [14]}, {"type": "macd", "params": [12,26,9]}]}
    ]
  }'

Code format (symbol/tsCode/codes) is auto-inferred from endpoint. No need to remember.

Requires: jq, curl
EOF
  exit 1
}

case "${1:-}" in
  batch) cmd_batch "${2:-}" ;;
  *) usage ;;
esac
