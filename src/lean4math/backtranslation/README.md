## Description

This folder contains code for running experiments with on-the-fly backtranslation.
CS197 Project: Lean4math

## Relevant files
- train.py: Training loop that fine-tunes a model (currently GPT-2 and Gemma-2B) for autoformalization.
- unsupervised_trainer.py: Implementation of UnsupervisedTrainer, a subclass of HuggingFace's Trainer that handles on-the-fly data generation.
- evaluate.py: Code to evaluate a pretrained model on ProofNet's test dataset.
- demo.py: Code to manually test a pretrained model's translations.
- dataset_utils.py: Methods for loading and preprocessing datasets for use for autoformalization.
