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
run_command "wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
run_command "bash Miniconda3-latest-Linux-x86_64.sh -u -b -p $HOME/miniconda"

# Add conda to PATH
echo "Adding Conda to PATH..."
export PATH=$HOME/miniconda/bin:$PATH

# Initialize conda
echo "Initializing Conda..."
run_command "conda init"

# Restart the shell or source the bash configuration
echo "Restarting the shell..."
source ~/.bashrc

# Create Conda environment
echo "Creating Conda environment..."
run_command "conda create -n roop python=3.10 cudatoolkit=11.8 -y"

# Activate the Conda environment
echo "Activating Conda environment..."
run_command "conda activate roop"

# Clone the repository
echo "Cloning the repository..."
run_command "git clone https://github.com/C0untFloyd/roop-unleashed.git"
cd roop-unleashed

# Edit the main.py file
echo "Editing the main.py file..."
sed -i '77s/share=roop.globals.CFG.server_share/share=True/' ui/main.py
sed -i '81s/gradio_interface.share = roop.globals.CFG.server_share/gradio_interface.share = True/' ui/main.py

# Install the required Python dependencies
echo "Installing required Python dependencies..."
run_command "pip install -r requirements.txt"

# Deactivate and reactivate Conda environment before running the application
echo "Deactivating and reactivating Conda environment..."
run_command "conda deactivate"
run_command "conda activate roop"

# Run the application
echo "Running the application..."
run_command "python run.py"
