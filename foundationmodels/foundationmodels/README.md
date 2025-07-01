Notes: 
- The reported values in the meta analysis sometimes differ from the original publication (see computational.csv)

GitHub Repos:
- https://github.com/facebookresearch/dinov2
- https://github.com/openmedlab/Data-Centric-FM-Healthcare
- https://github.com/mahmoodlab/UNI
- https://huggingface.co/MahmoodLab/UNI2-h
- https://github.com/bytedance/ibot


DINOv2 default config set from github:

MODEL:
  WEIGHTS: ''
compute_precision:
  grad_scaler: true
  teacher:
    backbone:
      sharding_strategy: SHARD_GRAD_OP
      mixed_precision:
        param_dtype: fp16
        reduce_dtype: fp16
        buffer_dtype: fp32
    dino_head:
      sharding_strategy: SHARD_GRAD_OP
      mixed_precision:
        param_dtype: fp16
        reduce_dtype: fp16
        buffer_dtype: fp32
    ibot_head:
      sharding_strategy: SHARD_GRAD_OP
      mixed_precision:
        param_dtype: fp16
        reduce_dtype: fp16
        buffer_dtype: fp32
  student:
    backbone:
      sharding_strategy: SHARD_GRAD_OP
      mixed_precision:
        param_dtype: fp16
        reduce_dtype: fp16
        buffer_dtype: fp32
    dino_head:
      sharding_strategy: SHARD_GRAD_OP
      mixed_precision:
        param_dtype: fp16
        reduce_dtype: fp32
        buffer_dtype: fp32
    ibot_head:
      sharding_strategy: SHARD_GRAD_OP
      mixed_precision:
        param_dtype: fp16
        reduce_dtype: fp32
        buffer_dtype: fp32
dino:
  loss_weight: 1.0
  head_n_prototypes: 65536
  head_bottleneck_dim: 256
  head_nlayers: 3
  head_hidden_dim: 2048
  koleo_loss_weight: 0.1
ibot:
  loss_weight: 1.0
  mask_sample_probability: 0.5
  mask_ratio_min_max:
  - 0.1
  - 0.5
  separate_head: false
  head_n_prototypes: 65536
  head_bottleneck_dim: 256
  head_nlayers: 3
  head_hidden_dim: 2048
train:
  batch_size_per_gpu: 64
  dataset_path: ImageNet:split=TRAIN
  output_dir: .
  saveckp_freq: 20
  seed: 0
  num_workers: 10
  OFFICIAL_EPOCH_LENGTH: 1250
  cache_dataset: true
  centering: "centering" # or "sinkhorn_knopp"
student:
  arch: vit_large
  patch_size: 16
  drop_path_rate: 0.3
  layerscale: 1.0e-05
  drop_path_uniform: true
  pretrained_weights: ''
  ffn_layer: "mlp"
  block_chunks: 0
  qkv_bias: true
  proj_bias: true
  ffn_bias: true
  num_register_tokens: 0
  interpolate_antialias: false
  interpolate_offset: 0.1
teacher:
  momentum_teacher: 0.992
  final_momentum_teacher: 1
  warmup_teacher_temp: 0.04
  teacher_temp: 0.07
  warmup_teacher_temp_epochs: 30
optim:
  epochs: 100
  weight_decay: 0.04
  weight_decay_end: 0.4
  base_lr: 0.004  # learning rate for a batch size of 1024
  lr: 0.  # will be set after applying scaling rule
  warmup_epochs: 10
  min_lr: 1.0e-06
  clip_grad: 3.0
  freeze_last_layer_epochs: 1
  scaling_rule: sqrt_wrt_1024
  patch_embed_lr_mult: 0.2
  layerwise_decay: 0.9
  adamw_beta1: 0.9
  adamw_beta2: 0.999
crops:
  global_crops_scale:
  - 0.32
  - 1.0
  local_crops_number: 8
  local_crops_scale:
  - 0.05
  - 0.32
  global_crops_size: 224
  local_crops_size: 96
evaluation:
  eval_period_iterations: 12500
  
  
  Methodology remarks:
  
  - RudolfV:
  	- expert crafted features
  	- heavy use of clustering for patch representation and "merged by pathologists into
9 morphological meaningful clusters".


TANGLE Hyperparam:
Hyperparameter | Value
Layers | 12
Heads | 12
Patch size | 16
Head activation | GELU
Embedding dimension | 16x16x3
Drop path rate | 0.1
Global crop scale | 0.32, 1
Global crop number | 2
Local crop scale | 0.05, 0.32
Local crop number | 10
Partial prediction shape | Block 
Partial prediction ratio | 0, 0.3
Partial prediction variance | 0, 0.2
Gradient clipping | 0.3
Normalize last layer | ✓
Shared head | ✓

AdamW β |(0.9, 0.999)
Batch size | 1024
Freeze last layer epochs | 3
Warmup epochs | 5
Warmup teacher temperature epochs | 30
Max epochs | 80
Learning rate schedule | Cosine
Learning rate (start) | 0
Learning rate (post warmup) | 5e-4
Learning rate (final) | 2e-6
Teacher temperature (start) | 0.04
Teacher temperature (final) | 0.07
Teacher momentum (start) | 0.996
Teacher momentum (final) | 1
Weight decay (start) | 0.04
Weight decay (end) | 0.4
Automatic mixed precision | fp16



UNI CPATH Hyperparams:
Hyper-parameter | Value
Layers | 24
Heads | 16
Patch size | 16
FFN layer | MLP
Head activation | GELU
Embedding dimension | 1024
Stochastic dropout rate |  0.1
Global crop scale | 0.48, 1.0
Global crop number & size | 2, 224
Local crop scale | 0.16, 0.48
Local crop number & size | 8, 96
Max masking ratio | 0.5
Min masking ratio | 0.1
Gradient clipping max norm | 3
Normalize last layer | Yes
Shared head | No
AdamW | (0.9, 0.999)
Batch size | 3072
Freeze last layer iterations | 1250
Warmup iterations | 12500
Warmup teacher temperature iterations | 37500
High-resolution finetuning iterations | 12500
Max Iterations | 125000
Learning rate schedule | Cosine
Learning rate (start) | 0 
Learning rate (post warmup) | 2e-3
Learning rate (final) | 1e-6
Teacher temperature (start) | 0.04
Teacher temperature (final) | 0.4
Teacher momentum (start) | 0.992
Teacher momentum (final) | 1.000
Weight decay (start) | 0.04
Weight decay (end) | 0.4
Automatic mixed precision | FP16

Supplementary Data Table 5: DINOv2 hyperparameters used for ViT-L/16 pretraining
