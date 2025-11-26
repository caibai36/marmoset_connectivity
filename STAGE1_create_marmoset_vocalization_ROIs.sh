#!/bin/bash

# ==========================================
# STAGE 1: MARMOSET AFFECTIVE VOCALIZATION NETWORK ROI EXTRACTION
# ==========================================
# Creates vocalization network ROIs for marmoset developmental analysis
# Based on marmoset neuroanatomy and human vocalization homologies
# ==========================================

# Configuration
MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1"
OUTPUT_DIR="./marmoset_vocalization_ROIs"

mkdir -p $OUTPUT_DIR

echo "==========================================="
echo "MARMOSET VOCALIZATION NETWORK ROI CREATION"
echo "Atlas: MBM v3.0.1"
echo "==========================================="
echo ""

# ==========================================
# MARMOSET-HUMAN HOMOLOGY MAPPING
# ==========================================
# Based on:
# - Petkov & Jarvis (2012) Nat Rev Neurosci
# - Eliades & Wang (2008) Nature
# - Miller et al. (2015) Current Biology
# - Takahashi et al. (2017) eLife
# ==========================================

cat > $OUTPUT_DIR/marmoset_vocalization_homology.txt << 'EOFHOM'
====================================================================================
MARMOSET-HUMAN VOCALIZATION NETWORK HOMOLOGY
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

MBM Atlas Regions to Extract:
- Frontal cortex areas (from atlas_MBM_cortex_vPaxinos.nii.gz)
- Look for: Area 4, Area 6, Area 45 labels

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
- Subcortical structures (from atlas_MBM_subcortical_beta.nii.gz)
- Cingulate cortex (from cortical atlas)
- Amygdala, Thalamus, Accumbens

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
- Temporal cortex (auditory areas)
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
- 14 months = EARLY JUVENILE (just past infancy)
- 24-36 months = YOUNG ADULT
- 40-80 months = MATURE ADULT
- >90 months = OLDER ADULT

====================================================================================
EOFHOM

echo "[OK] Homology reference created"
echo ""

# ==========================================
# STEP 1: Examine available atlases
# ==========================================

echo "Step 1: Examining MBM atlases..."

if [ ! -f "$MBM_DIR/atlas_MBM_cortex_vPaxinos.nii.gz" ]; then
    echo "ERROR: MBM atlas not found at $MBM_DIR"
    echo "Please update MBM_DIR path in this script"
    exit 1
fi

# Check what labels are available
echo ""
echo "Available cortical atlases:"
ls -lh $MBM_DIR/atlas_MBM_cortex*.nii.gz
echo ""
echo "Available subcortical atlas:"
ls -lh $MBM_DIR/atlas_MBM_subcortical*.nii.gz
echo ""

# Print label files
echo "Checking label definitions..."
for labelfile in $MBM_DIR/atlas_*.txt; do
    if [ -f "$labelfile" ]; then
        echo ""
        echo "=== $(basename $labelfile) ==="
        head -20 "$labelfile"
    fi
done

echo ""
echo "[MANUAL STEP REQUIRED]"
echo "Please examine the atlas label files above and identify:"
echo "  1. Motor/premotor cortex labels (Area 4, Area 6)"
echo "  2. Prefrontal cortex labels (Area 45, frontal areas)"
echo "  3. Auditory cortex labels (A1, R, CM, CL areas)"
echo "  4. Cingulate cortex labels"
echo "  5. Subcortical labels (amygdala, thalamus, caudate, putamen, pallidum)"
echo ""
echo "Once identified, update STAGE1b script with specific label numbers"
echo ""

# ==========================================
# Create template ROI extraction script (to be customized)
# ==========================================

cat > $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh << 'EOFROI'
#!/bin/bash

# ==========================================
# STAGE 1b: EXTRACT MARMOSET VOCALIZATION ROIs
# ==========================================
# CUSTOMIZE THIS SCRIPT with actual label numbers from MBM atlas
# ==========================================

MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1"
OUTPUT_DIR="./marmoset_vocalization_ROIs"

CORTICAL_ATLAS="$MBM_DIR/atlas_MBM_cortex_vPaxinos.nii.gz"
SUBCORTICAL_ATLAS="$MBM_DIR/atlas_MBM_subcortical_beta.nii.gz"
TEMPLATE_BRAIN="$MBM_DIR/template_T2w_brain.nii.gz"

