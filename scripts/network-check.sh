#!/usr/bin/env bash
set -u
if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 <target-ip-or-host> [...]" >&2
  exit 2
fi
failed=0
for target in "$@"; do
  printf '\n==> Checking %s\n' "$target"
  if ping -c 3 -W 2 "$target"; then
    echo "PASS: $target"
  else
    echo "FAIL: $target"
    failed=1
  fi
done
exit "$failed"
