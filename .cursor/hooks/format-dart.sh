#!/bin/bash
input=$(cat)
file=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("file_path",""))')

case "$file" in
  *.dart) ;;
  *)
    printf '%s\n' '{}'
    exit 0
    ;;
esac

if command -v dart >/dev/null 2>&1; then
  dart format "$file" >/dev/null 2>&1 || true
fi

printf '%s\n' '{}'
exit 0
