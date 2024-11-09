#!/bin/bash

# Exit on any error
set -e

# Function to run commands and check for errors
run_command() {
    local command="$1"
    echo "Running: $command"
    if ! eval "$command"; then
        echo "Error executing command: $command"
        exit 1
    fi
}

# Function to check if CUDA is available
check_cuda() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo "Error: NVIDIA driver not found. Please install NVIDIA drivers first."
        exit 1
    fi
    echo "CUDA check passed. Found NVIDIA drivers:"
    nvidia-smi
}

# Function to check if Miniconda is already installed
check_miniconda() {
    if [ -d "$HOME/miniconda" ]; then
        echo "Miniconda is already installed at $HOME/miniconda"
        return 0
    fi
    return 1
}

# Function to verify downloaded files
verify_download() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: Downloaded file $file not found"
        exit 1
    fi
}

# Check CUDA first
check_cuda

# Update and upgrade the system
echo "Updating and upgrading the system..."
run_command "apt update"
run_command "DEBIAN_FRONTEND=noninteractive apt upgrade -y"

# Install required packages
echo "Installing required packages..."
run_command "DEBIAN_FRONTEND=noninteractive apt install -y nano git build-essential g++=4:9.3.0-1ubuntu2 nvidia-cuda-toolkit ffmpeg wget"

# Install Miniconda if not already installed
if ! check_miniconda; then
    echo "Downloading and installing Miniconda..."
    MINICONDA_FILE="$HOME/miniconda.sh"
    run_command "wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $MINICONDA_FILE"
    verify_download "$MINICONDA_FILE"
    run_command "bash $MINICONDA_FILE -u -b -p $HOME/miniconda"
    run_command "rm $MINICONDA_FILE"
fi

# Add Conda to PATH if not already added
if ! grep -q "miniconda/bin" ~/.bashrc; then
    echo "Adding Conda to PATH..."
    echo 'export PATH=$HOME/miniconda/bin:$PATH' >> ~/.bashrc
fi

# Initialize Conda
echo "Initializing Conda..."
source "$HOME/miniconda/bin/conda" || source "$HOME/miniconda/etc/profile.d/conda.sh"
run_command "conda init bash"

# Create new Conda environment
echo "Creating Conda environment 'roop'..."
if conda env list | grep -q "roop"; then
    echo "Environment 'roop' already exists. Removing..."
    run_command "conda env remove -n roop -y"
fi
run_command "conda create -n roop python=3.10 cudatoolkit=11.8 -y"

# Clone and setup roop-unleashed
echo "Setting up roop-unleashed..."
if [ -d "roop-unleashed" ]; then
    echo "Removing existing roop-unleashed directory..."
    rm -rf roop-unleashed
fi

# Setup roop in a subshell with proper activation
(
    source "$HOME/miniconda/etc/profile.d/conda.sh"
    conda activate roop || exit 1
    
    # Clone repository
    git clone https://github.com/C0untFloyd/roop-unleashed.git || exit 1
    cd roop-unleashed || exit 1
    
    # Modify UI files for sharing
    sed -i '77s/share=roop.globals.CFG.server_share/share=True/' ui/main.py
    sed -i '81s/gradio_interface.share = roop.globals.CFG.server_share/gradio_interface.share = True/' ui/main.py
    
    # Install requirements
    pip install -r requirements.txt || exit 1
    
    # Run the application
    python run.py
)

# Check if the subshell failed
if [ $? -ne 0 ]; then
    echo "Error: Failed to setup and run roop-unleashed"
    exit 1
fi

