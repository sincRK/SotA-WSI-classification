#!/bin/bash

cd $TMPDIR

# clone TRIDENT
git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git

# clone patho_bench
git clone -b dev --single-branch https://github.com/sincRK/Patho-Bench.git

cp -r ${HOME}/SotA-WSI-classification/slurm/feature_extraction $TMPDIR

cp -r ${HOME}/SotA-WSI-classification/slurm/eval_skeleton $TMPDIR

cp -r ${BENCH}/hf_models_bench $TMPDIR

MODEL_DIR="hf_models_bench"

# for patch_encoders
INPUT_JSON="${TMPDIR}/TRIDENT/trident/patch_encoder_models/local_ckpts.json"
cp ${TMPDIR}/feature_extraction/patch_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

# for segmentation_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/segmentation_models/local_ckpts.json"
cp ${TMPDIR}/feature_extraction/segmentation_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

# for slide_encoder_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/slide_encoder_models/local_ckpts.json"
cp ${TMPDIR}/feature_extraction/slide_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

mkdir --parents ${TMPDIR}/cobra_ood/20x_512px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/20x_512px_0px_overlap/slide_features_titan/* ${TMPDIR}/cobra_ood/20x_512px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/cobra_ood/20x_512px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/20x_512px_0px_overlap/slide_features_prism/* ${TMPDIR}/cobra_ood/20x_512px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/cobra_ood/20x_512px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/20x_512px_0px_overlap/slide_features_feather/* ${TMPDIR}/cobra_ood/20x_512px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/cobra_ood/20x_256px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/20x_256px_0px_overlap/slide_features_titan/* ${TMPDIR}/cobra_ood/20x_256px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/cobra_ood/20x_256px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/20x_256px_0px_overlap/slide_features_prism/* ${TMPDIR}/cobra_ood/20x_256px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/cobra_ood/20x_256px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/20x_256px_0px_overlap/slide_features_feather/* ${TMPDIR}/cobra_ood/20x_256px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/cobra_ood/10x_512px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/10x_512px_0px_overlap/slide_features_titan/* ${TMPDIR}/cobra_ood/10x_512px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/cobra_ood/10x_512px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/10x_512px_0px_overlap/slide_features_prism/* ${TMPDIR}/cobra_ood/10x_512px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/cobra_ood/10x_512px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/10x_512px_0px_overlap/slide_features_feather/* ${TMPDIR}/cobra_ood/10x_512px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/cobra_ood/10x_256px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/10x_256px_0px_overlap/slide_features_titan/* ${TMPDIR}/cobra_ood/10x_256px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/cobra_ood/10x_256px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/10x_256px_0px_overlap/slide_features_prism/* ${TMPDIR}/cobra_ood/10x_256px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/cobra_ood/10x_256px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/10x_256px_0px_overlap/slide_features_feather/* ${TMPDIR}/cobra_ood/10x_256px_0px_overlap/slide_features_feather
