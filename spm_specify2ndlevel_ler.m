function spm_specify2ndlevel_ler(stats_dir, input)

spm('defaults','fmri');
spm_jobman('initcfg');
second_level = struct;
spm_size = size(input);
n_sub = spm_size(2);
fcon={};
for i = 1:n_sub
    fcon{i} = input(i).con1;
end

% SETUP BATCH JOB STRUCTURE
second_level.matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};
second_level.matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = fcon';
second_level.matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
second_level.matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
second_level.matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
second_level.matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
second_level.matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
second_level.matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
second_level.matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
second_level.matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% RUN BATCH JOB
spm_jobman('run',second_level.matlabbatch);
