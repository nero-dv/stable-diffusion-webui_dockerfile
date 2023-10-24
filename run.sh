#!/usr/bin/env bash

cd /dockerx/stable-diffusion-webui

# activate venv
source /dockerx/stable-diffusion-webui/venv/bin/activate

# run launch.py
python /dockerx/stable-diffusion-webui/launch.py --listen