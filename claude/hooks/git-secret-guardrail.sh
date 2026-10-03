#!/usr/bin/env bash
# PreToolUse hook: scan staged git diff for likely secrets before `git commit`.
# Reads Claude Code hook JSON on stdin; emits a block decision as JSON on stdout
# when matches are found, otherwise exits 0 silently.
#
# Patterns blocked (added lines in the staged diff; `--amend` falls back to HEAD):
#   - AWS access key id        AKIA + 16 upper/digits        (e.g. AKIAIOSFODNN7EXAMPLE)
#   - AWS temp access key      ASIA + 16 upper/digits        (STS session creds)
#   - AWS secret access key    aws_secret_access_key = <40 base64url>  (case-insensitive)
#   - GitHub token             ghp_/gho_/ghu_/ghs_/ghr_ + 36+ chars
#   - Google API key           AIza + 35 url-safe chars
#   - Slack token              xoxb-/xoxa-/xoxp-/xoxr-/xoxs- + 10+ chars
#   - OpenAI / Anthropic key   sk-... or sk-ant-... + 20+ chars
#   - Private key block        -----BEGIN ... PRIVATE KEY-----
#   - Generic secret assignment  secret/password/passwd/api_key/token = "<16+ chars>"
#                                (case-insensitive; quoted values only)
#
# To add a pattern: append a name to pattern_names, its regex to pattern_regexes,
# and 'i' or '' to pattern_flags. All three arrays must stay the same length.

set -u

input=$(cat)

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
dir=$(printf '%s' "$input" | jq -r '.cwd // ""')
[ -z "$dir" ] && dir="$PWD"

git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0

diff=$(git -C "$dir" diff --cached --no-color 2>/dev/null || true)

if [ -z "$diff" ] && printf '%s' "$cmd" | grep -q -- '--amend'; then
  diff=$(git -C "$dir" show HEAD --no-color 2>/dev/null || true)
fi

[ -z "$diff" ] && exit 0

# Parallel arrays: pattern_names[i] / pattern_regexes[i] / pattern_flags[i].
# Flags: "i" = case-insensitive, "" = case-sensitive.
pattern_names=(
  'AWS access key id'
  'AWS temp access key'
  'AWS secret access key'
  'GitHub token'
  'Google API key'
  'Slack token'
  'OpenAI/Anthropic key'
  'Private key block'
  'Generic secret assignment'
)
pattern_regexes=(
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'
  'aws_secret_access_key[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+=]{40}'
  'gh[pousr]_[A-Za-z0-9]{36,}'
  'AIza[0-9A-Za-z_-]{35}'
  'xox[baprs]-[0-9A-Za-z-]{10,}'
  'sk-(ant-)?[A-Za-z0-9_-]{20,}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '(secret|password|passwd|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{16,}["'"'"']'
)
pattern_flags=(
  ''
  ''
  'i'
  ''
  ''
  ''
  ''
  ''
  'i'
)

added=$(printf '%s\n' "$diff" | grep '^+' | grep -v '^+++' || true)
[ -z "$added" ] && exit 0

findings=""
for i in "${!pattern_names[@]}"; do
  name="${pattern_names[$i]}"
  regex="${pattern_regexes[$i]}"
  flags="${pattern_flags[$i]}"
  if [ "$flags" = "i" ]; then
    hits=$(printf '%s\n' "$added" | grep -nEi -e "$regex" || true)
  else
    hits=$(printf '%s\n' "$added" | grep -nE -e "$regex" || true)
  fi
  if [ -n "$hits" ]; then
    findings+="[$name]"$'\n'"$hits"$'\n'
  fi
done

[ -z "$findings" ] && exit 0

reason="git-secret-guardrail: potential secret(s) in staged diff:
${findings}
Unstage the lines or move the value to an untracked secrets file before committing."

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
exit 0
