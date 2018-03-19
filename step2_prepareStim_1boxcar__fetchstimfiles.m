clear
clc

load e

stim_dir = fullfile(pwd,'stim');

e.getSerie('run_nm_001').addStim(stim_dir,'MRI_1.mat$'    ,'run_1_mat',1)
e.getSerie('run_nm_002').addStim(stim_dir,'MRI_2.mat$'    ,'run_2_mat',1)
e.getSerie('run_nm_001').addStim(stim_dir,'MRI_1_SPM.mat$','run_1_SPM',1)
e.getSerie('run_nm_002').addStim(stim_dir,'MRI_2_SPM.mat$','run_2_SPM',1)

save e e
