# InfiniteRecorder
Record RTSP streams infinitely

## Purpose

This script records RTSP streams from my home security cameras:

 * From each configured camera it will record full quality videos (if configured)
 * From each configured camera it will record low quality videos
 * Videos are recorded in short time chunks
 * Each day old videos are marged in bigger chunks
 * After configured time, old chunks are deleted
 
## Installation

### Install from repository

```bash
wget -O - https://packages.windmaker.net/WINDMAKER-GPG-KEY.pub | sudo apt-key add -
sudo add-apt-repository "deb http://packages.windmaker.net/ any main"
sudo apt-get update
sudo apt-get install windmaker-infiniterecorder
```

### Install deb ir arch linux package from CI pipelines

Look for letest artifact generated in [Repo CI Pipelines](https://git.windmaker.net/a-castellano/InfiniteRecorder/-/jobs)

## Configuration
### Config file

*windmaker-infiniterecorder* will look for config file placed in *ENV_FILE* environment variable value
```bash
#!/bin/bash

VIDEO_LENGTH="0:15"
OWNER_USER="alvaro"
RECORDING_FOLDER="/home/alvaro/recordings"
RAW_VIDEO_DELETE_TIME=43200 # Seconds
REDUCED_VIDEO_DELETE_TIME=43200 # Seconds
MERGED_VIDEO_PERIOD="15:00"
WEBCAM_INSTANCES=("WebCamOne" "WebCamTwo")

declare -A WEBCAM_INSTANCES_INFO

WEBCAM_INSTANCES_INFO["WebCamOne_IP"]="10.10.10.10"
WEBCAM_INSTANCES_INFO["WebCamOne_PORT"]="554"
WEBCAM_INSTANCES_INFO["WebCamOne_RTSP_URL"]="/h264Preview_01_main"
WEBCAM_INSTANCES_INFO["WebCamOne_FFMPEG_OPTIONS"]="-c copy"
WEBCAM_INSTANCES_INFO["WebCamOne_USER"]="admin"
WEBCAM_INSTANCES_INFO["WebCamOne_PASSWORD"]="pass"
WEBCAM_INSTANCES_INFO["WebCamOne_REDUCED_ONLY"]=true

WEBCAM_INSTANCES_INFO["WebCamTwo_IP"]="10.10.10.11"
WEBCAM_INSTANCES_INFO["WebCamTwo_PORT"]="554"
WEBCAM_INSTANCES_INFO["WebCamTwo_RTSP_URL"]="/h264Preview_01_main"
WEBCAM_INSTANCES_INFO["WebCamTwo_FFMPEG_OPTIONS"]="-c copy"
WEBCAM_INSTANCES_INFO["WebCamTwo_USER"]="admin"
WEBCAM_INSTANCES_INFO["WebCamTwo_PASSWORD"]="pass"
WEBCAM_INSTANCES_INFO["WebCamTwo_REDUCED_ONLY"]=false
```

## Service management

Services will be installed in selected user folder during install.

*windmaker-infiniterecorder* service can be staterd as follows:
```bash
systemctl --user start windmaker-infiniterecorder.service
```

*windmaker-infiniterecorder-video-manager* service will merge videos, it will also delete old videos depending of *RAW_VIDEO_DELETE_TIME* and *REDUCED_VIDEO_DELETE_TIME*. 

This service runs using a timer that will execute video manager each day at 01:00.

It can be enabled as follows:
```bash
systemctl --user start windmaker-infiniterecorder-video-manager.service windmaker-infiniterecorder-video-manager.timer
```
## Development tips

### Set source variables during development proccess

Assuming dev config file is placed in file name *config*, script can be biulded and managed as follows:
```bash
make; set -a ;source config; set +a; ./windmaker-infiniterecorde
```
