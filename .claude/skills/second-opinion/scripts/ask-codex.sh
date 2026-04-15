#!/usr/bin/env bash
# ask-codex.sh — Run codex exec in read-only mode and return clean output
#
# Usage: bash ask-codex.sh [--model MODEL] [--timeout SECS] "prompt"
#
# Options:
#   --model MODEL    Codex model to use (default: gpt-5.4)
#   --timeout SECS   Max seconds to wait for response (default: 120)
#
# Examples:
#   bash ask-codex.sh "Review this error handling approach"
#   bash ask-codex.sh --model o3 --timeout 180 "Is this migration safe?"

set -euo pipefail

MODEL="gpt-5.4"
TIMEOUT=1200
PROMPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)
      MODEL="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --help|-h)
      sed -n '2,/^$/s/^# \?//p' "$0"
      exit 0
      ;;
    -*)
      echo "Error: Unknown flag: $1" >&2
      echo "Usage: bash ask-codex.sh [--model MODEL] [--timeout SECS] \"prompt\"" >&2
      exit 1
      ;;
    *)
      PROMPT="$1"
      shift
      ;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided." >&2
  echo "Usage: bash ask-codex.sh [--model MODEL] [--timeout SECS] \"prompt\"" >&2
  exit 1
fi

if ! command -v codex &>/dev/null; then
  echo "Error: codex-cli not found in PATH." >&2
  echo "Install: npm install -g @openai/codex" >&2
  echo "Then authenticate: codex login" >&2
  exit 1
fi

OUTFILE=$(mktemp /tmp/codex-opinion-XXXXXX.md)
trap 'rm -f "$OUTFILE"' EXIT

# Run codex with a timeout. macOS lacks GNU timeout, so fall back to a
# background-process approach when the command isn't available.
EXIT_CODE=0
if command -v timeout &>/dev/null; then
  timeout "${TIMEOUT}s" codex exec \
    --sandbox read-only \
    --model "$MODEL" \
    -o "$OUTFILE" \
    "$PROMPT" 2>/dev/null || EXIT_CODE=$?
else
  codex exec \
    --sandbox read-only \
    --model "$MODEL" \
    -o "$OUTFILE" \
    "$PROMPT" 2>/dev/null &
  CODEX_PID=$!
  ( sleep "$TIMEOUT" && kill "$CODEX_PID" 2>/dev/null ) &
  TIMER_PID=$!
  wait "$CODEX_PID" 2>/dev/null || EXIT_CODE=$?
  kill "$TIMER_PID" 2>/dev/null || true
  wait "$TIMER_PID" 2>/dev/null || true
  # If codex was killed by the timer, treat as timeout (137 = SIGKILL, 143 = SIGTERM)
  if [[ $EXIT_CODE -eq 143 || $EXIT_CODE -eq 137 ]]; then
    EXIT_CODE=124
  fi
fi

if [[ $EXIT_CODE -eq 124 ]]; then
  echo "Error: Codex timed out after ${TIMEOUT}s." >&2
  echo "Try a simpler question or increase --timeout." >&2
  exit 1
elif [[ $EXIT_CODE -ne 0 ]]; then
  echo "Error: Codex exited with code $EXIT_CODE." >&2
  echo "Check that codex is authenticated (codex login) and OPENAI_API_KEY is set." >&2
  exit 1
fi

if [[ ! -s "$OUTFILE" ]]; then
  echo "Error: Codex returned an empty response." >&2
  exit 1
fi

cat "$OUTFILE"
