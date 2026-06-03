#!/usr/bin/env bash
set -euo pipefail

RVIZ="${1:-false}"
WS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +u
source /opt/ros/humble/setup.bash
source "${WS_DIR}/install/setup.bash"
set -u
mkdir -p "${WS_DIR}/log/ros"
export ROS_LOG_DIR="${WS_DIR}/log/ros"

ros2 launch fast_lio mapping.launch.py config_file:=mid360.yaml rviz:="${RVIZ}"
