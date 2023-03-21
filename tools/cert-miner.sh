#!/bin/bash

set -euo pipefail

usage() {
  echo "Mine the certz"
  echo ""
  echo "Usage:"
  echo "  $0 <device-ip> <target-dir> [offset=0] [count=1]"
  echo ""
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

device=$1
target=$2
begin=${3:-0}
count=${4:-1}
end=$(expr ${begin} + ${count})

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "connect to device ${device}"
adb connect ${device}
echo "wait 2s for device connection to be ready"
sleep 2

echo "push gtv-ca-sign to device"
adb -s ${device} push --sync ${dir}/../bin/gtv-ca-sign /tmp/gtv-ca-sign
adb -s ${device} shell busybox chmod +x /tmp/gtv-ca-sign

echo "pull cpu.crt from device"
cpu_crt_path="${dir}/../tmp/cpu.crt"
adb -s ${device} pull /factory/client.crt "${cpu_crt_path}"

cpu_crt=$(cat ${cpu_crt_path})
ica_crt=$(cat ${dir}/../etc/ica.crt)

for i in $(seq ${begin} $(expr ${end} - 1)); do
  echo "gen cert ${i}"
  hash=$(python3 ${dir}/make-cert.py ${dir}/../tmp ${i})

  peer_key=$(cat ${dir}/../tmp/peer.key)
  peer_crt=$(cat ${dir}/../tmp/peer.crt)

  echo "sign hash: ${hash}"
  signature=$(adb -s ${device} shell "/tmp/gtv-ca-sign --hash ${hash}" | tail -1)
  echo "signature: ${signature}"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    base64=$(echo $signature | xxd -r -p | base64)
  else
    base64=$(echo $signature | xxd -r -p | base64 -w 0)
  fi
  echo "base64: ${base64}"

  not_before=$(openssl x509 -in "${dir}/../tmp/peer.crt" -noout -startdate)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    timestamp=$(date -j -f "%b %d %H:%M:%S %Y %Z" "${not_before:10}" +%Y%m%d)
  else
    timestamp=$(date -d "${not_before:10}" +%Y%m%d)
  fi

  echo "make ${target}/certs-${timestamp}.json"

  printf '{"pr":"%s","pu":"%s","cpu":"%s","sig":"%s","ica":"%s"}' "${peer_key}" "${peer_crt}" "${cpu_crt}" "${base64}" "${ica_crt}" > ${target}/certs-${timestamp}.json
done
