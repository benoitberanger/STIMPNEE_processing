clear
clc

modeldir     = 'ANOVA_Factorial_electrophyGlobal_Grip_Derivatives';
inputdir     = 'electrophyGlobal';
contrastname = 'con_0004.nii';

tools.second_level.main( modeldir, inputdir, contrastname )
