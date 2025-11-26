#!/usr/bin/env python3

"""
STAGE 7: CROSS-SPECIES COMPARISON (MARMOSET-HUMAN)
====================================================
Compares marmoset and human vocalization network connectivity
Identifies homologous patterns and species differences
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats

# Configuration
MARMOSET_DIR = "./connectivity_matrices"
HUMAN_DIR = "./human_vocalization_connectivity"  # If you have human data
OUTPUT_DIR = "./cross_species_comparison"

def create_comparison_framework():
    """
    Create marmoset-human homology framework
    """

    # Define homologous regions
    homology_map = {
        'motor_cortex': {
            'marmoset': 'bilateral_motor_cortex',
            'human': 'bilateral_vocal_motor',
            'confidence': 'HIGH',
            'notes': 'Primary motor areas well-conserved'
        },
        'prefrontal_cortex': {
            'marmoset': 'bilateral_prefrontal',
            'human': 'bilateral_vocal_motor',  # Includes Broca's
            'confidence': 'MEDIUM',
            'notes': 'Marmosets lack direct Broca homolog'
        },
        'auditory_cortex': {
            'marmoset': 'bilateral_auditory',
            'human': 'bilateral_auditory_vocal',
            'confidence': 'HIGH',
            'notes': 'Core auditory cortex well-conserved'
        },
        'cingulate_cortex': {
            'marmoset': 'bilateral_cingulate',
            'human': 'complete_limbic_vocal',
            'confidence': 'HIGH',
            'notes': 'ACC vocalization drive conserved in mammals'
        },
        'amygdala': {
            'marmoset': 'bilateral_amygdala',
            'human': 'complete_limbic_vocal',
            'confidence': 'HIGH',
            'notes': 'Emotional vocalization substrate'
        },
        'thalamus': {
            'marmoset': 'bilateral_thalamus',
            'human': 'complete_limbic_vocal',
            'confidence': 'HIGH',
            'notes': 'Thalamic relay conserved'
        },
        'basal_ganglia': {
            'marmoset': ['bilateral_caudate', 'bilateral_putamen', 'bilateral_pallidum'],
            'human': 'bilateral_basal_ganglia',
            'confidence': 'HIGH',
            'notes': 'Vocal sequencing and timing'
        }
    }

    return homology_map

def plot_homology_framework(output_dir):
    """
    Visualize marmoset-human vocalization network homology
    """
    homology = create_comparison_framework()

    fig, ax = plt.subplots(figsize=(14, 10))

    # Create summary table
    rows = []
    for region, info in homology.items():
        rows.append({
            'Functional System': region.replace('_', ' ').title(),
            'Marmoset Region': info['marmoset'] if isinstance(info['marmoset'], str)
                               else ', '.join(info['marmoset']),
            'Human Homolog': info['human'],
            'Confidence': info['confidence'],
            'Notes': info['notes']
        })

    df = pd.DataFrame(rows)

    # Create color-coded table
    colors_map = {'HIGH': '#90EE90', 'MEDIUM': '#FFD700', 'LOW': '#FFB6C1'}

    ax.axis('tight')
    ax.axis('off')

    table_data = []
    cell_colors = []

    # Header
    table_data.append(df.columns.tolist())
    cell_colors.append(['lightgray'] * len(df.columns))

    # Data rows
    for idx, row in df.iterrows():
        table_data.append(row.tolist())

        # Color code by confidence
        row_colors = ['white'] * len(df.columns)
        row_colors[3] = colors_map[row['Confidence']]
        cell_colors.append(row_colors)

    table = ax.table(cellText=table_data,
                    cellColours=cell_colors,
                    cellLoc='left',
                    loc='center',
                    colWidths=[0.15, 0.25, 0.20, 0.10, 0.30])

    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1, 2)

    # Style header
    for i in range(len(df.columns)):
        table[(0, i)].set_facecolor('darkgray')
        table[(0, i)].set_text_props(weight='bold', color='white')

    plt.title('Marmoset-Human Vocalization Network Homology',
             fontsize=16, fontweight='bold', pad=20)

    plt.savefig(f"{output_dir}/homology_framework.png",
               dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

    # Save as CSV
    df.to_csv(f"{output_dir}/homology_framework.csv", index=False)

    return df

def compare_developmental_trajectories():
    """
    Compare marmoset and human developmental timelines
    """

    # Developmental milestones
    comparison = {
        'Milestone': [
            'Birth vocalizations',
            'Babbling onset',
            'Adult-like calls',
            'Vocal learning critical period',
            'Sexual maturity',
            'Lifespan'
        ],
        'Marmoset (months)': [
            '0',
            '2-4',
            '6-12',
            '0-6',
            '15-18',
            '144-180 (12-15 years)'
        ],
        'Human (months)': [
            '0',
            '6-10',
            '36-48',
            '0-36',
            '144-180',
            '900-1080 (75-90 years)'
        ],
        'Ratio (Marmoset/Human)': [
            '1:1',
            '1:3',
            '1:4',
            '1:6',
            '1:10',
            '1:6'
        ]
    }

    df = pd.DataFrame(comparison)

    return df

def plot_comparative_connectivity_patterns(marmoset_summary, output_dir):
    """
    Plot marmoset connectivity patterns and compare to expected human patterns
    """

    fig, axes = plt.subplots(2, 2, figsize=(16, 14))
    fig.suptitle('Marmoset Vocalization Network: Comparative Analysis',
                fontsize=16, fontweight='bold')

    # 1. Overall connectivity strength
    ax = axes[0, 0]

    marmoset_ages = marmoset_summary['age_months'].values
    marmoset_conn = marmoset_summary['mean_connectivity'].values

    # Convert marmoset age to human-equivalent (approximate scaling: 1 marmoset month ≈ 4 human months)
    human_equiv_age = marmoset_ages * 4

    ax.scatter(human_equiv_age, marmoset_conn,
              c='green', s=100, alpha=0.7, label='Marmoset data (scaled to human age)',
              edgecolors='black')

    # Fit line
    slope, intercept, r, p, _ = stats.linregress(human_equiv_age, marmoset_conn)
    age_pred = np.linspace(human_equiv_age.min(), human_equiv_age.max(), 100)
    conn_pred = slope * age_pred + intercept
    ax.plot(age_pred, conn_pred, 'g--', linewidth=2,
           label=f'Marmoset trend (R²={r**2:.3f})')

    ax.set_xlabel('Age (human-equivalent months)', fontsize=12)
    ax.set_ylabel('Mean Connectivity (r)', fontsize=12)
    ax.set_title('A. Developmental Trajectory\n(Marmoset age × 4 = Human-equivalent)',
                fontsize=12, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Add developmental phases
    ax.axvspan(0, 72, alpha=0.1, color='yellow', label='Infancy')
    ax.axvspan(72, 216, alpha=0.1, color='orange', label='Childhood')
    ax.axvspan(216, 576, alpha=0.1, color='red', label='Adolescence')

    # 2. Species comparison summary
    ax = axes[0, 1]
    ax.axis('off')

    comparison_text = """
