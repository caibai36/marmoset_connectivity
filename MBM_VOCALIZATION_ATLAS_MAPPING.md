# MBM Atlas Labels for Affective Vocalization Networks
## Based on Actual MBM v3.0.1 Paxinos Atlas

**Atlas File:** `atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz`
**Location:** `/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm/`

---

## NETWORK 1: VOCAL MOTOR CORTEX

### Primary Motor Cortex (M1 - Face/Larynx Representation)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 37 | A4ab | Primary motor cortex (face/orofacial region) |
| 38 | A4c | Primary motor cortex (caudal M1) |

**Function:** Direct motor control of vocal apparatus (larynx, tongue, lips)

**Developmental Prediction:** Matures mid-infancy in marmosets (~4-8 weeks)

---

### Premotor and Supplementary Motor Areas (Area 6)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 39 | A6DC | Dorsal premotor cortex (caudal) |
| 40 | A6DR | Dorsal premotor cortex (rostral) |
| 41 | A6M | Medial Area 6 (SMA - supplementary motor area) |
| 42 | A6Va | Ventral Area 6a (vocal premotor) |
| 43 | A6Vb | Ventral Area 6b (oro-facial premotor) |
| 103 | ProM | Premotor cortex |

**Function:** Vocalization planning, sequencing, and initiation

**Developmental Prediction:** SMA matures early; dorsal PMd develops later

---

### Ventrolateral Prefrontal Cortex (Vocal Planning)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 31 | A45 | Ventrolateral PFC (analogous to human Broca's area) |

**Function:** Motor planning for voluntary vocalizations

**Note:** Marmosets do NOT have a full Broca's area homolog, but A45 is involved in oro-facial motor control and vocal planning.

**Developmental Prediction:** Late development (~8-12 weeks), critical for vocal learning

---

## NETWORK 2: LIMBIC VOCALIZATION SYSTEM (Affective Control)

### Anterior Cingulate Cortex (Voluntary Vocal Control)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 16 | A24a | Anterior cingulate (subgenual) |
| 17 | A24b | Anterior cingulate (pregenual) |
| 18 | A24c | Anterior cingulate (mid) |
| 19 | A24d | Anterior cingulate (dorsal) |
| 20 | A25 | Ventral anterior cingulate |
| 25 | A32 | Dorsal anterior cingulate |
| 26 | A32V | Ventral A32 |

**Function:**
- Voluntary initiation of vocalizations
- Gating of innate calls
- Conflict resolution (when to call vs be silent)
- Turn-taking control in antiphonal calling

**Critical for:** Marmoset vocal turn-taking behavior (mother-infant exchanges)

**Developmental Prediction:**
- Ventral ACC (A25): Early development (innate calls)
- Dorsal ACC (A24d, A32): Late development (voluntary control)

---

### Insula (Interoception & Emotional Expression)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 50 | AI | Anterior insula (emotional awareness) |
| 67 | DI | Dorsal insula (sensorimotor) |
| 72 | GI | Granular insula (interoceptive processing) |
| 105 | ReI | Retrosplenial insula |

**Function:**
- Interoceptive awareness (bodily states)
- Emotional state monitoring
- Links emotion to vocal expression
- Arousal-dependent call production

**Critical for:** Emotion-driven vocalizations (distress calls, affiliative calls)

**Developmental Prediction:** Anterior insula develops with emotional regulation (~6-10 weeks)

---

### Orbitofrontal Cortex (Affective Valence)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 4 | A13L | Lateral Area 13 |
| 5 | A13M | Medial Area 13 |
| 6 | A13a | Area 13a |
| 7 | A13b | Area 13b |
| 8 | A14C | Caudal Area 14 (medial OFC) |
| 9 | A14R | Rostral Area 14 |

**Function:**
- Reward/punishment evaluation
- Social context assessment
- Call type selection based on social situation
- Affective valence of vocalizations

**Critical for:** Context-appropriate call production (food calls, alarm calls)

**Developmental Prediction:** Late development (~10-16 weeks), social learning period

---

### Gustatory Cortex (Oro-Facial Control)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 73 | Gu | Gustatory cortex/primary taste area |

**Function:** Oro-facial sensory processing, connected to vocal motor control

---

## NETWORK 3: AUDITORY-VOCAL INTEGRATION

### Core Auditory Cortex (Primary Auditory Processing)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 54 | AuA1 | Primary auditory cortex (A1 - tonotopic core) |

**Function:** Basic auditory processing, frequency discrimination

**Developmental Prediction:** Matures early (~2-4 weeks), critical period for auditory tuning

---

### Rostral Auditory Belt (Call-Selective Responses)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 60 | AuR | Rostral belt |
| 61 | AuRM | Rostromedial belt |
| 63 | AuRT | Rostrotemporal belt |
| 64 | AuRTL | Rostrotemporal lateral |
| 65 | AuRTM | Rostrotemporal medial |

**Function:**
- Call-selective neurons (respond preferentially to conspecific calls)
- Vocal pattern recognition
- Auditory object processing (identifying specific call types)

