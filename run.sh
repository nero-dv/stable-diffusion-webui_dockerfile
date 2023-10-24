#!/usr/bin/env bash

export APP=/dockerx/stable-diffusion-webui

cd $APP || return

# activate venv
# shellcheck source=/dev/null
source $APP/venv/bin/activate

# run launch.py
python $APP/launch.py --listen