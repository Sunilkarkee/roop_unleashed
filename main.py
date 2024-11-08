import subprocess
import os

def run_command(command):
    """Executes a shell command and checks for errors."""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}")
        print(e.stderr)

def main():
    # Update and upgrade the system
    print("Updating and upgrading the system...")
    run_command("sudo apt update && sudo apt upgrade -y")

    # Install required packages (using base version of g++)
    print("Installing required packages...")
    run_command("sudo apt install -y nano git build-essential g++ nvidia-cuda-toolkit ffmpeg")

    # Add CUDA to PATH
    print("Adding CUDA to PATH...")
    with open(os.path.expanduser("~/.bashrc"), "a") as bashrc:
        bashrc.write('export PATH=$PATH:$HOME/bin\n')

    # Source the .bashrc file to apply the changes
    run_command("source ~/.bashrc")

    # Download and install Miniconda
    print("Downloading and installing Miniconda...")
    run_command("wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh")
    run_command("bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda")

    # Add conda to PATH
    os.environ["PATH"] += ":$HOME/miniconda/bin"

    # Create Conda environment
    print("Creating Conda environment...")
    run_command("conda create -n roop python=3.10 cudatoolkit=11.8 -y")
    run_command("conda activate roop")

    # Clone the repository
    print("Cloning the repository...")
    run_command("git clone https://github.com/C0untFloyd/roop-unleashed.git")
    os.chdir("roop-unleashed")

    # Edit the main.py file
    print("Editing the main.py file...")
    with open("ui/main.py", "r") as file:
        lines = file.readlines()

    # Modify the content of the file at the specified lines
    lines[77] = "    share = True\n"  # Line 78
    lines[81] = "    gradio_interface.share = True\n"  # Line 82

    with open("ui/main.py", "w") as file:
        file.writelines(lines)

    # Install the required Python dependencies
    print("Installing required Python dependencies...")
    run_command("pip install -r requirements.txt")

    # Deactivate and reactivate Conda environment before running the application
    print("Deactivating and reactivating Conda environment...")
    run_command("conda deactivate")
    run_command("conda activate roop")

    # Run the application
    print("Running the application...")
    run_command("python run.py")

if __name__ == "__main__":
    main()
