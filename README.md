# InfiniteRecorder
Record RTSP streams infinitely

## Purpose

This script records RTSP streams from my home security cameras:

 * From each configured camera it will record full quality videos
 * From each configured camera it will record low quality videos
 * Videos are recorded in short time chunks
 * After configured time, old chunks are deleted
 
## Installation

### Install from repository

```bash
wget -O - https://packages.windmaker.net/WINDMAKER-GPG-KEY.pub | sudo apt-key add -
sudo add-apt-repository "deb http://packages.windmaker.net/ any main"
sudo apt-get update
sudo apt-get install windmaker-infiniterecorder
```

### Install deb package from CI pipelines

Look for letest artifact generated in [Repo CI Pipelines](https://git.windmaker.net/a-castellano/InfiniteRecorder/-/jobs)

## Configuration
### Config file

*windmaker-infiniterecorder* will look for config file placed in */etc/default/windmaker-infiniterecorder*
```bash
#!/bin/bash

VIDEO_LENGTH="0:15"
OWNER_USER="alvaro"
RECORDING_FOLDER="/home/alvaro/recordings"
RAW_VIDEO_DELETE_TIME=480
REDUCED_VIDEO_DELETE_TIME=480
WEBCAM_INSTANCES=("WebCamOne" "WebCamTwo")

declare -A WEBCAM_INSTANCES_INFO

WEBCAM_INSTANCES_INFO["WebCamOne_IP"]="10.10.10.10"
WEBCAM_INSTANCES_INFO["WebCamOne_PORT"]="554"
WEBCAM_INSTANCES_INFO["WebCamOne_RTSP_URL"]="/h264Preview_01_main"
WEBCAM_INSTANCES_INFO["WebCamOne_FFMPEG_OPTIONS"]="-c copy"
WEBCAM_INSTANCES_INFO["WebCamOne_USER"]="admin"
WEBCAM_INSTANCES_INFO["WebCamOne_PASSWORD"]="pass"

WEBCAM_INSTANCES_INFO["WebCamTwo_IP"]="10.10.10.11"
WEBCAM_INSTANCES_INFO["WebCamTwo_PORT"]="554"
WEBCAM_INSTANCES_INFO["WebCamTwo_RTSP_URL"]="/h264Preview_01_main"
WEBCAM_INSTANCES_INFO["WebCamTwo_FFMPEG_OPTIONS"]="-c copy"
WEBCAM_INSTANCES_INFO["WebCamTwo_USER"]="admin"
WEBCAM_INSTANCES_INFO["WebCamTwo_PASSWORD"]="pass"

```

## Service management

Service can be started using systemd:
```bash
systemctl start windmaker-infiniterecorder.service
```

Pacakge will create a cron file containing removal tasks:
```bash
# cat /etc/cron.d/windmaker-infiniterecorder
*/2 * * * * root flock -x -w 30 /tmp/windmaker-infiniterecorder-video-manager.lock -c '/usr/bin/windmaker-infiniterecorder-video-manager'
```

## Development tips

### Set source variables during development proccess

Assuming dev config file is placed in file name *config*, script can be biulded and managed as follows:
```bash
make; set -a ;source config; set +a; ./windmaker-infiniterecorde
```
