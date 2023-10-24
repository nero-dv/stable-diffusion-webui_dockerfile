#!/usr/bin/env bash

export APP=/dockerx/stable-diffusion-webui

cd $APP

# activate venv
source $APP/venv/bin/activate

# run launch.py
python $APP/launch.py --listen