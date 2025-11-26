#!/bin/bash

# ==========================================
# STAGE 1: MARMOSET AFFECTIVE VOCALIZATION NETWORK ROI EXTRACTION
# ==========================================
# Updated for actual data paths with 0.5mm downsampled templates
# Creates vocalization network ROIs for marmoset developmental analysis
# ==========================================

# Configuration
MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm"
OUTPUT_DIR="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/roi_masks"

mkdir -p $OUTPUT_DIR

echo "==========================================="
echo "MARMOSET VOCALIZATION NETWORK ROI CREATION"
echo "Atlas: MBM v3.0.1 (0.5mm isotropic)"
echo "==========================================="
echo ""

# ==========================================
# STEP 0: Verify atlas files exist
# ==========================================

echo "Step 0: Verifying atlas files..."
echo ""

if [ ! -f "$MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz" ]; then
    echo "ERROR: Cortical atlas not found!"
    echo "Expected: $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz"
    exit 1
fi

if [ ! -f "$MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz" ]; then
    echo "ERROR: Subcortical atlas not found!"
    echo "Expected: $MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz"
    exit 1
fi

echo "✓ Atlas files verified"
echo ""

# ==========================================
# STEP 1: Examine available atlases
# ==========================================

echo "Step 1: Examining MBM atlases..."
echo ""

# Check what atlases are available
echo "Available atlases:"
ls -lh $MBM_DIR/atlas*.nii.gz

echo ""
echo "Cortical atlas dimensions:"
3dinfo -n4 $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz

echo ""
echo "Subcortical atlas dimensions:"
3dinfo -n4 $MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz

echo ""

# ==========================================
# STEP 2: Get unique labels from atlases
# ==========================================

echo "Step 2: Extracting unique labels from atlases..."
echo ""

echo "Cortical atlas labels:"
3dBrickStat -max $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz | \
    xargs echo "  Maximum label value:"

echo ""
echo "Subcortical atlas labels:"
3dBrickStat -max $MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz | \
    xargs echo "  Maximum label value:"

echo ""

# Print histogram to see label distribution
echo "Cortical label histogram (unique values):"
3dBrickStat -non-zero $MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz 2>&1 | head -20

echo ""

# ==========================================
# MARMOSET-HUMAN HOMOLOGY MAPPING
# ==========================================

cat > $OUTPUT_DIR/marmoset_vocalization_homology.txt << 'EOFHOM'
====================================================================================
MARMOSET-HUMAN VOCALIZATION NETWORK HOMOLOGY
====================================================================================
Updated: 2025-11-26
Atlas: MBM v3.0.1 Paxinos + Subcortical (0.5mm isotropic)
====================================================================================

CRITICAL NOTES FOR MARMOSET VOCALIZATION:
- Marmosets are VOCAL LEARNERS (unlike macaques)
- Produce rich repertoire: phee, tsik, trillphee, twitter, trill calls
- Antiphonal calling (turn-taking vocal exchanges)
- Parental vocal feedback shapes infant calls (similar to human babbling)

