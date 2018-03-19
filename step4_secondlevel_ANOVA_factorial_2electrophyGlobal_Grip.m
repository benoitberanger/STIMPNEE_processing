clear
clc

modeldir     = 'ANOVA_Factorial_electrophyGlobal_Grip';
inputdir     = 'electrophyGlobal';
contrastname = 'con_0002.nii';

tools.second_level.main( modeldir, inputdir, contrastname )
