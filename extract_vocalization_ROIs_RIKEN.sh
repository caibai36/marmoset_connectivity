#!/bin/bash

# ==========================================
# MARMOSET AFFECTIVE VOCALIZATION ROI EXTRACTION
# RIKEN BMA VERSION
# ==========================================
# Using RIKEN Brain and Mind Atlas (RikenBMA_cortex)
# For compatibility with other research groups using Riken atlas
# ==========================================

# Paths
MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm"
OUTPUT_DIR="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/roi_masks_riken"

mkdir -p $OUTPUT_DIR

echo "=========================================="
echo "AFFECTIVE VOCALIZATION ROI EXTRACTION"
echo "Using RIKEN Brain and Mind Atlas"
echo "=========================================="
echo ""

# Check atlas files exist
if [ ! -f "$MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz" ]; then
    echo "ERROR: RIKEN cortical atlas not found!"
    exit 1
fi

if [ ! -f "$MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz" ]; then
    echo "ERROR: Subcortical atlas not found!"
    exit 1
fi

echo "✓ Atlas files verified"
echo ""

# ==========================================
# NETWORK 1: VOCAL MOTOR CORTEX
# ==========================================
echo "Creating Vocal Motor Cortex ROIs..."
echo ""

# Primary Motor Cortex (M1 - face/larynx area)
# A4ab (31), A4c (32)
echo "  - Primary Motor (M1): A4ab + A4c"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,31)+equals(a,32)' \
       -prefix $OUTPUT_DIR/motor_primary_M1_bilateral.nii.gz

# Premotor and Supplementary Motor (Area 6)
# A6DC (33), A6DR (34), A6M (35), A6Va (36), A6Vb (37)
echo "  - Premotor/SMA (Area 6): A6DC + A6DR + A6M + A6Va + A6Vb"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,33)+equals(a,34)+equals(a,35)+equals(a,36)+equals(a,37)' \
       -prefix $OUTPUT_DIR/motor_premotor_area6_bilateral.nii.gz

# Ventrolateral Prefrontal (Area 45 - vocal planning)
# A45 (70)
echo "  - Ventrolateral PFC (A45): Vocal motor planning"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,70)' \
       -prefix $OUTPUT_DIR/motor_vlPFC_A45_bilateral.nii.gz

# ProM (118) - Premotor
echo "  - Premotor (ProM)"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,118)' \
       -prefix $OUTPUT_DIR/motor_ProM_bilateral.nii.gz

# Combined Motor Network
3dcalc -a $OUTPUT_DIR/motor_primary_M1_bilateral.nii.gz \
       -b $OUTPUT_DIR/motor_premotor_area6_bilateral.nii.gz \
       -c $OUTPUT_DIR/motor_vlPFC_A45_bilateral.nii.gz \
       -d $OUTPUT_DIR/motor_ProM_bilateral.nii.gz \
       -expr 'step(a+b+c+d)' \
       -prefix $OUTPUT_DIR/network_1_vocal_motor.nii.gz

echo "  ✓ Vocal Motor Network ROIs created"
echo ""

# ==========================================
# NETWORK 2: LIMBIC VOCALIZATION SYSTEM
# ==========================================
echo "Creating Limbic Vocalization ROIs..."
echo ""

# Anterior Cingulate Cortex (voluntary vocal control)
# A24a (57), A24b (58), A24c (59), A24d (60), A25 (61), A32 (66), A32V (67)
echo "  - Anterior Cingulate: A24a/b/c/d + A25 + A32/V"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,57)+equals(a,58)+equals(a,59)+equals(a,60)+equals(a,61)+equals(a,66)+equals(a,67)' \
       -prefix $OUTPUT_DIR/limbic_ACC_bilateral.nii.gz

# Insula (interoception, emotional expression)
# AI (26), DI (88), GI (92), ReI (121)
echo "  - Insula: AI + DI + GI + ReI"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,26)+equals(a,88)+equals(a,92)+equals(a,121)' \
       -prefix $OUTPUT_DIR/limbic_insula_bilateral.nii.gz

