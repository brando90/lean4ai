https://huggingface.co/AI4M/gemma2-2b-gpt4-more-dataset (1 epoch)
https://huggingface.co/AI4M/gemma2-2b-gpt4-more-5-epochs (5 epoch)
https://huggingface.co/AI4M/gemma-2-2b-mma-dataset

https://huggingface.co/AI4M/gpt2-mma-dataset
# https://huggingface.co/AI4M/gpt2-gpt4-more

# - Run pass@k evaluation for Lean4
# conda activate
export model_name='AI4M/gemma2-2b-gpt4-more-dataset' # 1 epoch
# export model_name='AI4M/gemma2-2b-gpt4-more-dataset-5-epochs' # 1 epoch
# export model_name='AI4M/gemma2-2b-gpt4-mma-dataset' # 1 epoch
echo ${model_name}

# export model_name='AI4M/gpt2-mma-dataset'
# export model_name='AI4M/gpt2-gpt4-more'

export eval_batch_size=32
export eval_batch_size=1024
export eval_batch_size=1300
# export eval_batch_size=32
export k=200 # the k specific the actualy metric for pass@k
export num_samples=${eval_batch_size} # the big N in pass@k - total number of completions generated
export num_samples=300 # the big N in pass@k - total number of completions generated
export eval_dataset='UDACA/proofnet-v3-lean4'
export split_name='test'
export prompt_fn_name='prompt_temp_fn_lean4_minif2f_val_v0'

# export mode='dryrun'
export mode='online'

conda activate zip_fit
# export CUDA_VISIBLE_DEVICES=0
export CUDA_VISIBLE_DEVICES=$(nvidia-smi --query-gpu=index,memory.free --format=csv,noheader,nounits | sort -t, -k2 -nr | head -n1 | cut -d',' -f1 | tr -d ' ')
python ~/ZIP-FIT/zip_fit/main/main_eval_pass_at_k_af.py \
    --mode ${mode} \
    --main_fn_name main_eval_lean4_model_performance_pass_at_k \
    --model_name ${model_name} \
    --eval_dataset ${eval_dataset} \
    --split_name ${split_name} \
    --eval_batch_size ${eval_batch_size} \
    --k ${k} \
    --num_samples ${num_samples} \
    --prompt_fn_name ${prompt_fn_name}
