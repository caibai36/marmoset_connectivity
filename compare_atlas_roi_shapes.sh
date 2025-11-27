#!/bin/bash

# ==========================================
# COMPARE ROI SHAPES BETWEEN PAXINOS AND RIKEN ATLASES
# ==========================================
# Check if same labels produce different spatial boundaries
# ==========================================

MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm"
OUTPUT_DIR="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/atlas_comparison"

mkdir -p $OUTPUT_DIR

echo "=========================================="
echo "ATLAS ROI SHAPE COMPARISON"
echo "=========================================="
echo ""

# Test regions: key vocalization areas
declare -A PAXINOS_LABELS
PAXINOS_LABELS[A4ab_M1]=37
PAXINOS_LABELS[A45_vlPFC]=31
PAXINOS_LABELS[AuA1_primary_auditory]=54
PAXINOS_LABELS[AI_anterior_insula]=50
PAXINOS_LABELS[A24a_ACC]=16

declare -A RIKEN_LABELS
RIKEN_LABELS[A4ab_M1]=31
RIKEN_LABELS[A45_vlPFC]=70
RIKEN_LABELS[AuA1_primary_auditory]=81
RIKEN_LABELS[AI_anterior_insula]=26
RIKEN_LABELS[A24a_ACC]=57

echo "Comparing key vocalization regions..."
echo ""

for region in A4ab_M1 A45_vlPFC AuA1_primary_auditory AI_anterior_insula A24a_ACC; do
    echo "Region: $region"
    echo "  Paxinos label: ${PAXINOS_LABELS[$region]}"
    echo "  RIKEN label: ${RIKEN_LABELS[$region]}"

    # Extract from Paxinos
    3dcalc -a $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
           -expr "equals(a,${PAXINOS_LABELS[$region]})" \
           -prefix $OUTPUT_DIR/${region}_paxinos.nii.gz 2>/dev/null

    # Extract from RIKEN
    3dcalc -a $MBM_DIR/atlas_RikenBMA_cortex_0.5mm.nii.gz \
           -expr "equals(a,${RIKEN_LABELS[$region]})" \
           -prefix $OUTPUT_DIR/${region}_riken.nii.gz 2>/dev/null

    # Get volumes
    pax_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_paxinos.nii.gz 2>/dev/null)
    rik_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_riken.nii.gz 2>/dev/null)

    pax_volume=$(echo "$pax_voxels * 0.125" | bc -l)  # 0.5mm^3 = 0.125 mm³
    rik_volume=$(echo "$rik_voxels * 0.125" | bc -l)

    echo "  Paxinos volume: ${pax_volume} mm³ (${pax_voxels} voxels)"
    echo "  RIKEN volume:   ${rik_volume} mm³ (${rik_voxels} voxels)"

    # Calculate overlap (Dice coefficient)
    3dcalc -a $OUTPUT_DIR/${region}_paxinos.nii.gz \
           -b $OUTPUT_DIR/${region}_riken.nii.gz \
           -expr 'step(a)*step(b)' \
           -prefix $OUTPUT_DIR/${region}_overlap.nii.gz 2>/dev/null

    3dcalc -a $OUTPUT_DIR/${region}_paxinos.nii.gz \
           -b $OUTPUT_DIR/${region}_riken.nii.gz \
           -expr 'step(a)+step(b)' \
           -prefix $OUTPUT_DIR/${region}_union.nii.gz 2>/dev/null

    overlap_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_overlap.nii.gz 2>/dev/null)
    union_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_union.nii.gz 2>/dev/null)

    # Dice coefficient: 2*overlap / (vol1 + vol2)
    dice=$(echo "scale=3; 2 * $overlap_voxels / ($pax_voxels + $rik_voxels)" | bc -l)

    # Jaccard index: overlap / union
    jaccard=$(echo "scale=3; $overlap_voxels / $union_voxels" | bc -l)

    echo "  Overlap (Dice): ${dice} (1.0 = perfect match)"
    echo "  Overlap (Jaccard): ${jaccard}"

    # Visual comparison files
    3dcalc -a $OUTPUT_DIR/${region}_paxinos.nii.gz \
           -b $OUTPUT_DIR/${region}_riken.nii.gz \
           -expr 'step(a)*1 + step(b)*2 + step(a)*step(b)*3' \
           -prefix $OUTPUT_DIR/${region}_comparison.nii.gz 2>/dev/null
    # Value 1 = Paxinos only
    # Value 2 = RIKEN only
    # Value 3 = Both (overlap)

    echo ""
done

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo ""
echo "Overlap interpretation:"
echo "  Dice > 0.8  : Very similar boundaries"
echo "  Dice 0.6-0.8: Moderate agreement"
echo "  Dice < 0.6  : Substantially different"
echo ""
echo "Files created in: $OUTPUT_DIR"
echo ""
echo "Visualization files (*_comparison.nii.gz):"
echo "  Value 1 (red)   = Paxinos only (not in RIKEN)"
echo "  Value 2 (green) = RIKEN only (not in Paxinos)"
echo "  Value 3 (yellow)= Overlap (both atlases agree)"
echo ""
echo "To visualize in AFNI:"
echo "  afni &"
echo "  # Load template_T2w_brain_0.5mm.nii.gz as underlay"
echo "  # Load *_comparison.nii.gz as overlay"
echo "  # Red regions = Paxinos extends beyond RIKEN"
echo "  # Green regions = RIKEN extends beyond Paxinos"
echo "  # Yellow regions = Both atlases agree"
echo ""

# Create summary CSV
echo "region,atlas,voxels,volume_mm3,dice_overlap,jaccard_overlap" > $OUTPUT_DIR/atlas_comparison_summary.csv

for region in A4ab_M1 A45_vlPFC AuA1_primary_auditory AI_anterior_insula A24a_ACC; do
    pax_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_paxinos.nii.gz 2>/dev/null)
    rik_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_riken.nii.gz 2>/dev/null)
    pax_volume=$(echo "$pax_voxels * 0.125" | bc -l)
    rik_volume=$(echo "$rik_voxels * 0.125" | bc -l)

    overlap_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_overlap.nii.gz 2>/dev/null)
    union_voxels=$(3dBrickStat -count -non-zero $OUTPUT_DIR/${region}_union.nii.gz 2>/dev/null)

    dice=$(echo "scale=3; 2 * $overlap_voxels / ($pax_voxels + $rik_voxels)" | bc -l)
    jaccard=$(echo "scale=3; $overlap_voxels / $union_voxels" | bc -l)

    echo "$region,Paxinos,$pax_voxels,$pax_volume,$dice,$jaccard" >> $OUTPUT_DIR/atlas_comparison_summary.csv
    echo "$region,RIKEN,$rik_voxels,$rik_volume,$dice,$jaccard" >> $OUTPUT_DIR/atlas_comparison_summary.csv
done

echo "Summary saved to: $OUTPUT_DIR/atlas_comparison_summary.csv"
echo ""
echo "Next steps:"
echo "  1. Check Dice coefficients in summary CSV"
echo "  2. Visualize *_comparison.nii.gz files in AFNI"
echo "  3. If Dice < 0.8, boundaries differ substantially"
echo "  4. Consider which atlas to use based on your needs"
echo ""
