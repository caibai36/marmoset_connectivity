#!/usr/bin/env python3

"""
STAGE 4: EXTRACT ROI TIME SERIES
=================================
Extracts mean time series from each vocalization network ROI
for each subject's resting-state fMRI data
"""

import os
import nibabel as nib
import numpy as np
import pandas as pd
from pathlib import Path
import glob

# Configuration
TEMPLATE_DATA_DIR = "./template_space_data"
ROI_DIR = f"{TEMPLATE_DATA_DIR}/roi_masks"
BOLD_DIR = f"{TEMPLATE_DATA_DIR}/registered_bold"
METADATA_FILE = f"{TEMPLATE_DATA_DIR}/metadata/subject_manifest.csv"
OUTPUT_DIR = "./roi_timeseries"

# ROI names (update based on Stage 1 output)
ROI_NAMES = [
    "bilateral_motor_cortex",
    "bilateral_prefrontal",
    "bilateral_auditory",
    "bilateral_cingulate",
    "bilateral_amygdala",
    "bilateral_thalamus",
    "bilateral_caudate",
    "bilateral_putamen",
    "bilateral_pallidum",
    "bilateral_accumbens"
]

def extract_roi_timeseries(bold_file, roi_mask_file):
    """
    Extract mean time series from ROI

    Parameters:
    -----------
    bold_file : str
        Path to 4D BOLD NIfTI file
    roi_mask_file : str
        Path to 3D ROI mask NIfTI file

    Returns:
    --------
    timeseries : numpy array
        Mean time series within ROI (shape: [n_timepoints,])
    """
    # Load data
    bold_img = nib.load(bold_file)
    bold_data = bold_img.get_fdata()

    roi_img = nib.load(roi_mask_file)
    roi_data = roi_img.get_fdata()

    # Ensure mask is binary
    roi_mask = roi_data > 0

    # Check if mask has any voxels
    nvoxels = np.sum(roi_mask)
    if nvoxels == 0:
        print(f"WARNING: ROI mask is empty for {os.path.basename(roi_mask_file)}")
        return None

    # Extract time series (mean across voxels in ROI)
    if bold_data.ndim == 4:
        # Reshape to [n_voxels, n_timepoints]
        n_timepoints = bold_data.shape[3]
        bold_2d = bold_data.reshape(-1, n_timepoints)

        # Get time series for voxels in ROI
        roi_timeseries = bold_2d[roi_mask.flatten(), :]

        # Compute mean
        mean_timeseries = np.mean(roi_timeseries, axis=0)

        print(f"  Extracted from {nvoxels} voxels, {n_timepoints} timepoints")
        return mean_timeseries
    else:
        print(f"ERROR: BOLD data has incorrect dimensions: {bold_data.shape}")
        return None

def main():
    print("="*50)
    print("STAGE 4: ROI TIME SERIES EXTRACTION")
    print("="*50)
    print()

    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/individual_rois", exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/summary", exist_ok=True)

    # Load metadata
    print("Loading subject metadata...")
    if os.path.exists(METADATA_FILE):
        metadata = pd.read_csv(METADATA_FILE)
        print(f"Found {len(metadata)} subjects")
    else:
        print(f"ERROR: Metadata file not found: {METADATA_FILE}")
        return

    print()

    # Get list of BOLD files
    bold_files = sorted(glob.glob(f"{BOLD_DIR}/*.nii.gz"))
    print(f"Found {len(bold_files)} BOLD files")
    print()

    # Process each BOLD file
    results_list = []

    for bold_file in bold_files:
        bold_basename = os.path.basename(bold_file)
        print(f"Processing: {bold_basename}")

        # Extract subject ID
        subject_id = bold_basename.split('_')[0]  # Assumes format: sub-XX_...
        print(f"  Subject: {subject_id}")

        # Get subject metadata
        subj_meta = metadata[metadata['subject_id'] == subject_id]
        if len(subj_meta) == 0:
            print(f"  WARNING: No metadata found for {subject_id}")
            continue

        age = subj_meta['age_months'].values[0]
        sex = subj_meta['sex'].values[0]
        site = subj_meta['site'].values[0]

        print(f"  Age: {age} months, Sex: {sex}, Site: {site}")

        # Extract time series for each ROI
        roi_timeseries_dict = {}

        for roi_name in ROI_NAMES:
            roi_file = f"{ROI_DIR}/{roi_name}.nii.gz"

            if not os.path.exists(roi_file):
                print(f"  WARNING: ROI mask not found: {roi_name}")
                continue

            print(f"  Extracting: {roi_name}")

            timeseries = extract_roi_timeseries(bold_file, roi_file)

            if timeseries is not None:
                roi_timeseries_dict[roi_name] = timeseries

                # Save individual ROI time series
                output_file = f"{OUTPUT_DIR}/individual_rois/{subject_id}_{roi_name}.txt"
                np.savetxt(output_file, timeseries)

        # Create combined time series matrix for this subject
        if len(roi_timeseries_dict) > 0:
            # Stack all ROI time series
            combined_ts = np.column_stack([roi_timeseries_dict[roi]
                                          for roi in sorted(roi_timeseries_dict.keys())])

            # Save combined matrix
            output_file = f"{OUTPUT_DIR}/individual_rois/{subject_id}_all_rois.txt"
            np.savetxt(output_file, combined_ts)

            # Create header
            header_file = f"{OUTPUT_DIR}/individual_rois/{subject_id}_roi_names.txt"
            with open(header_file, 'w') as f:
                for roi in sorted(roi_timeseries_dict.keys()):
                    f.write(f"{roi}\n")

            print(f"  [OK] Saved {len(roi_timeseries_dict)} ROI time series")

            # Record results
            results_list.append({
                'subject_id': subject_id,
                'bold_file': bold_basename,
                'age_months': age,
                'sex': sex,
                'site': site,
                'n_rois_extracted': len(roi_timeseries_dict),
                'n_timepoints': combined_ts.shape[0]
            })

        print()

    # Save summary
    if len(results_list) > 0:
        results_df = pd.DataFrame(results_list)
        results_df.to_csv(f"{OUTPUT_DIR}/summary/extraction_summary.csv", index=False)

        print("="*50)
        print("EXTRACTION COMPLETE")
        print("="*50)
        print()
        print(f"Processed {len(results_df)} BOLD files")
        print(f"Output directory: {OUTPUT_DIR}")
        print()
        print("Summary:")
        print(results_df)
        print()
        print(f"Summary saved to: {OUTPUT_DIR}/summary/extraction_summary.csv")
        print()
    else:
        print("ERROR: No time series extracted")

if __name__ == "__main__":
    main()
