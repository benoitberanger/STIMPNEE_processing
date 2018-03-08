clear
clc

load e

e.getSerie('run_nm_001').addStim('stim','MRI_1_SPM.mat$','run_1_SPM',1)
e.getSerie('run_nm_002').addStim('stim','MRI_2_SPM.mat$','run_2_SPM',1)


save e e
