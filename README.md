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
git clone -b main git@github.com:brando90/lean4ai.git
cd $HOME/lean4ai
pip install -e .
```
The installation uses `pyproject.toml` for modern Python packaging, which:
- Installs all required dependencies automatically
- Sets up the project in editable mode for development

Now install ZIP-FIT to use pass @ k AF with Lean:
```bash
# Get ZIPFIT (for pass @ k for AF with Lean)
cd $HOME
# Clone the ZIP-FIT repository and check out the bm_dev branch
git clone --recurse-submodules -b bm_dev git@github.com:stair-lab/ZIP-FIT.git 
cd $HOME/ZIP-FIT 
pip install -e .
```
Now to install the rest of ZIP-FIT follow the instructions here: https://github.com/stair-lab/ZIP-FIT/tree/bm_dev?tab=readme-ov-file#2-install-vllm--eleutherai-harness

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
