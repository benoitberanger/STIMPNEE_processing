clear
clc

modeldir     = 'ANOVA_Factorial_electrophyGlobal_Belt';
inputdir     = 'electrophyGlobal';
contrastname = 'con_0001.nii';

tools.second_level.main( modeldir, inputdir, contrastname )
