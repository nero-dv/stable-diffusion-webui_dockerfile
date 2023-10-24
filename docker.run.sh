#!/usr/bin/env bash

export OUTPUT=/mnt/rocm_pytorch/dockerx/output
export TAG=${1}

sudo cp -r "$OUTPUT" "$OUTPUT.bak" || true
sudo rm -rf $OUTPUT || true
sudo mkdir -p $OUTPUT || true
sudo chmod -R 777 $OUTPUT || true
sudo docker run -it \
  -p 7860:7860 \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add=video \
  --ipc=host \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --volume $OUTPUT:/dockerx/output \
  sdwebui:$TAG \
  /bin/bash -c "/dockerx/stable-diffusion-webui/run.sh"
