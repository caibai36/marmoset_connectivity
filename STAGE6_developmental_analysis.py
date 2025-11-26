#!/usr/bin/env python3

"""
STAGE 6: DEVELOPMENTAL ANALYSIS
================================
Analyzes how vocalization network connectivity changes with age
Identifies developmental trajectories
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.optimize import curve_fit
import glob

# Configuration
CONNECTIVITY_DIR = "./connectivity_matrices"
OUTPUT_DIR = "./developmental_analysis"

# Developmental models
def linear_model(age, a, b):
    """Linear growth: y = a*x + b"""
    return a * age + b

def logarithmic_model(age, a, b):
    """Logarithmic: y = a*log(x) + b"""
    return a * np.log(age) + b

def exponential_model(age, a, b, c):
    """Exponential: y = a*exp(-b*x) + c"""
    return a * np.exp(-b * age) + c

def plot_developmental_trajectory(data_df, output_file):
    """
    Plot connectivity vs age with fitted models
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Vocalization Network Connectivity Development', fontsize=16, fontweight='bold')

    # Sort by age
    data_df = data_df.sort_values('age_months')

    ages = data_df['age_months'].values
    connectivity = data_df['mean_connectivity'].values

    # Color code by sex
    colors = {'m': 'blue', 'f': 'red', 'M': 'blue', 'F': 'red'}
    sex_colors = [colors.get(s, 'gray') for s in data_df['sex']]

    # 1. Overall scatter with linear fit
    ax = axes[0, 0]
    for sex in ['m', 'f', 'M', 'F']:
        sex_data = data_df[data_df['sex'] == sex]
        if len(sex_data) > 0:
            ax.scatter(sex_data['age_months'],
                      sex_data['mean_connectivity'],
                      c=colors.get(sex, 'gray'),
                      label=f'{"Male" if sex.lower()=="m" else "Female"}',
                      s=100, alpha=0.7, edgecolors='black')

    # Linear fit
    slope, intercept, r_value, p_value, std_err = stats.linregress(ages, connectivity)
    age_pred = np.linspace(ages.min(), ages.max(), 100)
    conn_pred = linear_model(age_pred, slope, intercept)

    ax.plot(age_pred, conn_pred, 'k--', linewidth=2,
           label=f'Linear fit (R²={r_value**2:.3f}, p={p_value:.4f})')

    ax.set_xlabel('Age (months)', fontsize=12)
    ax.set_ylabel('Mean Connectivity (r)', fontsize=12)
    ax.set_title('A. Linear Model', fontsize=12, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 2. Logarithmic model
    ax = axes[0, 1]
    ax.scatter(ages, connectivity, c=sex_colors, s=100, alpha=0.7, edgecolors='black')

    try:
        popt_log, _ = curve_fit(logarithmic_model, ages, connectivity)
        conn_pred_log = logarithmic_model(age_pred, *popt_log)
        ax.plot(age_pred, conn_pred_log, 'g--', linewidth=2,
               label=f'Logarithmic fit')

        # Calculate R²
        residuals = connectivity - logarithmic_model(ages, *popt_log)
        ss_res = np.sum(residuals**2)
        ss_tot = np.sum((connectivity - np.mean(connectivity))**2)
        r2_log = 1 - (ss_res / ss_tot)

        ax.text(0.05, 0.95, f'R² = {r2_log:.3f}',
               transform=ax.transAxes, fontsize=10,
               verticalalignment='top',
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    except:
        ax.text(0.5, 0.5, 'Fit failed',
               transform=ax.transAxes, ha='center')

    ax.set_xlabel('Age (months)', fontsize=12)
    ax.set_ylabel('Mean Connectivity (r)', fontsize=12)
    ax.set_title('B. Logarithmic Model', fontsize=12, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 3. Developmental phases
    ax = axes[1, 0]

    # Define developmental phases
    juvenile = data_df[data_df['age_months'] < 18]
    young_adult = data_df[(data_df['age_months'] >= 18) & (data_df['age_months'] < 48)]
    mature_adult = data_df[(data_df['age_months'] >= 48) & (data_df['age_months'] < 84)]
    older_adult = data_df[data_df['age_months'] >= 84]

    phases = []
    phase_data = []
    phase_labels = []

    if len(juvenile) > 0:
        phases.append('Juvenile\n(<18mo)')
        phase_data.append(juvenile['mean_connectivity'])
        phase_labels.append('J')

    if len(young_adult) > 0:
        phases.append('Young Adult\n(18-48mo)')
        phase_data.append(young_adult['mean_connectivity'])
        phase_labels.append('YA')

    if len(mature_adult) > 0:
        phases.append('Mature Adult\n(48-84mo)')
        phase_data.append(mature_adult['mean_connectivity'])
        phase_labels.append('MA')

    if len(older_adult) > 0:
        phases.append('Older Adult\n(>84mo)')
        phase_data.append(older_adult['mean_connectivity'])
        phase_labels.append('OA')

    # Box plot
    bp = ax.boxplot(phase_data, labels=phases, patch_artist=True)
    for patch in bp['boxes']:
        patch.set_facecolor('lightblue')

    # Add scatter points
    for i, phase in enumerate(phase_data):
        y = phase
        x = np.random.normal(i+1, 0.04, size=len(y))
        ax.scatter(x, y, alpha=0.5, s=50, c='darkblue')

    ax.set_ylabel('Mean Connectivity (r)', fontsize=12)
    ax.set_title('C. Developmental Phases', fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    # Statistical comparison
    if len(phase_data) >= 2:
        from scipy.stats import f_oneway
        f_stat, p_val = f_oneway(*phase_data)
        ax.text(0.05, 0.95, f'ANOVA: F={f_stat:.2f}, p={p_val:.4f}',
               transform=ax.transAxes, fontsize=10,
               verticalalignment='top',
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    # 4. Variance analysis
    ax = axes[1, 1]
    ax.scatter(ages, data_df['std_connectivity'], c=sex_colors, s=100, alpha=0.7, edgecolors='black')

    # Fit line
    slope_std, intercept_std, r_std, p_std, _ = stats.linregress(ages, data_df['std_connectivity'])
    conn_std_pred = linear_model(age_pred, slope_std, intercept_std)
    ax.plot(age_pred, conn_std_pred, 'k--', linewidth=2,
           label=f'Linear fit (R²={r_std**2:.3f}, p={p_std:.4f})')

    ax.set_xlabel('Age (months)', fontsize=12)
    ax.set_ylabel('Connectivity Variability (SD)', fontsize=12)
    ax.set_title('D. Network Variability', fontsize=12, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

    return slope, intercept, r_value, p_value

def analyze_edge_development(connectivity_dir, output_dir):
    """
    Analyze development of individual edges (ROI-ROI connections)
    """
    print("Analyzing edge-wise development...")

    # Load all connectivity matrices
    conn_files = glob.glob(f"{connectivity_dir}/individual/*_corr.npy")

    if len(conn_files) == 0:
        print("  WARNING: No connectivity matrices found")
        return

    # Load summary to get ages
    summary_df = pd.read_csv(f"{connectivity_dir}/summary/connectivity_summary.csv")

    # Load first matrix to get dimensions
    first_matrix = np.load(conn_files[0])
    n_rois = first_matrix.shape[0]

    # Create array to store all matrices
    all_matrices = []
    ages = []
    subjects = []

    for conn_file in conn_files:
        subject_id = os.path.basename(conn_file).replace('_corr.npy', '')

        # Get age
        subj_data = summary_df[summary_df['subject_id'] == subject_id]
        if len(subj_data) == 0:
            continue

        age = subj_data['age_months'].values[0]

        # Load matrix
        matrix = np.load(conn_file)

        all_matrices.append(matrix)
        ages.append(age)
        subjects.append(subject_id)

    all_matrices = np.array(all_matrices)  # Shape: [n_subjects, n_rois, n_rois]
    ages = np.array(ages)

    print(f"  Loaded {len(all_matrices)} matrices")

    # Analyze each edge
    edge_correlations = np.zeros((n_rois, n_rois))
    edge_pvalues = np.zeros((n_rois, n_rois))

    for i in range(n_rois):
        for j in range(i+1, n_rois):
            # Get this edge across all subjects
            edge_values = all_matrices[:, i, j]

            # Correlate with age
            r, p = stats.pearsonr(ages, edge_values)

            edge_correlations[i, j] = r
            edge_correlations[j, i] = r
            edge_pvalues[i, j] = p
            edge_pvalues[j, i] = p

    # Save edge analysis
    np.save(f"{output_dir}/edge_age_correlations.npy", edge_correlations)
    np.save(f"{output_dir}/edge_age_pvalues.npy", edge_pvalues)

    # Plot
    plt.figure(figsize=(10, 8))
    mask = np.triu(np.ones_like(edge_correlations, dtype=bool), k=1)
    sns.heatmap(edge_correlations,
                mask=mask,
                cmap='RdBu_r',
                center=0,
                vmin=-1, vmax=1,
                square=True,
                cbar_kws={'label': 'Correlation with Age'})
    plt.title('Edge-wise Developmental Correlations', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(f"{output_dir}/edge_development_heatmap.png", dpi=300, bbox_inches='tight')
    plt.close()

    print(f"  [OK] Edge-wise analysis complete")

    # Find strongest developmental changes
    triu_indices = np.triu_indices_from(edge_correlations, k=1)
    edge_r = edge_correlations[triu_indices]
    edge_p = edge_pvalues[triu_indices]

    # Significant edges (p < 0.05)
    sig_mask = edge_p < 0.05
    n_sig = np.sum(sig_mask)

    print(f"  Found {n_sig} edges with significant age correlations (p<0.05)")

    return edge_correlations, edge_pvalues

def main():
    print("="*50)
    print("STAGE 6: DEVELOPMENTAL ANALYSIS")
    print("="*50)
    print()

    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Load connectivity summary
    summary_file = f"{CONNECTIVITY_DIR}/summary/connectivity_summary.csv"
    if not os.path.exists(summary_file):
        print(f"ERROR: Summary file not found: {summary_file}")
        return

    summary_df = pd.read_csv(summary_file)
    print(f"Loaded data for {len(summary_df)} subjects")
    print(f"Age range: {summary_df['age_months'].min():.1f} - {summary_df['age_months'].max():.1f} months")
    print()

    # Overall developmental trajectory
    print("Computing developmental trajectories...")
    slope, intercept, r_value, p_value = plot_developmental_trajectory(
        summary_df,
        f"{OUTPUT_DIR}/developmental_trajectory.png"
    )

    print(f"  Linear model: connectivity = {slope:.4f} * age + {intercept:.4f}")
    print(f"  R² = {r_value**2:.4f}, p = {p_value:.4f}")
    print()

    # Edge-wise analysis
    edge_corr, edge_p = analyze_edge_development(CONNECTIVITY_DIR, OUTPUT_DIR)

    # Save summary statistics
    results = {
        'n_subjects': len(summary_df),
        'age_min': summary_df['age_months'].min(),
        'age_max': summary_df['age_months'].max(),
        'age_mean': summary_df['age_months'].mean(),
        'age_std': summary_df['age_months'].std(),
        'connectivity_age_slope': slope,
        'connectivity_age_intercept': intercept,
        'connectivity_age_r': r_value,
        'connectivity_age_r2': r_value**2,
        'connectivity_age_p': p_value
    }

    results_df = pd.DataFrame([results])
    results_df.to_csv(f"{OUTPUT_DIR}/developmental_summary.csv", index=False)

    print("="*50)
    print("DEVELOPMENTAL ANALYSIS COMPLETE")
    print("="*50)
    print()
    print(f"Output directory: {OUTPUT_DIR}")
    print()
    print("Key findings:")
    print(f"  - Age range: {results['age_min']:.0f}-{results['age_max']:.0f} months")
    print(f"  - Age-connectivity correlation: r={r_value:.3f}, p={p_value:.4f}")
    print(f"  - Developmental change: {'SIGNIFICANT' if p_value < 0.05 else 'NOT SIGNIFICANT'}")
    print()

if __name__ == "__main__":
    main()
