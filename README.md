# Can Lean4 (and thus Formal Methods) Improve Language Models (LMs)?

# Installation

## 1. Create & Activate the lean4ai Conda Environment
```bash
cd $HOME
conda create -y -n lean4ai python=3.10
conda activate lean4ai
conda activate lean4ai
pip install --upgrade pip
```

## 2. Clone and Install lean4ai
```bash
cd $HOME
# Clone the lean4ai repository and initialize all submodules recursively
git clone -b main git@github.com:brando90/lean4ai.git
pip install -e ~/lean4ai
```
The installation uses `pyproject.toml` for modern Python packaging, which:
- Installs all required dependencies automatically
- Sets up the project in editable mode for development

Now install ZIP-FIT to use pass @ k AF with Lean:
```bash
# Clone the ZIP-FIT repository (SSH) and recursively initialize any submodules
git clone --recurse-submodules git@github.com:stair-lab/ZIP-FIT.git
# Change directory into the newly cloned ZIP-FIT repo
cd ZIP-FIT
# Fetch the latest changes and branches from the remote
git fetch origin
# Show all local and remote branches
git branch -a
# Create and switch to the 'bm_dev' branch, tracking remote 'origin/bm_dev'
git checkout -b bm_dev origin/bm_dev
# Display branch details, including local/remote tracking and commit differences
git branch -vv
# Install ZIP-FIT in editable mode, so local changes are reflected immediately
pip install -e ~/ZIP-FIT

# Verify install
pip list | grep zip_fit
pip list | grep lm_eval
pip list | grep vllm
pip list | grep antlr4
# Expected output:
# zip_fit                           1.0.8         /lfs/ampere8/0/brando9/ZIP-FIT
# lm_eval                           0.4.8
# vllm                              0.6.4.post1
# antlr4-python3-runtime            4.11.0 
```
Now to install the rest of ZIP-FIT follow the instructions here: 

# Appendix

### lean4agi
LeanDojo lean4 dataset: https://zenodo.org/records/10114185

Processed leam4 dataset: https://huggingface.co/datasets/akjadhav/leandojo-lean4-formal-informal-strings


## To deinitialize the ZIP-FIT git submodule

```bash
# 1) Change to the repository root
cd ~/lean4ai

# 2) Deinitialize the submodule (removes it from .git/config)
git submodule deinit -f ZIP-FIT

# 3) Remove the submodule from Git's index (this unregisters the submodule)
git rm -f ZIP-FIT

# 4) Remove the actual submodule directory from disk
rm -rf ZIP-FIT/

# 5) Delete leftover metadata for the submodule
rm -rf .git/modules/ZIP-FIT

# 6) Remove the entire .gitmodules file (if ZIP-FIT is your only submodule)
rm -f .gitmodules

# 7) Commit the changes so the repository no longer references the submodule
git commit -am "Completely remove ZIP-FIT submodule"
```
