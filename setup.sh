#!/bin/bash

# Function to run commands and check for errors
run_command() {
    local command=$1
    echo "Running: $command"
    $command
    if [ $? -ne 0 ]; then
        echo "Error executing command: $command"
        exit 1
    fi
}

# Update and upgrade the system
echo "Updating and upgrading the system..."
run_command "apt update"
run_command "apt upgrade -y"

# Install required packages (using base version of g++)
echo "Installing required packages..."
run_command "apt install -y nano git build-essential g++ nvidia-cuda-toolkit ffmpeg"

# Add CUDA to PATH
echo "Adding CUDA to PATH..."
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
source ~/.bashrc

# Download and install Miniconda
echo "Downloading and installing Miniconda..."
run_command "wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda.sh"
run_command "bash $HOME/miniconda.sh -u -b -p $HOME/miniconda"

# Add Conda to PATH
echo "Adding Conda to PATH..."
echo 'export PATH=$HOME/miniconda/bin:$PATH' >> ~/.bashrc

# Initialize Conda
echo "Initializing Conda..."
run_command "$HOME/miniconda/bin/conda init"

# Source the bashrc file to ensure conda is initialized properly
echo "Applying changes to the shell..."
source ~/.bashrc

# Create Conda environment 'roop' with Python 3.10 and cudatoolkit 11.8
echo "Creating Conda environment 'roop'..."
run_command "conda create -n roop python=3.10 cudatoolkit=11.8 -y"

# Force activate Conda environment and run commands in it
echo "Activating Conda environment and running commands..."

# Running commands within the 'roop' environment using bash -i
bash -i -c "
    conda activate roop && 
    git clone https://github.com/C0untFloyd/roop-unleashed.git && 
    cd roop-unleashed && 
    sed -i '77s/share=roop.globals.CFG.server_share/share=True/' ui/main.py && 
    sed -i '81s/gradio_interface.share = roop.globals.CFG.server_share/gradio_interface.share = True/' ui/main.py &&
    pip install -r requirements.txt &&
    python run.py
"