echo "==========================================="
echo "EXTRACTING MARMOSET VOCALIZATION ROIs"
echo "==========================================="

# ==========================================
# 1. VOCAL MOTOR CORTEX
# ==========================================
echo "Creating vocal motor cortex ROIs..."

# TODO: Replace XXX with actual label numbers from atlas
# Example labels (NEED TO VERIFY IN ATLAS):
# Left motor: labels for left motor cortex (area 4, 6)
# Right motor: labels for right motor cortex

# Example command (customize labels):
3dcalc -a $CORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_motor_cortex.nii.gz

echo "  [TEMPLATE] Motor cortex - NEEDS LABEL NUMBERS"

# ==========================================
# 2. PREFRONTAL CORTEX (Area 45, ventral PFC)
# ==========================================
echo "Creating prefrontal cortex ROIs..."

3dcalc -a $CORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_prefrontal.nii.gz

echo "  [TEMPLATE] Prefrontal - NEEDS LABEL NUMBERS"

# ==========================================
# 3. AUDITORY CORTEX
# ==========================================
echo "Creating auditory cortex ROIs..."

# Core + belt auditory regions
3dcalc -a $CORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_auditory.nii.gz

echo "  [TEMPLATE] Auditory cortex - NEEDS LABEL NUMBERS"

# ==========================================
# 4. CINGULATE CORTEX
# ==========================================
echo "Creating cingulate cortex ROIs..."

# Anterior and mid-cingulate
3dcalc -a $CORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_cingulate.nii.gz

echo "  [TEMPLATE] Cingulate - NEEDS LABEL NUMBERS"

# ==========================================
# 5. SUBCORTICAL STRUCTURES
# ==========================================
echo "Creating subcortical ROIs..."

# Amygdala (left + right)
3dcalc -a $SUBCORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_amygdala.nii.gz

# Thalamus
3dcalc -a $SUBCORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_thalamus.nii.gz

# Caudate
3dcalc -a $SUBCORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_caudate.nii.gz

# Putamen
3dcalc -a $SUBCORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_putamen.nii.gz

# Pallidum
3dcalc -a $SUBCORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_pallidum.nii.gz

# Nucleus Accumbens (if available)
3dcalc -a $SUBCORTICAL_ATLAS \
       -expr 'amongst(a,XXX,XXX)' \
       -prefix $OUTPUT_DIR/bilateral_accumbens.nii.gz

echo "  [TEMPLATE] Subcortical structures - NEEDS LABEL NUMBERS"

# ==========================================
# 6. COMBINED VOCALIZATION NETWORK
# ==========================================
echo "Creating combined vocalization network..."

3dcalc -a $OUTPUT_DIR/bilateral_motor_cortex.nii.gz \
       -b $OUTPUT_DIR/bilateral_prefrontal.nii.gz \
       -c $OUTPUT_DIR/bilateral_auditory.nii.gz \
       -d $OUTPUT_DIR/bilateral_cingulate.nii.gz \
       -e $OUTPUT_DIR/bilateral_amygdala.nii.gz \
       -f $OUTPUT_DIR/bilateral_thalamus.nii.gz \
       -g $OUTPUT_DIR/bilateral_caudate.nii.gz \
       -h $OUTPUT_DIR/bilateral_putamen.nii.gz \
       -i $OUTPUT_DIR/bilateral_pallidum.nii.gz \
       -expr 'step(a+b+c+d+e+f+g+h+i)' \
       -prefix $OUTPUT_DIR/complete_vocalization_network.nii.gz

echo "[OK] All ROI masks created"
echo ""
echo "Output directory: $OUTPUT_DIR"
ls -lh $OUTPUT_DIR/*.nii.gz
EOFROI

chmod +x $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh

echo ""
echo "==========================================="
echo "STAGE 1 PREPARATION COMPLETE"
echo "==========================================="
echo ""
echo "Next steps:"
echo "  1. Examine atlas labels printed above"
echo "  2. Edit $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh"
echo "  3. Replace XXX with actual label numbers"
echo "  4. Run: $OUTPUT_DIR/STAGE1b_extract_vocalization_ROIs.sh"
echo ""
echo "Reference file: $OUTPUT_DIR/marmoset_vocalization_homology.txt"
echo ""
