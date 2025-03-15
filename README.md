# Can Lean4 (and thus Formal Methods) Improve Language Models (LMs)?

# Installation

## 1. Create & Activate the lean4ai Conda Environment
```bash
cd $HOME
conda create -y -n lean4ai python=3.10
pip install --upgrade pip
conda activate lean4ai
```

## 2. Clone and Install lean4ai
```bash
cd $HOME
# Clone the lean4ai repository and initialize all submodules recursively
git clone --recurse-submodules -b main git@github.com:brando90/lean4ai.git
cd $HOME/lean4ai

# Check if .gitmodules exists; if not, initialize and update submodules
if [ ! -f .gitmodules ]; then # If .gitmodules is missing, add and update submodules recursively
    cd $HOME/lean4ai
    # Adds the ZIP-FIT submodule (creates/updates .gitmodules automatically)
    git submodule add -b bm_dev git@github.com:stair-lab/ZIP-FIT.git 
    # Reads .gitmodules and registers submodules in .git/config (does not clone/update them)
    git submodule init  
    # Fetches latest commits from remote for submodules, including nested ones
    git submodule update --recursive --remote  
fi

# Install submodule
cd $HOME/lean4ai/ZIP-FIT
pip install -e .
```
Note: if you create a submodule and misname it you might have to do this:
```bash
# Correcting a Misnamed Git Submodule
# 1. Deinitialize the incorrect submodule
git submodule deinit <incorrect_submodule_name>
# 2. Remove the incorrect submodule directory
rm -rf <incorrect_submodule_directory> 
# Example: rm -rf zipfit
# 3. Remove the incorrect submodule from Git's index
git rm --cached <incorrect_submodule_directory>
```

Now install the project:
```bash
# Install the package in editable mode with all dependencies
pip install -e ~/lean4ai
```
The installation uses `pyproject.toml` for modern Python packaging, which:
- Installs all required dependencies automatically
- Sets up the project in editable mode for development

## 3. Verify Installation

Run the following commands to verify your installation:

```bash
# 1. Check Python version and location
which python
python --version 

# 2. Verify the package is installed
python -c "import lean4ai; print('lean4ai package successfully imported')"

# 3. Test GPU
python -c "import torch; print('GPU computation test:'); print(torch.randn(2, 4).cuda() @ torch.randn(4, 1).cuda())"
```

# Appendix

### lean4agi
LeanDojo lean4 dataset: https://zenodo.org/records/10114185

Processed leam4 dataset: https://huggingface.co/datasets/akjadhav/leandojo-lean4-formal-informal-strings
