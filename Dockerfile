# Use the specified image
FROM rocm/pytorch:rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1

# Set the work directory
WORKDIR /dockerx/stable-diffusion-webui

# Install google-perftools using apt
RUN apt-get update && apt-get install -y --no-install-recommends \
  google-perftools=2.9.1-0ubuntu3 \
  git=1:2.34.1-1ubuntu1.10 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Clone repository into specified directory
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /dockerx/stable-diffusion-webui \
  && git checkout 5ef669de080814067961f28357256e8fe27544f4 
# Create a virtual environment, upgrade pip and wheel in the venv, then install rocm enabled pytorch
RUN python3.10 -m venv /dockerx/stable-diffusion-webui/venv \
  && /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install --upgrade pip wheel"

### BEGINNING OF REPOSITORIES ###
RUN git clone https://github.com/salesforce/BLIP.git /dockerx/stable-diffusion-webui/repositories/BLIP \
  && cd /dockerx/stable-diffusion-webui/repositories/BLIP \
  && git checkout 48211a1594f1321b00f14c9f7a5b4813144b2fb9 \
  && git clone https://github.com/sczhou/CodeFormer.git /dockerx/stable-diffusion-webui/repositories/CodeFormer \
  && cd /dockerx/stable-diffusion-webui/repositories/CodeFormer \
  && git checkout c5b4593074ba6214284d6acd5f1719b6c5d739af \
  && git clone https://github.com/Stability-AI/generative-models.git /dockerx/stable-diffusion-webui/repositories/generative-models \
  && cd /dockerx/stable-diffusion-webui/repositories/generative-models \
  && git checkout 45c443b316737a4ab6e40413d7794a7f5657c19f \
  && git clone https://github.com/crowsonkb/k-diffusion.git /dockerx/stable-diffusion-webui/repositories/k-diffusion \
  && cd /dockerx/stable-diffusion-webui/repositories/k-diffusion \
  && git checkout ab527a9a6d347f364e3d185ba6d714e22d80cb3c \
  && git clone https://github.com/Stability-AI/stablediffusion.git /dockerx/stable-diffusion-webui/repositories/stable-diffusion-stability-ai \
  && cd /dockerx/stable-diffusion-webui/repositories/stable-diffusion-stability-ai \
  && git checkout cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf
### END OF REPOSITORIES ###

COPY requirements.gen.txt /dockerx/stable-diffusion-webui/requirements.gen.txt

# Install the requirements.txt file
RUN /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install -r requirements.gen.txt && \
    pip install --force-reinstall torch torchvision --index-url https://download.pytorch.org/whl/rocm5.6"

# Copy some of the scripts and files into the container
COPY config.json /dockerx/stable-diffusion-webui/config.json
COPY models/*.vae.pt /dockerx/stable-diffusion-webui/models/VAE/
COPY models/*.safetensors /dockerx/stable-diffusion-webui/models/Stable-diffusion/
COPY .env .env
COPY run.sh run.sh
COPY dl.sh dl.sh

# Make both the run.sh and dl.sh files executable
RUN chmod +x /dockerx/stable-diffusion-webui/run.sh /dockerx/stable-diffusion-webui/dl.sh

# Expose port 7860 to signal that this container listens on that port at runtime
EXPOSE 7860
