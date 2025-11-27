# Complete Label Mapping: Paxinos vs RIKEN
## For Easy Cross-Reference

---

## Does Sequential Numbering Matter for Code Complexity?

**Answer: Not really!** The code is almost identical.

### Code Comparison

**PAXINOS (Sequential):**
```bash
# Motor cortex
3dcalc -a atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,37)+equals(a,38)' \
       -prefix motor_M1.nii.gz
```

**RIKEN (Non-sequential):**
```bash
# Motor cortex (same region, different numbers)
3dcalc -a atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,31)+equals(a,32)' \
       -prefix motor_M1.nii.gz
```

**Difference:** Just the label numbers (37,38 vs 31,32). Code structure is identical!

**Verdict:** Sequential numbering is a **minor convenience**, not a major complexity difference.

---

## When Sequential Numbering Helps (Slightly)

### 1. Looping Over All Labels
```bash
# PAXINOS (easy):
for i in {1..135}; do
    3dcalc -a atlas.nii.gz -expr "equals(a,$i)" -prefix roi_${i}.nii.gz
done

# RIKEN (need explicit list):
for i in 26 27 28 29 30 31 32 33 ... 150; do  # harder to write
    3dcalc -a atlas.nii.gz -expr "equals(a,$i)" -prefix roi_${i}.nii.gz
done
```