MARMOSET vs. HUMAN VOCALIZATION

SIMILARITIES:
✓ Limbic system drives emotional calls
✓ Auditory feedback critical for development
✓ Basal ganglia for sequencing/timing
✓ Cingulate cortex for voluntary control
✓ Social context modulates vocalizations

KEY DIFFERENCES:
✗ Humans: Direct cortical-laryngeal control
  Marmosets: Indirect premotor control

✗ Humans: Left-lateralized speech areas
  Marmosets: More bilateral organization

✗ Humans: Extended learning period (years)
  Marmosets: Rapid maturation (months)

✓ Marmosets: Antiphonal calling (turn-taking)
  Humans: Conversational turn-taking
  → CONVERGENT EVOLUTION

VOCAL LEARNING STATUS:
Both are VOCAL LEARNERS (rare in mammals)
- Marmosets: Limited vocal flexibility
- Humans: Open-ended vocal learning
    """

    ax.text(0.1, 0.95, comparison_text,
           transform=ax.transAxes,
           fontsize=10,
           verticalalignment='top',
           family='monospace',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    # 3. Network maturation rates
    ax = axes[1, 0]

    # Calculate maturation index (connectivity change per month)
    if len(marmoset_ages) > 1:
        # Normalize connectivity to 0-1 range
        conn_norm = (marmoset_conn - marmoset_conn.min()) / \
                    (marmoset_conn.max() - marmoset_conn.min() + 1e-10)

        ax.scatter(marmoset_ages, conn_norm,
                  c='green', s=100, alpha=0.7, edgecolors='black')

        # Fit maturation curve
        slope_m, intercept_m, _, _, _ = stats.linregress(marmoset_ages, conn_norm)
        age_pred_m = np.linspace(marmoset_ages.min(), marmoset_ages.max(), 100)
        conn_pred_m = slope_m * age_pred_m + intercept_m
        ax.plot(age_pred_m, conn_pred_m, 'g-', linewidth=2,
               label=f'Marmoset: {slope_m:.4f} per month')

        ax.set_xlabel('Age (months)', fontsize=12)
        ax.set_ylabel('Normalized Connectivity', fontsize=12)
        ax.set_title('C. Network Maturation Rate', fontsize=12, fontweight='bold')
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Add maturation milestones
        ax.axvline(x=6, color='red', linestyle=':', alpha=0.5, label='Adult-like calls')
        ax.axvline(x=18, color='orange', linestyle=':', alpha=0.5, label='Sexual maturity')

    # 4. Age scaling comparison
    ax = axes[1, 1]

    # Create developmental timeline comparison
    marmoset_milestones = [0, 3, 6, 12, 18]
    human_milestones = [0, 12, 24, 48, 216]  # Birth, 1yr, 2yr, 4yr, 18yr

    ax.plot(marmoset_milestones, human_milestones, 'o-', linewidth=2,
           markersize=10, color='purple', label='Developmental milestones')

    for m_age, h_age in zip(marmoset_milestones, human_milestones):
        ax.annotate(f'{m_age}mo→{h_age}mo',
                   (m_age, h_age),
                   textcoords="offset points",
                   xytext=(0,10),
                   ha='center',
                   fontsize=8)

    ax.set_xlabel('Marmoset Age (months)', fontsize=12)
    ax.set_ylabel('Human-Equivalent Age (months)', fontsize=12)
    ax.set_title('D. Cross-Species Age Scaling', fontsize=12, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(f"{output_dir}/comparative_analysis.png",
               dpi=300, bbox_inches='tight')
    plt.close()

def main():
    print("="*50)
    print("STAGE 7: CROSS-SPECIES COMPARISON")
    print("="*50)
    print()

    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # 1. Create homology framework
    print("Creating homology framework...")
    homology_df = plot_homology_framework(OUTPUT_DIR)
    print(f"[OK] Homology framework created")
    print()

    # 2. Compare developmental timelines
    print("Comparing developmental timelines...")
    timeline_df = compare_developmental_trajectories()
    timeline_df.to_csv(f"{OUTPUT_DIR}/developmental_timeline_comparison.csv", index=False)
    print(timeline_df)
    print()

    # 3. Load marmoset data and create comparative visualizations
    print("Creating comparative visualizations...")
    marmoset_summary = f"{MARMOSET_DIR}/summary/connectivity_summary.csv"

    if os.path.exists(marmoset_summary):
        summary_df = pd.read_csv(marmoset_summary)
        plot_comparative_connectivity_patterns(summary_df, OUTPUT_DIR)
        print(f"[OK] Comparative analysis plots created")
    else:
        print(f"WARNING: Marmoset summary not found: {marmoset_summary}")

    print()

    print("="*50)
    print("CROSS-SPECIES COMPARISON COMPLETE")
    print("="*50)
    print()
    print(f"Output directory: {OUTPUT_DIR}")
    print()
    print("Key outputs:")
    print("  - homology_framework.png/csv: Region-by-region comparison")
    print("  - developmental_timeline_comparison.csv: Milestone comparison")
    print("  - comparative_analysis.png: Connectivity pattern comparison")
    print()
    print("INTERPRETATION NOTES:")
    print("="*50)
    print("• Marmosets mature ~4-10x faster than humans")
    print("• Limbic vocalization circuits are highly conserved")
    print("• Cortical control differs (marmosets lack direct laryngeal control)")
    print("• Both species show vocal learning (rare in mammals)")
    print("• Antiphonal calling in marmosets parallels human turn-taking")
    print()

if __name__ == "__main__":
    main()
