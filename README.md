# SotA-WSI-classification


# Implementation
FNET: https://arxiv.org/abs/2105.03824<br>
NoProp Diffusion: https://arxiv.org/abs/2503.24322<br>
U-KAN: https://github.com/CUHK-AIM-Group/U-KAN<br>
Vision-KAN: https://github.com/chenziwenhaoshuai/Vision-KAN<br>
Densenet Mosaic: https://arxiv.org/abs/2101.07903<br>




# Theory
Sheaf GNN: https://arxiv.org/abs/2502.15476<br>
KANs: https://arxiv.org/html/2406.09087v1<br>
Beispiel Benchmark-Paper: https://arxiv.org/html/2506.21444v1#S3<br>
Effektivität von Embeddings: https://arxiv.org/html/2410.06723v1<br>
Effektivität von Transferlearning: https://arxiv.org/pdf/2506.09022<br>




# Useful libraries/projects
TRIDENT (WSI processing and feature extraction): https://github.com/mahmoodlab/TRIDENT<br>
Patho-Bench (Benchmarking library for WSI): https://github.com/mahmoodlab/Patho-Bench<br>
MIL-lab (MIL loading und Konkurenz): https://github.com/mahmoodlab/MIL-Lab<br>
SSL_tile_benchmarks (Benchmark for Detection and Biomarker): https://github.com/sinai-computational-pathology/SSL_tile_benchmarks<br>
BenchmarkingPathologyFoundationModels https://github.com/QuIIL/BenchmarkingPathologyFoundationModels<br>


# Published benchmarks:
Benchmarking foundation models as feature extractors for weakly-supervised computational pathology https://arxiv.org/pdf/2408.15823<br>
In this study, we benchmarked 19 histopathology foundation models on 13 patient cohorts with 6,818
patients and 9,528 slides from lung, colorectal, gastric, and breast cancers. The models were
evaluated on weakly-supervised tasks related to biomarkers, morphological properties, and
prognostic outcomes.<br>
A clinical benchmark of public self-supervised pathology foundation models https://www.nature.com/articles/s41467-025-58796-1<br>
In this work, we present a collection of pathology datasets comprising clinical slides associated with clinically relevant endpoints including cancer diagnoses and a variety of biomarkers generated during standard hospital operation from three medical centers.<br>
Evaluating Vision and Pathology Foundation Models for Computational Pathology: A Comprehensive Benchmark Study https://www.medrxiv.org/content/10.1101/2025.05.08.25327250v1<br>
In this study, we conduct a comprehensive benchmarking of 31 AI foundation models for computational pathology, including general vision models (VM), general vision-language models (VLM), pathology-specific vision models (Path-VM), and pathology-specific vision-language models (Path-VLM), evaluated over 41 tasks sourced from TCGA, CPTAC, external benchmarking datasets, and out-of-domain datasets.<br>
https://pathbench.stanford.edu/<br>
Benchmarking weakly-supervised deep learning pipelines for whole slide classification in computational pathology  https://www.sciencedirect.com/science/article/pii/S1361841522001219<br>
We implemented and systematically compared six methods in six clinically relevant end-to-end prediction tasks using data from N=2980 patients for training with rigorous external validation. We tested three classical weakly-supervised approaches with convolutional neural networks and vision transformers (ViT) and three MIL-based approaches with and without an additional attention module. Our results empirically demonstrate that histological tumor subtyping of renal cell carcinoma is an easy task in which all approaches achieve an area under the receiver operating curve (AUROC) of above 0.9. In contrast, we report significant performance differences for clinically relevant tasks of mutation prediction in colorectal, gastric, and bladder cancer.<br>
Benchmarking Pathology Foundation Models: Adaptation Strategies and Scenarios https://arxiv.org/abs/2410.16038v1<br>
In this study, we benchmark four pathology-specific foundation models across 14 datasets and two scenarios-consistency assessment and flexibility assessment-addressing diverse adaptation scenarios and downstream tasks. In the consistency assessment scenario, involving five fine-tuning methods, we found that the parameter-efficient fine-tuning approach was both efficient and effective for adapting pathology-specific foundation models to diverse datasets within the same downstream task. In the flexibility assessment scenario under data-limited environments, utilizing five few-shot learning methods, we observed that the foundation models benefited more from the few-shot learning methods that involve modification during the testing phase only.<br>
Benchmarking Self-Supervised Learning on Diverse Pathology Datasets https://arxiv.org/pdf/2212.04690<br>
To address this need, we execute the largest-scale study of SSL pre-training on pathology image data, to date. Our study is conducted using 4 representative SSL methods on diverse downstream tasks. We establish that large-scale domain-aligned pre-training in pathology consistently out-performs ImageNet pre-training in standard SSL settings such as linear and fine-tuning evaluations, as well as in low-label regimes. Moreover, we propose a set of domain-specific techniques that we experimentally show leads to a performance boost.<br>
Benchmarking Embedding Aggregation Methods in Computational Pathology: A Clinical Data Perspective https://proceedings.mlr.press/v254/chen24a.html<br>
This study conducts a thorough benchmarking analysis of ten slide-level aggregation techniques across nine clinically relevant tasks, including diagnostic assessment, biomarker classification, and outcome prediction. The results yield following key insights: (1) Embeddings derived from domainspecific (histological images) FMs outperform those from generic ImageNet-based models across aggregation methods. (2) Spatial-aware aggregators enhance the performance significantly when using ImageNet pre-trained models but not when using FMs. (3) No single model excels in all tasks and spatially-aware models do not show general superiority as it would be expected.<br>

# Meta-Reviews:
Deep learning in computational dermatopathology of melanoma: A technical systematic literature review https://www.sciencedirect.com/science/article/pii/S0010482523005486<br>
We aim to provide a structured and comprehensive overview of peer-reviewed publications on DL applied to dermatopathology focused on melanoma.<br>
