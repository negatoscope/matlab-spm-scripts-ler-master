function output = spm_reslice_ler(functional4D_fn, structural_fn, fwhm, spm_dir)
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
% output = input;
[d, f, e] = fileparts(structural_fn);

% STEP 4 -- Reslice all to functional-resolution image grid
disp('Step 4 -- Reslice all to functional-resolution image grid');
spm('defaults','fmri');
spm_jobman('initcfg');
reslice = struct;
% Ref
reslice.matlabbatch{1}.spm.spatial.coreg.write.ref = {[functional4D_fn ',1']};
% Source
source_fns = {};
for i = 1:6
    source_fns{i} = [d filesep 'c' num2str(i) f e];
end
source_fns{7} = structural_fn;
reslice.matlabbatch{1}.spm.spatial.coreg.write.source = source_fns';
% Roptions
reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
reslice.matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
% Run
spm_jobman('run',reslice.matlabbatch);
% Save filenames
[d, f, e] = fileparts(structural_fn);
output.rstructural_fn = [d filesep 'r' f e];
output.rgm_fn = [d filesep 'rc1' f e];
output.rwm_fn = [d filesep 'rc2' f e];
output.rcsf_fn = [d filesep 'rc3' f e];
output.rbone_fn = [d filesep 'rc4' f e];
output.rsoft_fn = [d filesep 'rc5' f e];
output.rair_fn = [d filesep 'rc6' f e];
disp('Step 4 - done!');
