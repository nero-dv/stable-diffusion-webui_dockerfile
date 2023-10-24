#!/usr/bin/env bash

export OUTPUT=/mnt/rocm_pytorch/dockerx/output
export TAG=${1} || "release"

docker image rm sdwebui:"$TAG" || true
sudo cp -r "$OUTPUT" "$OUTPUT.bak" || true
sudo rm -rf $OUTPUT || true
sudo mkdir -p $OUTPUT || true
sudo chmod -R 777 $OUTPUT || true
sudo docker run \
    -p 7860:7860 \
    --device=/dev/kfd \
    --device=/dev/dri \
    --group-add=video \
    --ipc=host \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --volume $OUTPUT:/dockerx/output \
    --name="sdwebui-$TAG" \
    sdwebui:"$TAG"
    # /bin/bash -c "/dockerx/run.sh"