**Critical for:** Recognition of parental calls, species-specific call discrimination

**Developmental Prediction:** Shows experience-dependent plasticity (~4-10 weeks)

---

### Caudal/Lateral Auditory Belt
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 55 | AuAL | Anterolateral belt |
| 56 | AuCL | Caudolateral belt |
| 57 | AuCM | Caudomedial belt |
| 59 | AuML | Mediolateral belt |

**Function:** Complex sound processing, spectrotemporal analysis

---

### Auditory Parabelt (Higher-Order Auditory)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 58 | AuCPB | Caudal parabelt |
| 62 | AuRPB | Rostral parabelt |

**Function:** Integration with premotor cortex (auditory-motor transformation)

**Critical for:** Audio-vocal feedback loop, vocal learning

---

### Superior Temporal Regions
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 111 | STR | Superior temporal rostral |

**Function:** Higher-level auditory processing, possibly voice recognition

---

## NETWORK 4: TEMPORAL/ASSOCIATION CORTEX

### Temporal Cortex (Social/Vocal Processing)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 112 | TE1 | Temporal area 1 |
| 113 | TE2 | Temporal area 2 |
| 114 | TE3 | Temporal area 3 |
| 115 | TEO | Temporo-occipital |

**Function:** Higher-level social auditory processing, possibly voice identity

---

### Temporoparietal Junction (Audiovisual Integration)
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 121 | TPO | Temporoparietal occipital |
| 122 | TPPro | Temporoparietal projection |
| 124 | TPt | Temporoparietal transitional |

**Function:**
- Audiovisual integration (seeing + hearing caller)
- Multisensory communication processing
- Social attention

**Critical for:** Face-voice integration in social interactions

---

## NETWORK 5: SUBCORTICAL STRUCTURES (TO BE DETERMINED)

### Required Subcortical Regions (Labels TBD):

**Amygdala** ⚠️ CRITICAL FOR AFFECTIVE VOCALIZATION
- Function: Emotional vocalization triggering (fear calls, distress calls)
- Development: Early maturation (innate calls functional from birth)

**Periaqueductal Gray (PAG)** ⚠️ CRITICAL (if available in atlas)
- Function: Innate call production (hardwired vocalization patterns)
- Development: Functional at birth

**Caudate**
- Function: Vocal initiation, turn-taking timing
- Development: Gradual maturation

**Putamen**
- Function: Motor sequencing of vocal patterns
- Development: Mid-infancy

**Globus Pallidus (Pallidum)**
- Function: Gating of vocal motor programs
- Development: Early-mid maturation

**Thalamus** (specific nuclei if available)
- Function: Relay of auditory and motor signals
- Development: Early maturation (sensory relay), late for cognitive control

**Nucleus Accumbens**
- Function: Reward-based vocal learning
- Development: Mid-late infancy (social reward learning)

---

## NETWORK 6: PARIETAL SENSORIMOTOR (Optional - For Completeness)

### Parietal Regions
| Label | Region | Anatomical Note |
|-------|--------|-----------------|
| 51 | AIP | Anterior intraparietal |
| 75 | LIP | Lateral intraparietal |
| 79 | MIP | Medial intraparietal |
| 87 | PE | Parietal E |
| 88 | PEC | Parietal EC |
| 89 | PF | Parietal F |
| 90 | PFG | Parietal FG |

**Function:** Sensorimotor integration, possibly spatial attention to vocalizers

**Note:** These may not be primary vocalization regions but could show developmental changes in sensorimotor integration related to communicative behaviors.

---

## ROI COMBINATION STRATEGY

### For Developmental Analysis:

**Option A: Network-Level ROIs (4 main networks)**
- Network 1: Vocal Motor (all motor/premotor combined)
- Network 2: Limbic (ACC + insula + OFC)
- Network 3: Auditory (core + belt + parabelt)
- Network 4: Temporal (TE + TPO)

**Option B: Functional Subdivision (10-12 ROIs)**
- Motor: M1, SMA, Premotor, vlPFC
- Limbic: ACC, Insula, OFC, Amygdala
- Auditory: Core, Rostral belt, Caudal belt
- Temporal: TE, TPO

**Option C: Detailed Analysis (20+ ROIs)**
- Individual sub-regions for fine-grained developmental trajectories

---

## MARMOSET-HUMAN HOMOLOGY

