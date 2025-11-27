# Cross-Species Affective Vocalization Development Study
## Two Complementary Analysis Approaches

Based on your goal: **"Compare developmental trajectories of affective vocalization-related brain areas between marmosets and humans across ages"**

You have **TWO parallel approaches** you can take (or do BOTH!):

---

## Approach 1: ANATOMICAL Development (Volume-Based)

### Research Question:
**"How do vocalization-related brain regions GROW in size during development, and is this similar between marmosets and humans?"**

### What You Measure:
- Brain region **volumes** (mm³) for each subject
- Plot: Volume vs Age for each ROI
- Compare: Marmoset growth curves vs Human growth curves

### Data Needed:
**Marmosets:**
- ✅ T2 anatomical scans (you have these)
- ❌ BOLD fMRI (NOT needed for this approach)
- ✅ MBM atlas (for ROI definitions)
- ✅ Age metadata (14-115 months)

**Humans:**
- ✅ T1 anatomical scans (you have these from your reference script)
- ✅ FreeSurfer segmentation (Desikan-Killiany atlas)
- ✅ Age metadata (infant ages)

### Pipeline:
```
MARMOSETS:
T2 scan → Register to MBM template → Extract ROI volumes → CSV of volumes

HUMANS:
T1 scan → FreeSurfer → Extract ROI volumes from aparc.stats → CSV of volumes

ANALYSIS:
Combined CSV → Growth trajectory models → Cross-species comparison
```

### Expected Findings:
- **Early development:** Subcortical regions (amygdala, striatum) mature faster
- **Mid development:** Cortical motor/auditory regions grow
- **Late development:** Frontal/limbic regions continue maturing
- **Species differences:** Marmosets develop faster (compressed timeline)

### Workflow Script:
✅ **ANATOMICAL_DEVELOPMENT_WORKFLOW.sh** (just created!)

Contains:
1. Marmoset-human ROI homology mapping
2. Marmoset volume extraction script
3. Human volume extraction script (based on your T1 script)
4. R script for developmental trajectory analysis

---

## Approach 2: FUNCTIONAL Development (Connectivity-Based)

### Research Question:
**"How does functional CONNECTIVITY between vocalization regions change during development, and is this similar between marmosets and humans?"**

### What You Measure:
- **Correlation strength** between brain regions during rest
- ROI-to-ROI connectivity matrices
- Plot: Connectivity vs Age for each region pair
- Compare: Marmoset connectivity development vs Human connectivity development

### Data Needed:
**Marmosets:**
- ✅ T2 anatomical scans
- ✅ **BOLD resting-state fMRI** (REQUIRED!)
- ✅ MBM atlas
- ✅ Age metadata

**Humans:**
- ✅ T1 anatomical scans
- ✅ **Resting-state fMRI** (if available)
- ✅ Age metadata

### Pipeline:
```
MARMOSETS:
Raw BOLD → Preprocessing (motion correction, filtering)
         → Registration to template
         → Extract ROI time series
         → Compute ROI-to-ROI correlations
         → Connectivity matrix per subject
         → Correlate connectivity with age

HUMANS:
(Same pipeline with human data)

ANALYSIS:
Compare connectivity development trajectories across species
```

### Expected Findings:
- **Early development:** Strong subcortical-limbic connectivity
- **Mid development:** Emergence of cortical-subcortical loops
- **Late development:** Mature long-range auditory-motor integration
- **Species differences:** Similar network architecture, different maturation rates

### Workflow Scripts:
✅ Already created in previous sessions:
- `rs_MASTER.sh` - Preprocessing (✓ Done for m6!)
- `registration_MASTER.sh` - Registration (Next step)
- `STAGE4_extract_timeseries.py` - Time series extraction
- `STAGE5_connectivity_analysis.py` - Connectivity computation
- `STAGE6_developmental_analysis.py` - Age correlation

---

## Comparison: Which Approach for Your Goal?

| Aspect | Anatomical (Volume) | Functional (Connectivity) |
|--------|---------------------|--------------------------|
| **Preprocessing needed?** | ❌ NO | ✅ YES (you completed m6!) |
| **Uses BOLD fMRI?** | ❌ NO | ✅ YES |
| **Measures** | Structure size | Communication between regions |
| **Processing time** | Fast (~minutes per subject) | Slow (~4 hours per subject) |
| **Easier to compare with humans?** | ✅ YES (FreeSurfer standard) | Harder (need human fMRI) |
| **Answers "what grows?"** | ✅ YES | ❌ NO |
| **Answers "how regions connect?"** | ❌ NO | ✅ YES |

---

## Recommendation: Do BOTH!

These approaches are **complementary**, not competing:

### Combined Analysis Power:

**Question 1:** Do larger motor cortices lead to stronger motor-auditory connectivity?
- Anatomical: Measure motor cortex volume
- Functional: Measure motor-auditory correlation
- Combined: Correlate volume with connectivity strength

**Question 2:** What matures faster - structure or function?
- Anatomical: When does insula reach adult size?
- Functional: When does insula-ACC connectivity mature?
- Combined: Compare timing of structural vs functional maturation

**Question 3:** Are marmoset-human differences structural or functional?
- Anatomical: Do marmosets have proportionally smaller frontal cortex?
- Functional: Is frontal-limbic connectivity weaker despite size?
- Combined: Disentangle structure from function

