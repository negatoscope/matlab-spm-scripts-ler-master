function output = spm_normalize_ler(functional4D_fn, structural_fn, fwhm, spm_dir, input)
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
%[d1, f1, e1] = fileparts(functional4D_fn);
%rfunctional4D_fn = [d1 filesep 'r' f1 e1];
f4D_spm = spm_vol(functional4D_fn);
spm_size = size(f4D_spm);
Nt = spm_size(1);
% Declare output structure
% output = input;

% STEP 5 -- Normalize (estimate and reslice) functionals to MNI
disp('Step 5 -- Normalize (estimate and reslice) functionals to MNI');
spm('defaults','fmri');
spm_jobman('initcfg');
normalize = struct;
% Data
fnorm={};
for i = 1:Nt
    fnorm{i} = [input.rfunctional_fn ',' num2str(i) ];
end

%[d, f, e] = fileparts(structural_fn);
%ranat = [d filesep 'r' f e];
%rstructural = spm_vol(ranat);
[d1, f1, e1] = fileparts(input.rfunctional_fn);
%rfunctional4D_fn = [d1 filesep 'r' f1 e1];

normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {input.rstructural_fn};
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = fnorm';
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {[spm_dir filesep 'tpm' filesep 'TPM.nii']};
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
normalize.matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

% Run
spm_jobman('run',normalize.matlabbatch);
input.wrfunctional_fn = [d1 filesep 'w' f1 e1];
disp('Step 5 - Done!');
