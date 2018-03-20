clear
clc

modeldir     = 'ANOVA_Factorial_electrophyGlobal_Belt_Derivatives';
inputdir     = 'electrophyGlobal';
contrastname = 'con_0003.nii';

tools.second_level.main( modeldir, inputdir, contrastname )