# Orbitofrontal Cortex (affective valence)
# A13L (47), A13M (48), A13a (45), A13b (46), A14C (49), A14R (50)
echo "  - Orbitofrontal: A13L/M/a/b + A14C/R"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,47)+equals(a,48)+equals(a,45)+equals(a,46)+equals(a,49)+equals(a,50)' \
       -prefix $OUTPUT_DIR/limbic_OFC_bilateral.nii.gz

# Gustatory cortex (Gu - 93) - related to oro-facial control
echo "  - Gustatory cortex (Gu): Oro-facial control"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,93)' \
       -prefix $OUTPUT_DIR/limbic_gustatory_bilateral.nii.gz

# Combined Limbic Network
3dcalc -a $OUTPUT_DIR/limbic_ACC_bilateral.nii.gz \
       -b $OUTPUT_DIR/limbic_insula_bilateral.nii.gz \
       -c $OUTPUT_DIR/limbic_OFC_bilateral.nii.gz \
       -d $OUTPUT_DIR/limbic_gustatory_bilateral.nii.gz \
       -expr 'step(a+b+c+d)' \
       -prefix $OUTPUT_DIR/network_2_limbic.nii.gz

echo "  ✓ Limbic Vocalization ROIs created"
echo ""

# ==========================================
# NETWORK 3: AUDITORY-VOCAL INTEGRATION
# ==========================================
echo "Creating Auditory-Vocal Integration ROIs..."
echo ""

# Primary Auditory Cortex (Core)
# AuA1 (81)
echo "  - Primary Auditory (A1): AuA1"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,81)' \
       -prefix $OUTPUT_DIR/auditory_core_A1_bilateral.nii.gz

# Auditory Belt (rostral regions - call-selective responses)
# AuR (82), AuRM (84), AuRT (87), AuRTL (85), AuRTM (86)
echo "  - Rostral Auditory Belt: AuR + AuRM + AuRT + AuRTL + AuRTM"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,82)+equals(a,84)+equals(a,87)+equals(a,85)+equals(a,86)' \
       -prefix $OUTPUT_DIR/auditory_belt_rostral_bilateral.nii.gz

# Auditory Belt (caudal/lateral regions)
# AuAL (76), AuCL (77), AuCM (78), AuML (80)
echo "  - Caudal/Lateral Auditory Belt: AuAL + AuCL + AuCM + AuML"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,76)+equals(a,77)+equals(a,78)+equals(a,80)' \
       -prefix $OUTPUT_DIR/auditory_belt_caudal_bilateral.nii.gz

# Auditory Parabelt
# AuCPB (79), AuRPB (83)
echo "  - Auditory Parabelt: AuCPB + AuRPB"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,79)+equals(a,83)' \
       -prefix $OUTPUT_DIR/auditory_parabelt_bilateral.nii.gz

# Superior Temporal Regions
# STR (126)
echo "  - Superior Temporal Rostral: STR"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,126)' \
       -prefix $OUTPUT_DIR/auditory_STR_bilateral.nii.gz

# Combined Auditory Network
3dcalc -a $OUTPUT_DIR/auditory_core_A1_bilateral.nii.gz \
       -b $OUTPUT_DIR/auditory_belt_rostral_bilateral.nii.gz \
       -c $OUTPUT_DIR/auditory_belt_caudal_bilateral.nii.gz \
       -d $OUTPUT_DIR/auditory_parabelt_bilateral.nii.gz \
       -e $OUTPUT_DIR/auditory_STR_bilateral.nii.gz \
       -expr 'step(a+b+c+d+e)' \
       -prefix $OUTPUT_DIR/network_3_auditory.nii.gz

echo "  ✓ Auditory-Vocal Integration ROIs created"
echo ""

# ==========================================
# NETWORK 4: TEMPORAL/ASSOCIATION CORTEX
# ==========================================
echo "Creating Temporal Association ROIs..."
echo ""

# Temporal Cortex (social/vocal processing)
# TE1 (128), TE2 (129), TE3 (130), TEO (131)
echo "  - Temporal Cortex: TE1 + TE2 + TE3 + TEO"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,128)+equals(a,129)+equals(a,130)+equals(a,131)' \
       -prefix $OUTPUT_DIR/temporal_cortex_bilateral.nii.gz

# Temporoparietal Junction (audiovisual integration)
# TPO (138), TPPro (139), TPt (140)
echo "  - Temporoparietal: TPO + TPPro + TPt"
3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,138)+equals(a,139)+equals(a,140)' \
       -prefix $OUTPUT_DIR/temporoparietal_bilateral.nii.gz

