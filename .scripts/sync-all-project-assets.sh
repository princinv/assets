#!/usr/bin/env bash

set -u

repos=(
  "/srv/docker/repos/engineering-framework"
  "/srv/docker/repos/docker-infra"
  "/srv/docker/repos/health"
  "/srv/docker/repos/homepage-geoip-heatmap"
  "/srv/docker/repos/recipes-bridge"
  "/srv/docker/repos/ansible-master"
  "/home/princinv/.local/share/chezmoi"
)

mode="${1:---check}"

case "$mode" in
  --check|--sync)
    ;;
  *)
    echo "Usage: .scripts/sync-all-project-assets.sh [--check|--sync]" >&2
    exit 2
    ;;
esac

failed=0

for repo_dir in "${repos[@]}"; do
  echo
  echo "== $repo_dir =="

  if [[ ! -x "$repo_dir/.scripts/sync-assets-mirror.sh" ]]; then
    echo "SKIP: missing project sync script"
    continue
  fi

  if ! (cd "$repo_dir" && .scripts/sync-assets-mirror.sh "$mode"); then
    failed=$((failed + 1))
  fi
done

if [[ "$failed" -gt 0 ]]; then
  echo "ERROR: $failed project asset mirror check(s) failed"
  exit 1
fi

echo
echo "OK: project asset mirrors complete"
