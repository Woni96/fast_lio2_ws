#!/usr/bin/env bash
set -euo pipefail

IFACE="${1:-eno1}"
HOST_IP="${2:-192.168.1.5/24}"
LIDAR_IP="${3:-192.168.1.12}"

if [[ ${EUID} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

if ! ip link show "${IFACE}" >/dev/null 2>&1; then
  echo "Network interface not found: ${IFACE}" >&2
  exit 1
fi

ip link set "${IFACE}" up
if ! ip -brief addr show dev "${IFACE}" | grep -q "${HOST_IP%/*}"; then
  ip addr add "${HOST_IP}" dev "${IFACE}"
fi

echo "Interface status:"
ip -brief addr show dev "${IFACE}"
echo
echo "Checking MID360 at ${LIDAR_IP}:"
ping -c 1 -W 1 "${LIDAR_IP}" || true

