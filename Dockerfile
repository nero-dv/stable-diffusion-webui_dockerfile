# Use the specified image
FROM rocm/pytorch:rocm5.7_ubuntu22.04_py3.10_pytorch_2.0.1

# Set the work directory
WORKDIR /dockerx

# Install google-perftools using apt
RUN apt-get update && apt-get install -y google-perftools

# Install git
RUN apt-get install -y git

# Clone repository into specified directory
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /dockerx/stable-diffusion-webui || \
    echo "Failed to clone repository"

# Navigate to the stable-diffusion-webui directory and checkout the tested commit
RUN cd /dockerx/stable-diffusion-webui && \
    git checkout 5ef669de080814067961f28357256e8fe27544f4 || \
    echo "Failed to checkout commit 5ef669de080814067961f28357256e8fe27544f4"

# Create a virtual environment, upgrade pip and wheel in the venv, then install rocm enabled pytorch
RUN python3.10 -m venv /dockerx/stable-diffusion-webui/venv && \
    /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install --upgrade pip wheel"

### BEGINNING OF REPOSITORIES ###

# # BLIP
# RUN cd /dockerx/stable-diffusion-webui/repositories && \
#     git clone https://github.com/salesforce/BLIP.git && \
#     cd BLIP && \
#     git checkout 48211a1594f1321b00f14c9f7a5b4813144b2fb9 || \
#     echo "Failed to checkout commit 48211a1594f1321b00f14c9f7a5b4813144b2fb9"
# # RUN cd /dockerx/stable-diffusion-webui/repositories && \
# #     cd BLIP && \
# #     pip install -r requirements.txt && \
# #     pip install -e .

# # CodeFormer
# RUN cd /dockerx/stable-diffusion-webui/repositories && \
#     git clone https://github.com/sczhou/CodeFormer.git && \
#     cd CodeFormer && \
#     git checkout c5b4593074ba6214284d6acd5f1719b6c5d739af || \
#     echo "Failed to checkout commit c5b4593074ba6214284d6acd5f1719b6c5d739af"
# # RUN cd /dockerx/stable-diffusion-webui/repositories && \
# #     cd CodeFormer && \
# #     pip install -r requirements.txt && \
# #     pip install -e .

# # Stability-AI/generative-models
# RUN cd /dockerx/stable-diffusion-webui/repositories && \
#     git clone https://github.com/Stability-AI/generative-models.git && \
#     cd generative-models && \
#     git checkout 45c443b316737a4ab6e40413d7794a7f5657c19f || \
#     echo "Failed to checkout commit 45c443b316737a4ab6e40413d7794a7f5657c19f"
# # RUN cd /dockerx/stable-diffusion-webui/repositories && \
# #     cd generative-models && \
# #     pip install -e .

# # k-diffusion
# RUN cd /dockerx/stable-diffusion-webui/repositories && \
#     git clone https://github.com/crowsonkb/k-diffusion.git && \
#     cd k-diffusion && \
#     git checkout ab527a9a6d347f364e3d185ba6d714e22d80cb3c || \
#     echo "Failed to checkout commit ab527a9a6d347f364e3d185ba6d714e22d80cb3c"
# # RUN cd /dockerx/stable-diffusion-webui/repositories && \
# #     cd k-diffusion && \
# #     pip install -r requirements.txt && \
# #     pip install -e .

# # Stability-AI/stablediffusion
# RUN cd /dockerx/stable-diffusion-webui/repositories && \
#     git clone https://github.com/Stability-AI/stablediffusion.git && \
#     cd stablediffusion && \
#     git checkout cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf || \
#     echo "Failed to checkout commit cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf"
# # RUN cd /dockerx/stable-diffusion-webui/repositories && \
# #     cd stablediffusion && \
# #     pip install -r requirements.txt && \
# #     pip install -e .

### END OF REPOSITORIES ###

COPY requirements.gen.txt /dockerx/stable-diffusion-webui/requirements.gen.txt

# Install the requirements.txt file
RUN cd /dockerx/stable-diffusion-webui && \
    /bin/bash -c "source /dockerx/stable-diffusion-webui/venv/bin/activate && pip install -r requirements.gen.txt && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6"

# # Uninstall pytorch
# RUN cd /dockerx/stable-diffusion-webui && \
#     pip uninstall torch torchvision torchaudio -y 

# # Install pytorch-rocm5.6
# RUN cd /dockerx/stable-diffusion-webui && \
#     pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6

# # Download sd v1,5 directly, allowing docker build caching to be used for future builds if needed
# RUN wget -O /dockerx/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# Copy the v1-5-pruned-emaonly.safetensors file into the appropriate stable-diffusion-webui models directory
COPY v1-5-pruned-emaonly.safetensors /dockerx/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors

# Copy any existing .vae.pt into the VAE directory
COPY models/*.vae.pt /dockerx/stable-diffusion-webui/models/VAE/

# Copy any existing models into the models directory
COPY models/*.safetensors /dockerx/stable-diffusion-webui/models/Stable-diffusion/

# Copy the run.sh file into the dockerx directory
COPY run.sh /dockerx/run.sh

# Copy the config.json file into the stable-diffusion-webui directory
COPY config.json /dockerx/stable-diffusion-webui/config.json

# Copy the dl.sh file and the env folder into /dockerx/
COPY dl.sh /dockerx/dl.sh
COPY env /dockerx/env

# Make both the run.sh and dl.sh files executable
RUN chmod +x /dockerx/run.sh
RUN chmod +x /dockerx/dl.sh

# Expose port 7860 to signal that this container listens on that port at runtime
EXPOSE 7860