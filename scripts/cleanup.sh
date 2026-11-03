#!/usr/bin/env bash
set -u

if ! docker info >/dev/null 2>&1; then
  echo "🔴 docker に到達できない" >&2
  exit 2
fi

echo "===== 掃除前 ====="
docker system df

rc=0
docker container prune -f  || rc=1

docker image prune -f      || rc=1

docker builder prune -af   || rc=1

docker network prune -f    || rc=1

echo "===== 掃除後 ====="
docker system df

exit "$rc"
