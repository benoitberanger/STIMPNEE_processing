close all
clear
clc

load  /media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/stim/2016_11_28_STIMPNEE_Temoin08_V1_S2/temoin08_V1_S2_FullMRIrun_MRI_1.mat


mc = [10.6624 12.1235 6.9249 7.316 9.6466 7.3514 7.3514 8.4554 8.5766 6.4438];


%%

close all

rawdata = DataStruct.TaskData.RR.Data;
rawdata{1,4} = 0; % start time
rawdata{end,4} = 0; % stop time

rawsignal = cell2mat(rawdata(:,4));

% signal = rawsignal;
signal = rawsignal + abs(min(rawsignal));
% signal = abs(rawsignal);

% figure
% ax(1) = subplot(2,1,1);
% plot(rawsignal,'red')
% ax(2) = subplot(2,1,2);
% plot(signal,'blue')
% linkaxes(ax,'x')

block = {};

prev = '';

for i = 1 : size(rawdata,1)
    
    current = rawdata{i,1};
    
    if ~strcmp(current,prev)
        block = [ block ; {current i}];
    end
    prev = current;
    
end


%%


for b = 1 : size(block,1) - 1
    
    block{b,3} = trapz( signal( block{b,2} : block{b+1,2} ) )*1/60;

end

%% 

resp_idx = strcmp(block(:,1),'Respiration');

ben = cell2mat(block(resp_idx,3))


%%

figure

subplot(2,1,1)
plot(mc)
title('mc')

subplot(2,1,2)
plot(ben)
title('ben')
