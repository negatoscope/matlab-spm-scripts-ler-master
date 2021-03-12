function output = spm_standardPreproc_jsh(functional4D_fn, structural_fn, fwhm, spm_dir)
% Function to complete preprocessing of structural and functional data from
% a single subject for use in any other Matlab/SPM12 script.

% Steps include coregistering structural image to first functional image,
% segmenting the coregistered structural image into tissue types, and
% reslicing the segments to the functional resolution image grid. 
% Makes use of spm12 batch routines. If spm12 batch parameters are not
% explicitly set, defaults are assumed. 
%
% INPUT:
% funcional4D_fn     - filename of pre-real-time functional scan
% structural_fn      - filename of T1-weighted structural scan
% fwhm               - kernel size for smoothing operations
% spm_dir            - SPM12 directory location
% 
% OUTPUT: 
% output            - structure with filenames and data
%__________________________________________________________________________
% Copyright (C) Stephan Heunis 2018

% Load data
f4D_spm = spm_vol(functional4D_fn);
spm_size = size(f4D_spm);
Nt = spm_size(1);
% Declare output structure
output = struct;

% STEP 2 -- Coregister structural image to first dynamic image (estimate only)
disp('Step 2 -- Coregister structural image to first dynamic image');
spm('defaults','fmri');
spm_jobman('initcfg');
coreg_estimate = struct;
% Ref
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.ref = {[functional4D_fn ',1']};
% Source
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.source = {structural_fn};
% Eoptions
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% Run
spm_jobman('run',coreg_estimate.matlabbatch);
disp('Step 2 - Done!');

