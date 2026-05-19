# FAST-LIO2 ROS2 Humble + Livox MID360

Workspace:

```bash
/home/user/fast_lio2_ws
```

Installed/built components:

- Livox-SDK2
- livox_ros_driver2
- fast_lio ROS2 port
- MID360 config and launch files

Current MID360 network verified on this machine:

- Interface: `eno1`
- Host IP on `eno1`: `192.168.1.2/24`
- MID360 IP: `192.168.1.3`
- MID360 SN: `47MDLC50020208`
- MID360 MAC: `e4:7a:2c:20:2b:b8`

The old/default values in some config files may still show `192.168.1.5`
for the host and `192.168.1.12` for the lidar. On this setup, the lidar
responded at `192.168.1.3`.

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

Optional: use the helper script to set the host network. Pass the current
host IP and lidar IP explicitly:

```bash
sudo /home/user/fast_lio2_ws/scripts/setup_mid360_network.sh eno1 192.168.1.2/24 192.168.1.3
```

Update the livox driver config before running if it still has the old IPs:

```bash
sed -i 's/192.168.1.5/192.168.1.2/g; s/192.168.1.12/192.168.1.3/g' \
  /home/user/fast_lio2_ws/src/FAST_LIO_ROS2/livox_ros_driver2/config/MID360_config.json
```

Run in two terminals:

```bash
/home/user/fast_lio2_ws/scripts/run_mid360_driver.sh
```

```bash
/home/user/fast_lio2_ws/scripts/run_fast_lio_mid360.sh false
```

Or run both together:

```bash
/home/user/fast_lio2_ws/scripts/run_mid360_fast_lio_all.sh false
```

Use `true` instead of `false` to open RViz:

```bash
/home/user/fast_lio2_ws/scripts/run_fast_lio_mid360.sh true
```

Useful checks:

```bash
source /opt/ros/humble/setup.bash
source /home/user/fast_lio2_ws/install/setup.bash
ros2 topic list
ros2 topic hz /livox/lidar
ros2 topic hz /livox/imu
```
