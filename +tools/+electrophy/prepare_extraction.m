function [ TR, freq, stim_files_char, rp_files_char ] = prepare_extraction

load e

stim_dir = get_subdir_regex(fullfile(pwd,'stim'),{e.name})';

stim_files = get_subdir_regex_files(stim_dir,'MRI_\d.mat$')';
stim_files_char = char(stim_files);

rp_files = get_subdir_regex_files(sort(cellstr(e.getSerie('run_nm').print)),'^rp_.*.txt')';
rp_files_char = char(rp_files);

freq = 60;
TR = 1.520;

end % function