**But:** For targeted ROI extraction (what you're doing), this doesn't matter!

### 2. Quick Label Lookup
```bash
# PAXINOS: Label 54 is probably around line 54 in the file
# RIKEN: Label 54 could be anywhere (it's A23b, not AuA1)
```

**But:** You have the full mapping table below, so this doesn't matter either!

---

## Complete Label Mapping for Vocalization Regions

### VOCAL MOTOR CORTEX

| Region | Paxinos Label | RIKEN Label | Function |
|--------|---------------|-------------|----------|
| **Primary Motor (M1)** |
| A4ab | 37 | 31 | Face/larynx motor control |
| A4c | 38 | 32 | Caudal M1 |
| **Premotor/SMA (Area 6)** |
| A6DC | 39 | 33 | Dorsal premotor (caudal) |
| A6DR | 40 | 34 | Dorsal premotor (rostral) |
| A6M | 41 | 35 | Medial Area 6 (SMA) |
| A6Va | 42 | 36 | Ventral Area 6a |
| A6Vb | 43 | 37 | Ventral Area 6b |
| **Ventrolateral PFC** |
| A45 | 31 | 70 | Vocal planning (Broca's homolog) |
| **Premotor** |
| ProM | 103 | 118 | Premotor cortex |

**Quick Reference:**
- PAXINOS Motor: `equals(a,37)+equals(a,38)+equals(a,39)+equals(a,40)+equals(a,41)+equals(a,42)+equals(a,43)+equals(a,31)+equals(a,103)`
- RIKEN Motor: `equals(a,31)+equals(a,32)+equals(a,33)+equals(a,34)+equals(a,35)+equals(a,36)+equals(a,37)+equals(a,70)+equals(a,118)`

---

### LIMBIC VOCALIZATION SYSTEM

| Region | Paxinos Label | RIKEN Label | Function |
|--------|---------------|-------------|----------|
| **Anterior Cingulate (ACC)** |
| A24a | 16 | 57 | Anterior cingulate (subgenual) |
| A24b | 17 | 58 | Anterior cingulate (pregenual) |
| A24c | 18 | 59 | Anterior cingulate (mid) |
| A24d | 19 | 60 | Anterior cingulate (dorsal) |
| A25 | 20 | 61 | Ventral ACC |
| A32 | 25 | 66 | Dorsal ACC |
| A32V | 26 | 67 | Ventral A32 |
| **Insula** |
| AI | 50 | 26 | Anterior insula (emotion) |
| DI | 67 | 88 | Dorsal insula |
| GI | 72 | 92 | Granular insula (interoception) |
| ReI | 105 | 121 | Retrosplenial insula |
| **Orbitofrontal Cortex (OFC)** |
| A13L | 4 | 47 | Lateral Area 13 |
| A13M | 5 | 48 | Medial Area 13 |
| A13a | 6 | 45 | Area 13a |
| A13b | 7 | 46 | Area 13b |
| A14C | 8 | 49 | Caudal Area 14 |
| A14R | 9 | 50 | Rostral Area 14 |
| **Gustatory** |
| Gu | 73 | 93 | Gustatory cortex |

**Quick Reference:**
- PAXINOS Limbic: `16-20, 25-26` (ACC) + `50,67,72,105` (Insula) + `4-9` (OFC) + `73` (Gu)
- RIKEN Limbic: `57-61,66-67` (ACC) + `26,88,92,121` (Insula) + `45-50` (OFC) + `93` (Gu)

---

### AUDITORY-VOCAL INTEGRATION

| Region | Paxinos Label | RIKEN Label | Function |
|--------|---------------|-------------|----------|
| **Core Auditory** |
| AuA1 | 54 | 81 | Primary auditory cortex (A1) |
| **Rostral Auditory Belt** |
| AuR | 60 | 82 | Rostral belt (call-selective) |
| AuRM | 61 | 84 | Rostromedial belt |
| AuRT | 63 | 87 | Rostrotemporal belt |
| AuRTL | 64 | 85 | Rostrotemporal lateral |
| AuRTM | 65 | 86 | Rostrotemporal medial |
| **Caudal/Lateral Belt** |
| AuAL | 55 | 76 | Anterolateral belt |
| AuCL | 56 | 77 | Caudolateral belt |
| AuCM | 57 | 78 | Caudomedial belt |
| AuML | 59 | 80 | Mediolateral belt |
| **Parabelt** |
| AuCPB | 58 | 79 | Caudal parabelt |
| AuRPB | 62 | 83 | Rostral parabelt |
| **Superior Temporal** |
| STR | 111 | 126 | Superior temporal rostral |

**Quick Reference:**
- PAXINOS Auditory: `54` (Core) + `60-65` (Rostral) + `55-59` (Caudal) + `58,62` (Parabelt) + `111` (STR)
- RIKEN Auditory: `81` (Core) + `82,84-87` (Rostral) + `76-80` (Caudal) + `79,83` (Parabelt) + `126` (STR)

---

### TEMPORAL/ASSOCIATION CORTEX

| Region | Paxinos Label | RIKEN Label | Function |
|--------|---------------|-------------|----------|
| **Temporal Cortex** |
| TE1 | 112 | 128 | Temporal area 1 |
| TE2 | 113 | 129 | Temporal area 2 |
| TE3 | 114 | 130 | Temporal area 3 |
| TEO | 115 | 131 | Temporo-occipital |
| **Temporoparietal** |
| TPO | 121 | 138 | Temporoparietal occipital |
| TPPro | 122 | 139 | Temporoparietal projection |
| TPt | 124 | 140 | Temporoparietal transitional |

**Quick Reference:**
- PAXINOS Temporal: `112-115` (TE) + `121-122,124` (TPO)
- RIKEN Temporal: `128-131` (TE) + `138-140` (TPO)

---

## Complete Alphabetical Mapping (All 135/141 Regions)

### A Regions

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| A1/A2 | 1 | 28 | A23V | 12 | 56 |
| A10 | 2 | 43 | A24a | 16 | 57 |
| A11 | 3 | 44 | A24b | 17 | 58 |
| A13L | 4 | 47 | A24c | 18 | 59 |
| A13M | 5 | 48 | A24d | 19 | 60 |
| A13a | 6 | 45 | A25 | 20 | 61 |
| A13b | 7 | 46 | A29a-c | 21 | 62 |
| A14C | 8 | 49 | A29d | 22 | 63 |
| A14R | 9 | 50 | A30 | 23 | 64 |
| A19DI | 10 | 51 | A31 | 24 | 65 |
| A19M | 11 | 52 | A32 | 25 | 66 |
| A23a | 13 | 53 | A32V | 26 | 67 |
| A23b | 14 | 54 | A35 | 27 | 68 |
| A23c | 15 | 55 | A36 | 28 | 69 |

### A Regions (continued)

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| A3a | 29 | 29 | A6M | 41 | 35 |
| A3b | 30 | 30 | A6Va | 42 | 36 |
| A45 | 31 | 70 | A6Vb | 43 | 37 |
| A46D | 32 | 71 | A8C | 44 | 41 |
| A46V | 33 | 72 | A8aD | 45 | 38 |
| A47L | 34 | 73 | A8Av | 46 | 39 |
| A47M | 35 | 74 | A8b | 47 | 40 |
| A47O | 36 | 75 | A9 | 48 | 42 |
| A4ab | 37 | 31 | AI | 50 | 26 |
| A4c | 38 | 32 | AIP | 51 | 27 |
| A6DC | 39 | 33 | Apri | 52 | 169 |
| A6DR | 40 | 34 |

### Auditory Regions (Au)

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| AuA1 | 54 | 81 | AuRM | 61 | 84 |
| AuAL | 55 | 76 | AuRPB | 62 | 83 |
| AuCL | 56 | 77 | AuRT | 63 | 87 |
| AuCM | 57 | 78 | AuRTL | 64 | 85 |
| AuCPB | 58 | 79 | AuRTM | 65 | 86 |
| AuML | 59 | 80 | DI | 67 | 88 |
| AuR | 60 | 82 |

### E-I Regions

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| Ent | 70 | 89 | Ipro | 75 | 95 |
| FST | 71 | 91 | LIP | 76 | 96 |
| GI | 72 | 92 | MIP | 79 | 97 |
| Gu | 73 | 93 | MST | 81 | 98 |

### O-P Regions

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| OPAl | 83 | 101 | PFG | 90 | 109 |
| OPro | 84 | 102 | PG | 91 | 110 |
| OPt | 85 | 100 | PGM | 92 | 112 |
| PaIL | 96 | 103 | Pga-IPa | 93 | 111 |
| PaIM | 97 | 104 | Pir | 100 | 113 |
| PE | 87 | 106 | ProM | 103 | 118 |
| PEC | 88 | 107 | ProSt | 104 | 119 |
| PF | 89 | 108 |

### R-S Regions

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| ReI | 105 | 121 | S2PR | 108 | 124 |
| S2E | 106 | 122 | S2PV | 109 | 125 |
| S2I | 107 | 123 | STR | 111 | 126 |

### T-V Regions

| Region | Paxinos | RIKEN | Region | Paxinos | RIKEN |
|--------|---------|-------|--------|---------|-------|
| TE1 | 112 | 128 | V1 | 126 | 142 |
| TE2 | 113 | 129 | V2 | 127 | 143 |
| TE3 | 114 | 130 | V3 | 128 | 144 |
| TEO | 115 | 131 | V3A | 129 | 145 |
| TF | 116 | 132 | V4 | 130 | 146 |
| TFO | 117 | 133 | V4T | 131 | 147 |
| TH | 118 | 134 | V5 | 132 | 148 |
| TL | 119 | 135 | V6 | 133 | 149 |
| TLO | 120 | 136 | V6A | 134 | 150 |
| TPO | 121 | 138 | VIP | 135 | 141 |
| TPPro | 122 | 139 |
| Tpro | 123 | 137 |
| TPt | 124 | 140 |

---

## Paxinos Dummy Labels (What's Missing)

These labels exist in Paxinos but are "dummylabel" placeholders:

| Paxinos Label | Would Be Between | Likely Region Type |
|---------------|------------------|-------------------|
| 49 | A9 → AI | ? |
| 53 | Apri → AuA1 | ? |
| 66 | AuRTM → DI | Auditory? |
| 68, 69 | DI → Ent | ? |
| 74 | Gu → Ipro | ? |
| 77, 78 | LIP → MIP | Parietal |
| 80 | MIP → MST | Parietal |
| 82 | MST → OPAl | ? |
| 86 | OPt → PE | Parietal |
| 94, 95 | Pga-IPa → PaIL | Parietal |
| 98, 99 | PaIM → Pir | ? |
| 101, 102 | Pir → ProM | ? |
| 110 | S2PV → STR | Somatosensory? |
| 125 | TPt → V1 | Visual? |

**All vocalization-critical regions are present in both atlases!**

---

## Usage Examples

### Extract Same ROI from Both Atlases

```bash
# PAXINOS version
3dcalc -a atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
       -expr 'equals(a,54)' \
       -prefix A1_paxinos.nii.gz

# RIKEN version (same region, different label)
3dcalc -a atlas_RikenBMA_cortex_0.5mm.nii.gz \
       -expr 'equals(a,81)' \
       -prefix A1_riken.nii.gz

# Compare overlap
3dcalc -a A1_paxinos.nii.gz -b A1_riken.nii.gz \
       -expr 'step(a)*step(b)' \
       -prefix A1_overlap.nii.gz
```

### Convert Label Numbers Between Atlases

```bash
# You have PAXINOS label 54 (AuA1)
# What's the RIKEN equivalent?
# Answer: 81 (from table above)

# Or use this lookup:
paxinos_label=54
region_name=$(grep "^[[:space:]]*${paxinos_label}[[:space:]]" atlas_MBM_cortex_vPaxinos.txt | awk '{print $2}')
riken_label=$(grep "[[:space:]]${region_name}[[:space:]]" atlas_RikenBMA_cortex.txt | awk '{print $1}')
echo "Paxinos $paxinos_label ($region_name) = RIKEN $riken_label"
```

---

## Bottom Line

**Code Complexity Difference: Minimal!**

The only real difference is which label numbers you type. The logic, structure, and methods are identical.

**Sequential vs Non-Sequential:**
- **Minor advantage:** Sequential is slightly easier to read/debug
- **Not a dealbreaker:** Non-sequential works just fine
- **Your choice:** Use whichever atlas you prefer

**My recommendation:**
- **Primary analysis:** Use PAXINOS (scripts already done)
- **Compatibility:** Use RIKEN if collaborating with others who use it
- **Both available:** Run both scripts, compare if needed

You now have both versions ready to use! 🎯
