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
VIDEO_LENGTH="0:15" # Lenght of chunk videos
OWNER_USER="alvaro"
RECORDING_FOLDER="/home/alvaro/recordings"
# WebCam and Vault cluster Info is available inside a consul cluster
CONSUL_CLUSTER="consul01.windmaker.net,consul02.windmaker.net,consul03.windmaker.net"
CONSUL_PORT=8500
WEBCAM_CONSUL_TOKEN="Consul_TOKEN"
VAULT_CONSUL_TOKEN="Consul_TOKEN"
VAULT_USER="readwebcamsecrets"
VAULT_PASSWORD="vault_password"
RAW_VIDEO_DELETE_TIME=600
REDUCED_VIDEO_DELETE_TIME=2160
```


### Consul config

#### WebCam Declararion

Webcam service declaration will require certain meta variables that *windmaker-infiniterecorder* will read, here is an example of webcam service:
```json
{
  "ID": "webcamtest",
  "Name": "WebCamTest",
  "Tags": ["webcam"],
  "Address": "BB.AA.XX.YY",
  "Port": 80,
  "Meta": {
    "streamPort": "554",
    "stramURL": "/h264Preview_01_main",
    "serviceName": "WebCam Test",
    "ffmpegExtraOptions": "-c copy"
  },
  "EnableTagOverride": false,
  "check": {
    "name": "Check WebCam Test",
    "http": "http://BB.AA.XX.YY",
    "method": "GET",
    "interval": "60s",
    "timeout": "5s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
```

Service can be declared in Consul as follows:
```bash
curl --header "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" --request PUT --data @webcamtrasera.json http://127.0.0.1:8500/v1/agent/service/register?replace-existing-checks=true
```

It is recomended to configure *windmaker-infiniterecorder* for using a consul policy only able to read webcam info and other for vault info. 


### Vault config

*windmaker-infiniterecorder* expects a kv folder called webcam where each there is a secret for each webcam with the seame name as Consul service *Name*

```json
{
  "password": "The_Password"",
  "user": "admin"
}
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