### Direct Homologs:
| Marmoset (MBM Paxinos) | Human (Desikan-Killiany) | Confidence |
|------------------------|--------------------------|------------|
| A4ab/c | Precentral (BA 4) | High |
| A6M | Paracentral (SMA) | High |
| AuA1 | Transverse Temporal (Heschl's) | High |
| A24a/b/c/d | Rostral/Caudal Anterior Cingulate | High |
| AI, DI | Insula | High |
| A13, A14 | Lateral/Medial Orbitofrontal | Medium-High |
| Amygdala | Amygdala | High |

### Approximate Homologs:
| Marmoset | Human | Note |
|----------|-------|------|
| A45 | Pars Opercularis (BA 44) | Marmoset lacks full Broca's area |
| AuR, AuRT | Superior Temporal | Call-selective regions |
| TE, TPO | Banks STS, Superior Temporal | Audiovisual integration |

---

## EXPECTED DEVELOPMENTAL TRAJECTORIES

### Based on Marmoset Vocal Development Literature:

**Early Infancy (0-4 weeks):**
- **Mature:** PAG (innate calls), Amygdala (distress calls), A1 (basic hearing)
- **Volume increases:** M1, Primary auditory
- **Connectivity:** Amygdala → PAG (innate emotional vocalizations)

**Mid Infancy (4-8 weeks):**
- **Rapid growth:** Premotor cortex (A6), Auditory belt (call recognition)
- **Connectivity emerges:** ACC → Motor (voluntary control), Auditory → Motor (feedback)
- **Behavioral:** Phee calls increase, turn-taking begins

**Late Infancy (8-16 weeks):**
- **Continued growth:** vlPFC (A45), OFC, Dorsal ACC
- **Connectivity matures:** Frontal-limbic, Auditory-motor loops
- **Behavioral:** Adult-like call repertoire, sophisticated turn-taking

**Juvenile-Adult (16 weeks+):**
- **Refinement:** Connectivity patterns stabilize
- **Social learning:** OFC, vlPFC reach mature volumes
- **Behavioral:** Full vocal competence, context-appropriate calling

---

## CRITICAL PARAMETERS FOR EXTRACTION

**Voxel size:** 0.5mm isotropic (125 voxels per mm³)

**Expected ROI volumes (approximate):**
- Primary Motor (M1): 10-20 mm³
- Auditory Core (A1): 5-10 mm³
- ACC (all subdivisions): 15-30 mm³
- Insula (all subdivisions): 20-40 mm³

**For connectivity analysis:**
- Minimum voxels per ROI: ~20-40 voxels (2.5-5 mm³)
- Smaller ROIs risk noisy time series

---

## USAGE WITH EXTRACT SCRIPT

```bash
# Run the extraction script
bash extract_vocalization_ROIs_actual_labels.sh

# Check created ROIs
ls roi_masks/*.nii.gz

# Verify voxel counts
3dBrickStat -count -non-zero roi_masks/network_1_vocal_motor.nii.gz

# Visualize in AFNI
afni -niml &
# Load: template_T2w_brain_0.5mm.nii.gz (underlay)
# Load: network_1_vocal_motor.nii.gz (overlay)
```

---

## NEXT STEPS

1. **Extract subcortical labels:**
   ```bash
   3dinfo -label atlas_MBM_subcortical_beta_0.5mm.nii.gz
   ```

2. **Update extraction script** with correct subcortical label numbers

3. **Run extraction:**
   ```bash
   bash extract_vocalization_ROIs_actual_labels.sh
   ```

4. **For anatomical development:**
   - Register each subject's T2 → MBM template
   - Calculate volumes for each ROI
   - Plot volume vs age

5. **For functional connectivity:**
   - Extract time series from registered BOLD
   - Compute ROI-to-ROI correlations
   - Analyze connectivity vs age

---

## REFERENCES

**Paxinos Marmoset Atlas:**
- Paxinos G, Watson C, Petrides M, Rosa M, Tokuno H. The Marmoset Brain in Stereotaxic Coordinates. Academic Press; 2012.

**MBM Atlas:**
- Liu C, et al. (2018). A digital 3D atlas of the marmoset brain based on multi-modal MRI. NeuroImage, 169:106-116.
- Liu C, et al. (2020). Marmoset Brain Mapping V3: Population multi-modal standard volumetric and surface-based templates. NeuroImage, 117620.

**Marmoset Vocalization Neuroscience:**
- Miller CT, et al. (2016). Marmosets: A neuroscientific model of human social behavior. Neuron, 90(2):219-233.
- Takahashi DY, et al. (2015). The developmental dynamics of marmoset monkey vocal production. Science, 349(6249):734-738.
- Eliades SJ, Wang X. (2008). Neural substrates of vocalization feedback monitoring in primate auditory cortex. Nature, 453(7198):1102-1106.
- Keller GB, Hahnloser RH. (2009). Neural processing of auditory feedback during vocal practice in a songbird. Nature, 457(7226):187-190.
- Roy S, et al. (2016). Assortative pairing and affiliation bias on social vocal exchanges in common marmosets. American Journal of Primatology, 78(12):1233-1244.

**Human Vocalization Development (for comparison):**
- Werker JF, Hensch TK. (2015). Critical periods in speech perception: New directions. Annual Review of Psychology, 66:173-196.
- Kuhl PK. (2004). Early language acquisition: Cracking the speech code. Nature Reviews Neuroscience, 5(11):831-843.

---

**Document Version:** 1.0
**Date:** 2025-11-27
**Author:** Based on user's actual MBM atlas data
