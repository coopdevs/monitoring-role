#!/bin/bash

set -ex

declare -r owner="coopdevs"
declare -r name="prometheus-what-active-users-exporter"

declare -r latest_release_url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/${owner}/${name}/releases/latest)
declare -r latest_version=$(echo ${latest_release_url} | awk -F'/' '{print $8}')
declare -r latest_version_name=${name}-${latest_version}-linux-x64

declare -r shasum_url=https://github.com/${owner}/${name}/releases/download/${latest_version}/sha256sums.txt
declare -r binary_url=https://github.com/${owner}/${name}/releases/download/${latest_version}/${latest_version_name}

curl -L ${shasum_url} > shasums256.txt
curl -L ${binary_url} > ${latest_version_name}

declare -r hash_sum_line=$(cat shasums256.txt | grep ${latest_version_name})
declare -r hash_sum=$(echo ${hash_sum_line} | awk -F' ' '{print $1}')

echo "${hash_sum}  ${latest_version_name}" | sha256sum --check --ignore-missing 

mv ${latest_version_name} ${name}
rm shasums256.txt
