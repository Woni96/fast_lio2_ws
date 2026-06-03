# FAST-LIO2 ROS2 Humble + Livox MID360

This workspace is prepared for running FAST-LIO2 with a Livox MID360 on ROS2
Humble.

Workspace root:

```bash
/home/user/fast_lio2_ws/fast_lio2_ws
```

## 구성

Main source packages:

- `src/Livox-SDK2`: Livox SDK2 source
- `src/livox_ros_driver2`: Livox ROS2 driver
- `src/FAST_LIO_ROS2`: FAST-LIO2 ROS2 port, package name `fast_lio`
- `src/FAST_LIO_ROS2/include/ikd-Tree`: FAST-LIO2 required submodule

Helper scripts:

- `scripts/run_mid360_driver.sh`: run only Livox MID360 driver
- `scripts/run_fast_lio_mid360.sh`: run only FAST-LIO2 with `mid360.yaml`
- `scripts/run_mid360_fast_lio_all.sh`: run driver and FAST-LIO2 together
- `scripts/setup_mid360_network.sh`: helper for setting the MID360 network

Generated directories:

- `build/`: colcon build output
- `install/`: installed ROS2 packages and setup files
- `log/`: colcon and ROS launch logs

`build/`, `install/`, and `log/` are generated files and should not be
committed.

## 설치 파일 준비

Install common build tools and ROS dependencies:

```bash
sudo apt update
sudo apt install -y build-essential cmake python3-colcon-common-extensions \
  ros-humble-pcl-ros ros-humble-pcl-conversions ros-humble-eigen3-cmake-module
```

If this workspace is cloned again from scratch, clone it with submodules:

```bash
git clone --recurse-submodules https://github.com/Woni96/fast_lio2_ws.git
```

If the workspace is already cloned, initialize all submodules:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
git submodule update --init --recursive
```

The official `livox_ros_driver2` repository stores ROS1 and ROS2 package files
separately. For ROS2 Humble, enable the ROS2 files before building:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
cp src/livox_ros_driver2/package_ROS2.xml src/livox_ros_driver2/package.xml
cp -r src/livox_ros_driver2/launch_ROS2 src/livox_ros_driver2/launch
```

Apply the MID360 network values used by this workspace:

```bash
sed -i 's/192.168.1.5/192.168.1.2/g; s/192.168.1.12/192.168.1.3/g' \
  src/livox_ros_driver2/config/MID360_config.json
```

## Livox-SDK2 설치

Build and install Livox-SDK2 first. The ROS2 driver links against the installed
SDK library in `/usr/local/lib`.

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws/src/Livox-SDK2
mkdir -p build
cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
```

Check that the SDK library exists:

```bash
ls /usr/local/lib | grep livox
```

Expected files include:

```text
liblivox_lidar_sdk_shared.so
liblivox_lidar_sdk_static.a
```

## ROS2 워크스페이스 빌드

Build all packages:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install --cmake-args -DROS_EDITION=ROS2 -DDISTRO_ROS=humble
source install/setup.bash
```

Expected packages:

```bash
ros2 pkg prefix livox_ros_driver2
ros2 pkg prefix fast_lio
```

Expected executables:

```bash
ros2 pkg executables livox_ros_driver2
ros2 pkg executables fast_lio
```

Expected output:

```text
livox_ros_driver2 livox_ros_driver2_node
fast_lio fastlio_mapping
```

If only one package changed, rebuild selectively:

```bash
source /opt/ros/humble/setup.bash
colcon build --symlink-install --packages-select livox_ros_driver2 \
  --cmake-args -DROS_EDITION=ROS2 -DDISTRO_ROS=humble
colcon build --symlink-install --packages-select fast_lio \
  --cmake-args -DROS_EDITION=ROS2 -DDISTRO_ROS=humble
```

