# Use the specified image
FROM rocm/pytorch:rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1

# Set the work directory
WORKDIR /dockerx

# Install google-perftools using apt
RUN apt-get update && apt-get install -y google-perftools

# Install git
RUN apt-get install -y git

# Clone repository into specified directory
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /dockerx/stable-diffusion-webui

# Create a virtual environment and upgrade pip and wheel in the venv
RUN python3.10 -m venv /dockerx/stable-diffusion-webui/venv && \
    /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install --upgrade pip wheel"

# Install rocm enabled pytorch
RUN /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6"

# Download "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors" to /dockerx/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors
RUN wget -O /dockerx/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# # Copy the v1-5-pruned-emaonly.safetensors file into the appropriate stable-diffusion-webui models directory
# COPY v1-5-pruned-emaonly.safetensors /dockerx/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors

# Copy the run.sh file into the dockerx directory
COPY run.sh /dockerx/run.sh

# Copy the config.json file into the stable-diffusion-webui directory
COPY config.json /dockerx/stable-diffusion-webui/config.json

# Make both the run.sh and prepare_env.sh files executable
RUN chmod +x /dockerx/run.sh

# Expose port 7860 to signal that this container listens on that port at runtime
EXPOSE 7860