====================================================================================
1. VOCAL MOTOR SYSTEM (CORTICAL)
====================================================================================
Marmoset Region                    Human Homolog              Function
---------------------------------------------------------------------------
Area 6 (Premotor/SMA)       →     BA 6 (SMA, premotor)      Vocalization initiation
Area 4 (Primary Motor)      →     BA 4 (M1)                 Laryngeal control
Ventrolateral PFC (Area 45) →     BA 44/45 (Broca's)        Motor speech planning*

*Note: Marmosets lack direct laryngeal motor cortex control like humans,
but have vocal motor areas in ventral premotor cortex.

MBM Atlas Regions to Extract (Paxinos parcellation):
- Motor cortex (look for motor/precentral labels in atlas)
- Premotor cortex (area 6 labels)
- Frontal regions related to vocalization

====================================================================================
2. LIMBIC VOCALIZATION SYSTEM
====================================================================================
Marmoset Region                    Human Homolog              Function
---------------------------------------------------------------------------
Anterior Cingulate Cortex   →     ACC                       Call initiation drive
Periaqueductal Gray (PAG)   →     PAG                       Innate vocalization
Amygdala                    →     Amygdala                  Emotional valence
Nucleus Accumbens           →     Accumbens                 Social motivation
Thalamus (MD, VA)           →     Thalamus                  Cortical relay

CRITICAL: PAG is essential for spontaneous emotional calls in all mammals
ACC provides voluntary control over vocalization timing

MBM Atlas Regions to Extract:
- Subcortical: Amygdala, Thalamus, Accumbens (from subcortical atlas)
- Cortical: Cingulate cortex (from Paxinos atlas)

====================================================================================
3. AUDITORY-VOCAL INTEGRATION
====================================================================================
Marmoset Region                    Human Homolog              Function
---------------------------------------------------------------------------
Core Auditory Cortex (A1)   →     Heschl's gyrus (A1)       Auditory processing
Rostral areas (R, RT)       →     Planum temporale          Conspecific calls
Caudal areas (CM, CL)       →     STS                       Voice perception
Frontal auditory field      →     Ventral premotor          Auditory-motor link

UNIQUE TO MARMOSETS:
- Auditory cortex shows call-selective responses
- Rapid auditory feedback integration (critical for turn-taking)
- Specialized neurons for phee calls and twitter calls

MBM Atlas Regions to Extract:
- Temporal cortex (auditory areas in Paxinos atlas)
- Superior temporal regions

====================================================================================
4. BASAL GANGLIA VOCAL CONTROL
====================================================================================
Marmoset Region                    Human Homolog              Function
---------------------------------------------------------------------------
Caudate                     →     Caudate                   Call sequencing
Putamen                     →     Putamen                   Motor execution
Pallidum                    →     Pallidum                  Timing, gating

ROLE IN VOCAL LEARNING:
- Basal ganglia essential for antiphonal calling development
- Striatal activity during vocal turn-taking
- Important for call timing and sequencing

MBM Atlas Regions to Extract:
- Subcortical atlas: Caudate, Putamen, Pallidum labels

====================================================================================
KEY DEVELOPMENTAL TIMELINE (for your age range: 14-115 months)
====================================================================================

INFANT PHASE (0-6 months = 0-0.5 years):
- Birth-2 months: Cry calls, isolation peeps
- 2-4 months: Emerging phee calls, parental feedback critical
- 4-6 months: Antiphonal calling begins

JUVENILE PHASE (6-18 months = 0.5-1.5 years):
- 6-12 months: Phee call maturation, twitter development
- Adult-like call repertoire emerges
- Auditory-motor integration strengthens

ADULT PHASE (>18 months = >1.5 years):
- Mature call repertoire
- Stable connectivity patterns
- Social context modulation

YOUR DATASET AGE RANGE:
- 14 months = EARLY JUVENILE (just past infancy) → youngest subject
- 24-36 months = YOUNG ADULT
- 40-80 months = MATURE ADULT
- >90 months = OLDER ADULT

====================================================================================
NEXT STEPS:
====================================================================================

1. CHECK LABEL FILES:
   Look at the text label files in MBM_v3.0.1/ directory:
   - atlas_MBM_cortex_vPaxinos.txt (cortical region labels)
   - atlas_MBM_subcortical_beta may have label info

2. IDENTIFY SPECIFIC LABELS:
   Open these text files and find label numbers for:
   - Motor/premotor cortex
   - Frontal areas
   - Cingulate cortex
   - Temporal/auditory cortex
   - Amygdala, Thalamus, Striatum (caudate/putamen), Pallidum

3. EDIT STAGE1b SCRIPT:
   Replace XXX placeholders with actual label numbers

4. CREATE ROI MASKS:
   Run STAGE1b_extract_vocalization_ROIs.sh

====================================================================================
EOFHOM

echo "[OK] Homology reference created: $OUTPUT_DIR/marmoset_vocalization_homology.txt"
echo ""

# ==========================================
# STEP 3: Display label reference files
# ==========================================

echo "Step 3: Checking for label reference files..."
echo ""

LABEL_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1"

if [ -f "$LABEL_DIR/atlas_MBM_cortex_vPaxinos.txt" ]; then
    echo "=== Paxinos Cortical Labels ==="
    head -50 "$LABEL_DIR/atlas_MBM_cortex_vPaxinos.txt"
    echo ""
    echo "(Showing first 50 lines. See full file at: $LABEL_DIR/atlas_MBM_cortex_vPaxinos.txt)"
else
    echo "⚠ Label file not found: atlas_MBM_cortex_vPaxinos.txt"
    echo "You may need to manually inspect the atlas to identify labels"
fi

echo ""

# ==========================================
# STEP 4: Create template ROI extraction script
# ==========================================

cat > $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh << 'EOFROI'
#!/bin/bash

# ==========================================
# STAGE 1b: EXTRACT MARMOSET VOCALIZATION ROIs
# ==========================================
# CUSTOMIZE THIS SCRIPT with actual label numbers from MBM atlas
# ==========================================

MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm"
OUTPUT_DIR="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/roi_masks"

CORTICAL_ATLAS="$MBM_DIR/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz"
SUBCORTICAL_ATLAS="$MBM_DIR/atlas_MBM_subcortical_beta_0.5mm.nii.gz"
TEMPLATE_BRAIN="$MBM_DIR/template_T2w_brain_0.5mm.nii.gz"

echo "==========================================="
echo "EXTRACTING MARMOSET VOCALIZATION ROIs"
echo "==========================================="
echo ""

# ==========================================
# IMPORTANT: UPDATE LABEL NUMBERS
# ==========================================
# You MUST inspect atlas_MBM_cortex_vPaxinos.txt to get actual labels
# Example shown below - REPLACE XXX with real numbers!

# ==========================================
# 1. VOCAL MOTOR CORTEX
# ==========================================
echo "Creating vocal motor cortex ROIs..."

# TODO: Replace XXX with actual label numbers from Paxinos atlas
# Look for: motor cortex, premotor, precentral, area 4, area 6
# Example labels (VERIFY THESE):
# Left motor: label X
# Right motor: label Y
# Premotor: label Z

echo "  [ACTION REQUIRED] Update motor cortex labels in this script"
echo "  Look in atlas_MBM_cortex_vPaxinos.txt for motor/premotor regions"
echo ""

# Uncomment and update after finding labels:
# 3dcalc -a $CORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_motor_cortex.nii.gz

# ==========================================
# 2. PREFRONTAL CORTEX (Area 45, ventral PFC)
# ==========================================
echo "Creating prefrontal cortex ROIs..."

echo "  [ACTION REQUIRED] Update prefrontal labels"
echo "  Look for: prefrontal, frontal, area 45"
echo ""

# Uncomment after finding labels:
# 3dcalc -a $CORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_prefrontal.nii.gz

# ==========================================
# 3. AUDITORY CORTEX
# ==========================================
echo "Creating auditory cortex ROIs..."

echo "  [ACTION REQUIRED] Update auditory labels"
echo "  Look for: auditory, temporal, superior temporal"
echo ""

# Uncomment after finding labels:
# 3dcalc -a $CORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_auditory.nii.gz

# ==========================================
# 4. CINGULATE CORTEX
# ==========================================
echo "Creating cingulate cortex ROIs..."

echo "  [ACTION REQUIRED] Update cingulate labels"
echo "  Look for: cingulate, anterior cingulate"
echo ""

# Uncomment after finding labels:
# 3dcalc -a $CORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_cingulate.nii.gz

# ==========================================
# 5. SUBCORTICAL STRUCTURES
# ==========================================
echo "Creating subcortical ROIs..."

echo "  [ACTION REQUIRED] Update subcortical labels"
echo "  Check atlas_MBM_subcortical_beta for label numbers"
echo ""

# Uncomment after finding labels:
# Amygdala
# 3dcalc -a $SUBCORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_amygdala.nii.gz

# Thalamus
# 3dcalc -a $SUBCORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_thalamus.nii.gz

# Caudate
# 3dcalc -a $SUBCORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_caudate.nii.gz

# Putamen
# 3dcalc -a $SUBCORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_putamen.nii.gz

# Pallidum
# 3dcalc -a $SUBCORTICAL_ATLAS \
#        -expr 'amongst(a,XXX,XXX)' \
#        -prefix $OUTPUT_DIR/bilateral_pallidum.nii.gz

# ==========================================
# 6. COMBINED VOCALIZATION NETWORK
# ==========================================
echo ""
echo "After creating individual ROIs, run this to combine:"
echo ""
echo "  3dcalc -a bilateral_motor_cortex.nii.gz \\"
echo "         -b bilateral_prefrontal.nii.gz \\"
echo "         -c bilateral_auditory.nii.gz \\"
echo "         -d bilateral_cingulate.nii.gz \\"
echo "         -e bilateral_amygdala.nii.gz \\"
echo "         -f bilateral_thalamus.nii.gz \\"
echo "         -g bilateral_caudate.nii.gz \\"
echo "         -h bilateral_putamen.nii.gz \\"
echo "         -i bilateral_pallidum.nii.gz \\"
echo "         -expr 'step(a+b+c+d+e+f+g+h+i)' \\"
echo "         -prefix complete_vocalization_network.nii.gz"
echo ""

echo "==========================================="
echo "STAGE 1b TEMPLATE COMPLETE"
echo "==========================================="
echo ""
echo "TO COMPLETE ROI EXTRACTION:"
echo "1. Examine label files in MBM_v3.0.1/"
echo "2. Update XXX placeholders with actual labels"
echo "3. Uncomment the 3dcalc commands"
echo "4. Run this script again"
echo ""
EOFROI

chmod +x $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh

echo ""
echo "==========================================="
echo "STAGE 1 PREPARATION COMPLETE"
echo "==========================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Read homology guide: $OUTPUT_DIR/marmoset_vocalization_homology.txt"
echo "  2. Examine atlas labels in MBM_v3.0.1/"
echo "  3. Edit: $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh"
echo "  4. Replace XXX with actual label numbers"
echo "  5. Run: bash $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh"
echo ""