Clean rebuild:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
rm -rf build install log
source /opt/ros/humble/setup.bash
colcon build --symlink-install --cmake-args -DROS_EDITION=ROS2 -DDISTRO_ROS=humble
```

## MID360 네트워크 설정

Current MID360 values used in this workspace:

- Interface: `eno1`
- Host IP on `eno1`: `192.168.1.2/24`
- MID360 IP: `192.168.1.3`
- MID360 SN: `47MDLC50020208`
- MID360 MAC: `e4:7a:2c:20:2b:b8`

The driver config is:

```bash
src/livox_ros_driver2/config/MID360_config.json
```

It should contain:

```json
"cmd_data_ip" : "192.168.1.2",
"push_msg_ip": "192.168.1.2",
"point_data_ip": "192.168.1.2",
"imu_data_ip" : "192.168.1.2",
"ip" : "192.168.1.3"
```

Check the network:

```bash
ip -br addr show dev eno1
ping -c 2 192.168.1.3
ip neigh show dev eno1
```

If `eno1` is not on the `192.168.1.x/24` network, set it manually:

```bash
sudo ip addr add 192.168.1.2/24 dev eno1
sudo ip link set eno1 up
```

Or use the helper script:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
sudo ./scripts/setup_mid360_network.sh eno1 192.168.1.2/24 192.168.1.3
```

## 실행

The helper scripts source ROS2 Humble and `install/setup.bash` automatically.
They also set `ROS_LOG_DIR` to `log/ros` inside this workspace, so ROS launch
does not need to write logs under `~/.ros/log`.

Run driver and FAST-LIO2 together:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
./scripts/run_mid360_fast_lio_all.sh false
```

Run with RViz:

```bash
./scripts/run_mid360_fast_lio_all.sh true
```

Run in two terminals:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
./scripts/run_mid360_driver.sh
```

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
./scripts/run_fast_lio_mid360.sh false
```

Manual launch commands:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/local/lib"
export ROS_LOG_DIR="$PWD/log/ros"
mkdir -p "$ROS_LOG_DIR"

ros2 launch livox_ros_driver2 msg_MID360_launch.py
```

In another terminal:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash
export ROS_LOG_DIR="$PWD/log/ros"
mkdir -p "$ROS_LOG_DIR"

ros2 launch fast_lio mapping.launch.py config_file:=mid360.yaml rviz:=false
```

## 실행 확인

After launching, check topics:

```bash
source /opt/ros/humble/setup.bash
source /home/user/fast_lio2_ws/fast_lio2_ws/install/setup.bash
ros2 topic list
ros2 topic hz /livox/lidar
ros2 topic hz /livox/imu
```

Useful launch argument checks:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash

ROS_LOG_DIR=/home/user/fast_lio2_ws/fast_lio2_ws/log/ros \
  ros2 launch fast_lio mapping.launch.py --show-args

ROS_LOG_DIR=/home/user/fast_lio2_ws/fast_lio2_ws/log/ros \
  ros2 launch livox_ros_driver2 msg_MID360_launch.py --show-args
```

## 문제 해결

If `fast_lio` fails with `Cannot find source file:
include/ikd-Tree/ikd_Tree.cpp`, initialize the submodule:

```bash
git -C /home/user/fast_lio2_ws/fast_lio2_ws/src/FAST_LIO_ROS2 \
  submodule update --init --recursive
```

If `livox_ros_driver2` is not found by `colcon`, enable the ROS2 package files:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
cp src/livox_ros_driver2/package_ROS2.xml src/livox_ros_driver2/package.xml
cp -r src/livox_ros_driver2/launch_ROS2 src/livox_ros_driver2/launch
```

If ROS launch fails because it cannot write to `~/.ros/log`, run with:

```bash
cd /home/user/fast_lio2_ws/fast_lio2_ws
mkdir -p log/ros
export ROS_LOG_DIR="$PWD/log/ros"
```

If the driver starts but no lidar data appears, verify:

```bash
ip -br addr show dev eno1
ping -c 2 192.168.1.3
ros2 topic list
ros2 topic hz /livox/lidar
ros2 topic hz /livox/imu
```
