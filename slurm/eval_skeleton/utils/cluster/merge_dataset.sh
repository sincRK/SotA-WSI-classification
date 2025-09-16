#!/bin/bash

cd $TMPDIR
D1=$1

mkdir --parents ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/20x_512px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/20x_512px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/20x_512px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/20x_256px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/20x_256px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/20x_256px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/10x_512px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/10x_512px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/10x_512px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/cobra_features/10x_256px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/cobra_features/10x_256px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/cobra_features/10x_256px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_feather

mkdir --parents ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/pp_features/20x_512px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/pp_features/20x_512px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/pp_features/20x_512px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/20x_512px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/pp_features/20x_256px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/pp_features/20x_256px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/pp_features/20x_256px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/20x_256px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/pp_features/10x_512px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/pp_features/10x_512px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/pp_features/10x_512px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/10x_512px_0px_overlap/slide_features_feather
mkdir --parents ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_titan
ln -s ${TMPDIR}/pp_features/10x_256px_0px_overlap/slide_features_titan/* ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_titan
mkdir --parents ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_prism
ln -s ${TMPDIR}/pp_features/10x_256px_0px_overlap/slide_features_prism/* ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_prism
mkdir --parents ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_feather
ln -s ${TMPDIR}/pp_features/10x_256px_0px_overlap/slide_features_feather/* ${TMPDIR}/${D1}/10x_256px_0px_overlap/slide_features_feather
