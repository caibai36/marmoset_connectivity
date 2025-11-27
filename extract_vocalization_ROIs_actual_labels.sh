#!/bin/bash

# ==========================================
# MARMOSET AFFECTIVE VOCALIZATION ROI EXTRACTION
# ==========================================
# Using ACTUAL MBM v3.0.1 Paxinos atlas labels
# For developmental study of affective vocalization networks
# ==========================================

# Paths
MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm"
OUTPUT_DIR="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/roi_masks"

mkdir -p $OUTPUT_DIR

echo "=========================================="
echo "AFFECTIVE VOCALIZATION ROI EXTRACTION"
echo "Using MBM v3.0.1 Paxinos Atlas"
echo "=========================================="
echo ""

# Check atlas files exist
if [ ! -f "$MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz" ]; then
    echo "ERROR: Cortical atlas not found!"
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
# A4ab (37), A4c (38)
echo "  - Primary Motor (M1): A4ab + A4c"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,37)+equals(a,38)' \
       -prefix $OUTPUT_DIR/motor_primary_M1_bilateral.nii.gz

# Premotor and Supplementary Motor (Area 6)
# A6DC (39), A6DR (40), A6M (41), A6Va (42), A6Vb (43)
echo "  - Premotor/SMA (Area 6): A6DC + A6DR + A6M + A6Va + A6Vb"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,39)+equals(a,40)+equals(a,41)+equals(a,42)+equals(a,43)' \
       -prefix $OUTPUT_DIR/motor_premotor_area6_bilateral.nii.gz

# Ventrolateral Prefrontal (Area 45 - vocal planning)
# A45 (31)
echo "  - Ventrolateral PFC (A45): Vocal motor planning"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,31)' \
       -prefix $OUTPUT_DIR/motor_vlPFC_A45_bilateral.nii.gz

# ProM (103) - Premotor
echo "  - Premotor (ProM)"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,103)' \
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
# A24a (16), A24b (17), A24c (18), A24d (19), A25 (20), A32 (25), A32V (26)
echo "  - Anterior Cingulate: A24a/b/c/d + A25 + A32/V"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,16)+equals(a,17)+equals(a,18)+equals(a,19)+equals(a,20)+equals(a,25)+equals(a,26)' \
       -prefix $OUTPUT_DIR/limbic_ACC_bilateral.nii.gz

# Insula (interoception, emotional expression)
# AI (50), DI (67), GI (72), ReI (105)
echo "  - Insula: AI + DI + GI + ReI"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,50)+equals(a,67)+equals(a,72)+equals(a,105)' \
       -prefix $OUTPUT_DIR/limbic_insula_bilateral.nii.gz

# Orbitofrontal Cortex (affective valence)
# A13L (4), A13M (5), A13a (6), A13b (7), A14C (8), A14R (9)
echo "  - Orbitofrontal: A13L/M/a/b + A14C/R"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,4)+equals(a,5)+equals(a,6)+equals(a,7)+equals(a,8)+equals(a,9)' \
       -prefix $OUTPUT_DIR/limbic_OFC_bilateral.nii.gz

# Gustatory cortex (Gu - 73) - related to oro-facial control
echo "  - Gustatory cortex (Gu): Oro-facial control"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,73)' \
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
# AuA1 (54)
echo "  - Primary Auditory (A1): AuA1"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,54)' \
       -prefix $OUTPUT_DIR/auditory_core_A1_bilateral.nii.gz

# Auditory Belt (rostral regions - call-selective responses)
# AuR (60), AuRM (61), AuRT (63), AuRTL (64), AuRTM (65)
echo "  - Rostral Auditory Belt: AuR + AuRM + AuRT + AuRTL + AuRTM"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,60)+equals(a,61)+equals(a,63)+equals(a,64)+equals(a,65)' \
       -prefix $OUTPUT_DIR/auditory_belt_rostral_bilateral.nii.gz

# Auditory Belt (caudal/lateral regions)
# AuAL (55), AuCL (56), AuCM (57), AuML (59)
echo "  - Caudal/Lateral Auditory Belt: AuAL + AuCL + AuCM + AuML"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,55)+equals(a,56)+equals(a,57)+equals(a,59)' \
       -prefix $OUTPUT_DIR/auditory_belt_caudal_bilateral.nii.gz

# Auditory Parabelt
# AuCPB (58), AuRPB (62)
echo "  - Auditory Parabelt: AuCPB + AuRPB"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,58)+equals(a,62)' \
       -prefix $OUTPUT_DIR/auditory_parabelt_bilateral.nii.gz

# Superior Temporal Regions
# STR (111)
echo "  - Superior Temporal Rostral: STR"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,111)' \
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
# TE1 (112), TE2 (113), TE3 (114), TEO (115)
echo "  - Temporal Cortex: TE1 + TE2 + TE3 + TEO"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,112)+equals(a,113)+equals(a,114)+equals(a,115)' \
       -prefix $OUTPUT_DIR/temporal_cortex_bilateral.nii.gz

# Temporoparietal Junction (audiovisual integration)
# TPO (121), TPPro (122), TPt (124)
echo "  - Temporoparietal: TPO + TPPro + TPt"
3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,121)+equals(a,122)+equals(a,124)' \
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
echo "ROI EXTRACTION COMPLETE"
echo "=========================================="
echo ""
echo "Created ROI files:"
ls -lh $OUTPUT_DIR/*.nii.gz
echo ""
echo "Summary:"
echo "  Network 1 (Vocal Motor):    $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_1_vocal_motor.nii.gz) voxels"
echo "  Network 2 (Limbic):         $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_2_limbic.nii.gz) voxels"
echo "  Network 3 (Auditory):       $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_3_auditory.nii.gz) voxels"
echo "  Network 4 (Temporal):       $(3dBrickStat -count -non-zero $OUTPUT_DIR/network_4_temporal.nii.gz) voxels"
echo ""
echo "Next steps:"
echo "  1. Check subcortical labels: cat $OUTPUT_DIR/subcortical_labels.txt"
echo "  2. Update this script with correct subcortical label numbers"
echo "  3. Re-run to add subcortical structures to Network 5"
echo "  4. Use these ROIs to extract time series from registered BOLD data"
echo ""
echo "For anatomical development analysis:"
echo "  - Use these ROI masks to extract volumes from T2 scans"
echo "  - Register each subject's T2 to MBM template"
echo "  - Apply ROI masks to calculate region volumes"
echo "  - Plot volume vs age for developmental trajectories"
echo ""
echo "For functional connectivity analysis:"
echo "  - Extract mean time series from each ROI"
echo "  - Compute ROI-to-ROI correlations"
echo "  - Analyze connectivity changes with age"
echo ""
