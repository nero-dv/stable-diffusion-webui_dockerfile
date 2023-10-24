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

# Navigate to the stable-diffusion-webui directory and checkout the tested commit
RUN cd /dockerx/stable-diffusion-webui && \
    git checkout 5ef669de080814067961f28357256e8fe27544f4

# Create a virtual environment, upgrade pip and wheel in the venv, then install rocm enabled pytorch
RUN python3.10 -m venv /dockerx/stable-diffusion-webui/venv && \
    /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install --upgrade pip wheel \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6"

# Download sd v1,5 directly, allowing docker build caching to be used for future builds if needed
RUN wget -O /dockerx/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# Copy the run.sh file into the dockerx directory
COPY run.sh /dockerx/run.sh

# Copy the config.json file into the stable-diffusion-webui directory
COPY config.json /dockerx/stable-diffusion-webui/config.json

# Make both the run.sh and prepare_env.sh files executable
RUN chmod +x /dockerx/run.sh

# Expose port 7860 to signal that this container listens on that port at runtime
EXPOSE 7860