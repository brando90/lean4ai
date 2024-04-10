# Can Formal Methods Improve Language Models?

lean4agi &amp; lean4math

## Installation

Create a conda env and make sure everything is up to date (please don't run commands blidly, read what you're doing and the output otherwise you won't be able to debug it):
```bash
# -- Activate conda
conda update -n base -c defaults conda
pip install --upgrade pip
conda create -y -n lean4ai python=3.9
conda activate lean4ai
```
Install this library in editable mode (make sure you understand what editable mode is, google the command bellow! Also, make sure you read the comments in the `setup.py` so you understand why and how we are setting up this python project following roughly the python standards):
```bash
cd $HOME/lean4ai
pip install -e . 
# or pip install -e ~/lean4ai
```
then make sure your install and gpu works + that you are using the version of python and binary/python you expect:
```bash
# see python you're using
which python
# test pytorch & gpus
python -c "import torch; print(torch.__version__); print(torch.version.cuda); print((torch.randn(2, 4).cuda() @ torch.randn(4, 1).cuda()))"
python -c "import torch; print(torch.version.cuda); print((torch.randn(2, 4).cuda() @ torch.randn(4, 1).cuda()))"
python -c "import torch; print(f'{torch.cuda.device_count()=}'); print(f'Device: {torch.cuda.get_device_name(0)=}')"
# test python installation and project setup is working
# python src/hello_world_snap.py
# or python /lfs/skampere1/0/brando9/lean4ai/src/hello_world.py
python $HOME/lean4ai/src/hello_world.py
```

For tips and more details see the [`snap cluster setup repo`](https://github.com/brando90/snap-cluster-setup) for detailed installatio tips for python, conda etc. and tutorial [with questions/assignments](https://docs.google.com/document/d/1k3d3_AOp-Y22L-GbgHivDqKe9r9LC5nscaIzbm3LWYc/edit?usp=sharing). 

## lean4agi
LeanDojo lean4 dataset: https://zenodo.org/records/10114185

Processed leam4 dataset: https://huggingface.co/datasets/akjadhav/leandojo-lean4-formal-informal-strings

## lean4math

Research journal: https://docs.google.com/document/d/1eZ9l-tQVUaWYq38pnB9xit6Z4noqZHh_6U7vX5IuY0Q/edit
