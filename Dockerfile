# Use an official Python runtime as a parent image
FROM nvidia/cuda:11.7.0-base-ubuntu20.04

# Set the working directory
WORKDIR /app

# Install git, wget, build-essential
RUN apt-get update && apt-get install -y git wget build-essential

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH="/miniconda/bin:${PATH}"

# Clone the repository
RUN git clone https://github.com/152334H/tortoise-tts-fast.git /app/tortoise-tts-fast

# Change the working directory to the tortoise-tts-fast directory
WORKDIR /app/tortoise-tts-fast

# Create the Conda environment
RUN conda create -n ttts-fast python=3.8 && \
    echo "source activate ttts-fast" > ~/.bashrc
ENV PATH /miniconda/envs/ttts-fast/bin:$PATH

# Set the shell for the following commands to use the Conda environment "ttts-fast"
SHELL ["conda", "run", "-n", "ttts-fast", "/bin/bash", "-c"]

# Install the necessary packages
RUN conda install -y pytorch==1.13.1 torchvision==0.14.1 torchaudio==0.13.1 -c pytorch -c nvidia && \
    conda install -c anaconda gdbm && \
    pip install -e . && \
    pip install git+https://github.com/152334H/BigVGAN.git && \
    pip install streamlit

# Make port 8501 available to the world outside this container
EXPOSE 8501

# Define environment variable
ENV NAME tortoise-tts

# List the contents of the /app directory
RUN ls -al /app

# Run the application
CMD ["streamlit", "run", "scripts/app.py"]
