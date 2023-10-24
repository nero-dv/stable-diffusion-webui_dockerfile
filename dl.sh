#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <URL>"
  echo "   eg: $0 https://civitai.com/api/download/models/xxxxx"
  exit 1
fi

URL=${1}
DESTINATION=/dockerx/stable-diffusion-webui/models/Stable-diffusion

LASTDIR=$(pwd)

source ./env/.env

# echo "${URL}" | grep -q "api" || echo "ERROR: Incorrect URL provided, you must provide the Download link from CivitAI, not the link to the model page."

echo "Downloading model from ${URL}, please wait..."

cd "${DESTINATION}" || echo "ERROR: Unable to change directory to ${DESTINATION}"

curl -J -L --remote-name -A "${USER_AGENT_STRING}" "${URL}" || echo "ERROR: curl command failed. Unable to download the file."

echo "Model downloaded successfully!"

cd "${LASTDIR}" || echo "ERROR: Unable to change directory to ${LASTDIR}"

exit 0