function output = spm_smooth_ler(functional4D_fn, structural_fn, fwhm, spm_dir, input)
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
% output = struct;

% Step 6 -- Gaussian kernel smoothing of realigned data
disp('Step 6 -- Gaussian kernel smoothing of realigned data');
spm('defaults','fmri');
spm_jobman('initcfg');
smooth = struct;
% Data
fns={};
for i = 1:Nt
    fns{i} = [input.wrfunctional_fn ',' num2str(i) ];
end
smooth.matlabbatch{1}.spm.spatial.smooth.data = fns';
% Other
smooth.matlabbatch{1}.spm.spatial.smooth.fwhm = [fwhm fwhm fwhm];
smooth.matlabbatch{1}.spm.spatial.smooth.dtype = 0;
smooth.matlabbatch{1}.spm.spatial.smooth.im = 0;
smooth.matlabbatch{1}.spm.spatial.smooth.prefix = 's';
% Run
spm_jobman('run',smooth.matlabbatch);
[d, f, e] = fileparts(input.wrfunctional_fn);
input.swrfunctional_fn = [d filesep 's' f e];
disp('Step 6 - done!');