### Publishability:
- **Anatomical only:** Good comparative anatomy paper
- **Functional only:** Good developmental connectivity paper
- **Both combined:** Excellent integrative neuroscience paper! 🏆

---

## What You Should Do Next

### Decision Point:

**Option A: Start with Anatomical (Faster, Simpler)**
```bash
cd /home/user/marmoset_connectivity
bash ANATOMICAL_DEVELOPMENT_WORKFLOW.sh

# This creates:
# 1. ROI homology mapping (marmoset ↔ human)
# 2. Volume extraction scripts
# 3. Statistical analysis pipeline

# Then:
# - Extract marmoset ROI volumes from T2 scans
# - Extract human ROI volumes from FreeSurfer
# - Run developmental trajectory analysis
# - Get results in ~1 week
```

**Option B: Continue with Functional (More Powerful, Already Started!)**
```bash
# You already completed m6 preprocessing! ✓
# Next: Registration

cd /work01/home/bin-wu/.../local/fmri/local
bash registration_MASTER_m6.sh

# Then continue with remaining subjects
# Timeline: ~1 month for full analysis
```

**Option C: Do Both in Parallel (Recommended!)**
```bash
# Person/Pipeline 1: Work on anatomical analysis
# Person/Pipeline 2: Continue functional preprocessing

# Combine results after both complete
```

---

## Key Clarification for Your Question

You asked: **"Do we not need preprocessing results for ROI analysis?"**

**Answer:** It depends on WHICH type of ROI analysis!

### Anatomical ROI Analysis (Volumes):
- ❌ **NO, you don't need preprocessing!**
- Uses: T2 anatomical scans directly
- Extracts: ROI volumes from atlas
- Compares: Volume growth across ages

### Functional ROI Analysis (Connectivity):
- ✅ **YES, you NEED preprocessing!**
- Uses: Preprocessed BOLD fMRI (what you just created for m6)
- Extracts: ROI time series from fMRI
- Compares: Connectivity changes across ages

### For Your Goal:
> "Compare development of affective vocalization related areas with ages across species"

You can study:
1. **How these areas GROW** (anatomical) → No preprocessing needed
2. **How these areas CONNECT** (functional) → Preprocessing needed
3. **Both!** (comprehensive) → Use both approaches

---

## Your Preprocessing IS Valuable!

Your successful m6 preprocessing (**8 files: 4 runs × 2 phase encodings**) is **absolutely necessary** for functional connectivity analysis.

Don't discard it! It took 2-3 hours to generate and is required for studying how vocalization networks communicate during development.

---

## Summary Decision Matrix

**If you want to answer:**
- *"Do motor cortex and amygdala grow at different rates?"* → Anatomical approach
- *"Does motor-auditory connectivity strengthen with age?"* → Functional approach
- *"How do structural growth and functional integration relate?"* → Both approaches
- *"Comprehensive comparison with human development"* → Both approaches

**Given your resources:**
- You have BOLD data ✓
- You already preprocessed m6 ✓
- You have human T1 + FreeSurfer ✓
- You have ages for all subjects ✓

**My recommendation:**
1. **Short-term (1-2 weeks):** Complete anatomical analysis
   - Faster results
   - Easier cross-species comparison
   - Good foundation paper

2. **Long-term (1-2 months):** Complete functional analysis
   - More novel findings
   - Leverages your preprocessing work
   - Publishable in higher-impact journal

3. **Publish:** Combined anatomical + functional developmental study
   - Most comprehensive
   - Strongest scientific contribution

---

## Ready-to-Run Scripts

All created and saved in repository:

**For Anatomical Approach:**
- `ANATOMICAL_DEVELOPMENT_WORKFLOW.sh` - Master workflow
- `extract_marmoset_roi_volumes.sh` - Volume extraction (auto-generated)
- `extract_human_roi_volumes.sh` - Human FreeSurfer volumes
- `analyze_developmental_trajectories.R` - Statistical analysis

**For Functional Approach:**
- `rs_MASTER_m6.sh` - Preprocessing (✓ Done!)
- `registration_MASTER.sh` - Next step
- `STAGE4_extract_timeseries.py` - Time series
- `STAGE5_connectivity_analysis.py` - Connectivity
- `STAGE6_developmental_analysis.py` - Development

**Workflow Guides:**
- `WORKFLOW_CLARIFICATION.md` - Explains both approaches
- `NEXT_STEPS_FOR_M6.md` - Step-by-step for functional
- `TWO_COMPLEMENTARY_APPROACHES.md` - This document!

---

## Questions to Help You Decide

1. **Do you have human resting-state fMRI data?**
   - YES → Do both approaches
   - NO → Start with anatomical (easier comparison)

2. **What's your timeline?**
   - 1-2 weeks → Anatomical only
   - 1-2 months → Both approaches

3. **What's your primary hypothesis?**
   - Structural maturation differs → Anatomical
   - Functional integration differs → Functional
   - Both are important → Both approaches

4. **What journals are you targeting?**
   - Comparative anatomy (Brain Struct Funct) → Anatomical
   - Developmental neuroscience (Dev Cog Neurosci) → Functional
   - Top-tier (eLife, PNAS) → Both combined!

---

Let me know which approach you want to pursue, and I'll help you execute it!
