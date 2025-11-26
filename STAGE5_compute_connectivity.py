#!/usr/bin/env python3

"""
STAGE 5: COMPUTE FUNCTIONAL CONNECTIVITY MATRICES
==================================================
Computes ROI-to-ROI functional connectivity for each subject
Uses Pearson correlation between ROI time series
"""

import os
import numpy as np
import pandas as pd
from pathlib import Path
import glob
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns

# Configuration
TIMESERIES_DIR = "./roi_timeseries"
OUTPUT_DIR = "./connectivity_matrices"

def compute_connectivity_matrix(timeseries_matrix):
    """
    Compute correlation matrix from time series

    Parameters:
    -----------
    timeseries_matrix : numpy array
        Shape: [n_timepoints, n_rois]

    Returns:
    --------
    corr_matrix : numpy array
        Correlation matrix [n_rois, n_rois]
    """
    # Compute Pearson correlation
    n_rois = timeseries_matrix.shape[1]
    corr_matrix = np.corrcoef(timeseries_matrix.T)

    return corr_matrix

def fisher_z_transform(corr_matrix):
    """
    Apply Fisher Z-transformation to correlation matrix

    Transforms correlations to approximately normal distribution
    Better for statistical analysis
    """
    # Avoid divide by zero and out of range
    corr_matrix = np.clip(corr_matrix, -0.9999, 0.9999)

    z_matrix = np.arctanh(corr_matrix)

    return z_matrix

def plot_connectivity_matrix(matrix, roi_names, title, output_file):
    """
    Visualize connectivity matrix
    """
    plt.figure(figsize=(12, 10))

    # Create mask for upper triangle (since matrix is symmetric)
    mask = np.triu(np.ones_like(matrix, dtype=bool), k=1)

    sns.heatmap(matrix,
                mask=mask,
                annot=True,
                fmt='.2f',
                cmap='RdBu_r',
                center=0,
                vmin=-1, vmax=1,
                xticklabels=roi_names,
                yticklabels=roi_names,
                square=True,
                cbar_kws={'label': 'Correlation (r)'})

    plt.title(title, fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

def main():
    print("="*50)
    print("STAGE 5: CONNECTIVITY MATRIX COMPUTATION")
    print("="*50)
    print()

    # Create output directories
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/individual", exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/plots", exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/summary", exist_ok=True)

    # Load extraction summary
    summary_file = f"{TIMESERIES_DIR}/summary/extraction_summary.csv"
    if not os.path.exists(summary_file):
        print(f"ERROR: Summary file not found: {summary_file}")
        return

    summary_df = pd.read_csv(summary_file)
    print(f"Found {len(summary_df)} subjects with extracted time series")
    print()

    # Process each subject
    connectivity_results = []

    for idx, row in summary_df.iterrows():
        subject_id = row['subject_id']
        age = row['age_months']
        sex = row['sex']
        site = row['site']

        print(f"Processing: {subject_id} (age: {age}mo, sex: {sex})")

        # Load time series matrix
        ts_file = f"{TIMESERIES_DIR}/individual_rois/{subject_id}_all_rois.txt"
        roi_names_file = f"{TIMESERIES_DIR}/individual_rois/{subject_id}_roi_names.txt"

        if not os.path.exists(ts_file):
            print(f"  WARNING: Time series file not found")
            continue

        # Load data
        timeseries = np.loadtxt(ts_file)

        # Load ROI names
        with open(roi_names_file, 'r') as f:
            roi_names = [line.strip() for line in f.readlines()]

        print(f"  Shape: {timeseries.shape}")
        print(f"  ROIs: {len(roi_names)}")

        # Compute connectivity matrix
        corr_matrix = compute_connectivity_matrix(timeseries)
        z_matrix = fisher_z_transform(corr_matrix)

        # Save matrices
        np.save(f"{OUTPUT_DIR}/individual/{subject_id}_corr.npy", corr_matrix)
        np.save(f"{OUTPUT_DIR}/individual/{subject_id}_fisher_z.npy", z_matrix)

        # Save as CSV for easy viewing
        corr_df = pd.DataFrame(corr_matrix,
                              index=roi_names,
                              columns=roi_names)
        corr_df.to_csv(f"{OUTPUT_DIR}/individual/{subject_id}_corr.csv")

        # Plot connectivity matrix
        plot_connectivity_matrix(
            corr_matrix,
            roi_names,
            f"{subject_id} - Vocalization Network Connectivity\nAge: {age}mo, Sex: {sex}",
            f"{OUTPUT_DIR}/plots/{subject_id}_connectivity.png"
        )

        print(f"  [OK] Connectivity computed and saved")

        # Extract summary statistics
        # Get upper triangle (excluding diagonal)
        triu_indices = np.triu_indices_from(corr_matrix, k=1)
        upper_triangle = corr_matrix[triu_indices]

        connectivity_results.append({
            'subject_id': subject_id,
            'age_months': age,
            'sex': sex,
            'site': site,
            'mean_connectivity': np.mean(upper_triangle),
            'std_connectivity': np.std(upper_triangle),
            'median_connectivity': np.median(upper_triangle),
            'max_connectivity': np.max(upper_triangle),
            'min_connectivity': np.min(upper_triangle),
            'n_rois': len(roi_names)
        })

        print()

    # Save summary
    if len(connectivity_results) > 0:
        results_df = pd.DataFrame(connectivity_results)
        results_df = results_df.sort_values('age_months')
        results_df.to_csv(f"{OUTPUT_DIR}/summary/connectivity_summary.csv", index=False)

        print("="*50)
        print("CONNECTIVITY COMPUTATION COMPLETE")
        print("="*50)
        print()
        print(f"Processed {len(results_df)} subjects")
        print()
        print("Summary statistics:")
        print(results_df.describe())
        print()
        print(f"Output directory: {OUTPUT_DIR}")
        print(f"  - individual/: Per-subject connectivity matrices")
        print(f"  - plots/: Connectivity matrix visualizations")
        print(f"  - summary/: Summary statistics")
        print()
    else:
        print("ERROR: No connectivity matrices computed")

if __name__ == "__main__":
    main()
