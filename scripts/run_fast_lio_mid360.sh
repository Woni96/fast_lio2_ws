#!/usr/bin/env bash
set -euo pipefail

RVIZ="${1:-false}"
WS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +u
source /opt/ros/humble/setup.bash
source "${WS_DIR}/install/setup.bash"
set -u

ros2 launch fast_lio mapping_mid360.launch.py rviz:="${RVIZ}"
