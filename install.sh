#!/bin/bash
# -- Check envs
conda info -e

# -- Activate conda
conda update -n base -c defaults conda
pip install --upgrade pip
conda create -y -n lean4ai python=3.10.11
conda activate lean4ai
#conda remove --name lean4ai --all

# -- Install this library from source
# - Get the code, put it in afs so its available to all machines and symlink it to home in the local machine
cd /afs/cs.stanford.edu/u/brando9/
git clone git@github.com:brando90/lean4ai.git
ln -s /afs/cs.stanford.edu/u/brando9/lean4ai $HOME/lean4ai
# - Install the library in editable mode so that changes are reflected immediately in running code
pip install -e ~/lean4ai
# pip uninstall ~/lean4ai
cd ~/lean4ai

# -- Test pytorch
python -c "import torch; print(torch.__version__); print(torch.version.cuda); print((torch.randn(2, 4).cuda() @ torch.randn(4, 1).cuda()))"
python -c "import torch; print(torch.version.cuda); print((torch.randn(2, 4).cuda() @ torch.randn(4, 1).cuda()))"
python -c "import torch; print(f'{torch.cuda.device_count()=}'); print(f'Device: {torch.cuda.get_device_name(0)=}')"

# -- Wandb
pip install wandb --upgrade
wandb login
#wandb login --relogin
cat ~/.netrc