# Combined Temporal Network
3dcalc -a $OUTPUT_DIR/temporal_cortex_bilateral.nii.gz \
       -b $OUTPUT_DIR/temporoparietal_bilateral.nii.gz \
       -expr 'step(a+b)' \
       -prefix $OUTPUT_DIR/network_4_temporal.nii.gz

echo "  ✓ Temporal Association ROIs created"
echo ""

# ==========================================
# NETWORK 5: SUBCORTICAL STRUCTURES
# ==========================================
echo "Creating Subcortical ROIs..."
echo ""

# NOTE: Subcortical atlas labels need to be checked!
# Use 3dinfo -label to see actual labels

echo "  Checking subcortical atlas labels..."
3dinfo -label $MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz > $OUTPUT_DIR/subcortical_labels.txt

echo "  Please check: $OUTPUT_DIR/subcortical_labels.txt"
echo "  And manually update this script with correct label numbers for:"
echo "    - Amygdala (CRITICAL for affective vocalization!)"
echo "    - Caudate"
echo "    - Putamen"
echo "    - Pallidum (Globus pallidus)"
echo "    - Thalamus"
echo "    - Nucleus accumbens"
echo "    - PAG (if available in brainstem atlas)"
echo ""

# Placeholder - UPDATE THESE AFTER CHECKING LABELS!
# 3dcalc -a $MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz \
#        -expr 'equals(a,LABEL_NUM_FOR_AMYGDALA)' \
#        -prefix $OUTPUT_DIR/subcortical_amygdala_bilateral.nii.gz

echo "  ⚠ Subcortical ROIs require manual label identification"
echo ""

# ==========================================
# COMPLETE VOCALIZATION NETWORK
# ==========================================
echo "Creating Complete Affective Vocalization Network..."
echo ""

3dcalc -a $OUTPUT_DIR/network_1_vocal_motor.nii.gz \
       -b $OUTPUT_DIR/network_2_limbic.nii.gz \
       -c $OUTPUT_DIR/network_3_auditory.nii.gz \
       -d $OUTPUT_DIR/network_4_temporal.nii.gz \
       -expr 'step(a)+step(b)*2+step(c)*3+step(d)*4' \
       -prefix $OUTPUT_DIR/complete_vocalization_network_labeled.nii.gz

# Binary version
3dcalc -a $OUTPUT_DIR/network_1_vocal_motor.nii.gz \
       -b $OUTPUT_DIR/network_2_limbic.nii.gz \
       -c $OUTPUT_DIR/network_3_auditory.nii.gz \
       -d $OUTPUT_DIR/network_4_temporal.nii.gz \
       -expr 'step(a+b+c+d)' \
       -prefix $OUTPUT_DIR/complete_vocalization_network_binary.nii.gz

echo "  ✓ Complete network created"
echo ""

# ==========================================
# SUMMARY
# ==========================================
echo "=========================================="
echo "RIKEN BMA ROI EXTRACTION COMPLETE"
echo "=========================================="
echo ""
echo "Created ROI files in: $OUTPUT_DIR"
ls -lh $OUTPUT_DIR/*.nii.gz
echo ""
echo "Summary:"
echo "  Network 1 (Vocal Motor):    $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_1_vocal_motor.nii.gz) voxels"
echo "  Network 2 (Limbic):         $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_2_limbic.nii.gz) voxels"
echo "  Network 3 (Auditory):       $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_3_auditory.nii.gz) voxels"
echo "  Network 4 (Temporal):       $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_4_temporal.nii.gz) voxels"
echo ""
echo "Atlas used: RIKEN Brain and Mind Atlas (RikenBMA_cortex)"
echo ""
echo "Next steps:"
echo "  1. Check subcortical labels: cat $OUTPUT_DIR/subcortical_labels.txt"
echo "  2. Update this script with correct subcortical label numbers"
echo "  3. Re-run to add subcortical structures to Network 5"
echo "  4. Compare with Paxinos version if desired:"
echo "     bash extract_vocalization_ROIs_actual_labels.sh  # Paxinos version"
echo "  5. Use these ROIs for connectivity or anatomical analysis"
echo ""
