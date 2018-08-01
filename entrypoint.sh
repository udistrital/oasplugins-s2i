#!/usr/bin/env bash

set -e
set -u

PLUGIN_DESTIMG="${PLUGIN_DESTIMG:-}"
PLUGIN_REGISTRY="${PLUGIN_REGISTRY:-https://index.docker.io/v1/}"
PLUGIN_ECR="${PLUGIN_ECR:-}"

nohup dockerd-entrypoint.sh > dockerd-entrypoint.log 2>dockerd-entrypoint.err &
dockerd=$!

cleanup() {
  kill "${dockerd}"
}

trap cleanup EXIT INT TERM

c=1

while ! docker info >&2 && [ $((c++)) -lt 10 ] ; do
  sleep "${c}"
done

docker info > /dev/null

if [ -n "${PLUGIN_DESTIMG}" ]; then
  s2i_tag="$(jq -r .tag < .s2ifile)"
fi

if [ -n "${PLUGIN_ECR}" ] && [ -n "${PLUGIN_DESTIMG}" ]; then
  eval "$(aws ecr get-login --no-include-email)"
elif [ -n "${PLUGIN_DESTIMG}" ]; then
  docker login --username "${DOCKER_USERNAME}" --password-stdin "${PLUGIN_REGISTRY}"  <<< "${DOCKER_PASSWORD}"
fi

s2i build --use-config

if [ -n "${PLUGIN_DESTIMG}" ]; then
  docker tag "${s2i_tag}" "${PLUGIN_DESTIMG}"
  docker push "${PLUGIN_DESTIMG}"
fi
