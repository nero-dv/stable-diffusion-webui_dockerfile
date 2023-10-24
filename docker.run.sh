#!/usr/bin/env bash

# sudo rm -rf /mnt/rocm_pytorch/dockerx/output || true
sudo mkdir -p /mnt/rocm_pytorch/dockerx/output || true
sudo chmod -R 777 /mnt/rocm_pytorch/dockerx/output || true
sudo docker run \
    --restart=always \
    -p 7860:7860 \
    --device=/dev/kfd \
    --device=/dev/dri \
    --group-add=video \
    --ipc=host \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --volume /mnt/rocm_pytorch/dockerx/output:/dockerx/output \
    sdwebui:rev4 \
    /bin/bash -c "/dockerx/run.sh"