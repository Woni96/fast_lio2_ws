#!/usr/bin/env bash
set -euo pipefail
WS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +u
source /opt/ros/humble/setup.bash
source "${WS_DIR}/install/setup.bash"
set -u
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/local/lib"
mkdir -p "${WS_DIR}/log/ros"
export ROS_LOG_DIR="${WS_DIR}/log/ros"

ros2 launch livox_ros_driver2 msg_MID360_launch.py
