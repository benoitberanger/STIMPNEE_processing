clear
clc

main_dir = pwd;

all_contrasts = {
    
'NULL'
'Force'
'Resp'
'Eye'
'Belt'
'Grip'
'BeltD'
'GripD'

'NULL  + Belt'
'Force + Belt'
'Resp  + Belt'
'Eye   + Belt'

'Force + Grip'

};

inputdir     = 'electrophySpectralPower';

for c = 1 : length(all_contrasts)
    
    modeldir     = sprintf('ANOVA_Factorial_electrophySpectralPower/%s',regexprep(all_contrasts{c},' ',''))
    contrastname = sprintf('con_%04d.nii',c)
    
    tools.second_level.main( modeldir, inputdir, contrastname )
    
    cd(main_dir)
    
end
