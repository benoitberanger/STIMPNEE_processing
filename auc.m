close all
clear
clc

Run{1} = load('/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/stim/2016_11_28_STIMPNEE_Temoin08_V1_S2/temoin08_V1_S2_FullMRIrun_MRI_1.mat');
Run{2} = load('/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/stim/2016_11_28_STIMPNEE_Temoin08_V1_S2/temoin08_V1_S2_FullMRIrun_MRI_2.mat');

mc{1} = [10.6624 12.1235 6.9249 7.3160 9.6466 7.3514 7.3514  8.4554  8.5766 6.4438];
mc{2} = [10.2907  9.2822 8.3551 8.0659 9.0027 7.2897 7.2897 10.1970 10.1970 8.6923];

for r = 1 : length(Run)
    
    %% Make blocks
    
    rawdata = Run{r}.DataStruct.TaskData.RR.Data;
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
    
    colorBlock.StartTime = nan(size(signal));
    colorBlock.StopTime = nan(size(signal));
    colorBlock.NULL = nan(size(signal));
    colorBlock.Force = nan(size(signal));
    colorBlock.Respiration = nan(size(signal));
    colorBlock.Eye = nan(size(signal));
    
    for b = 1 : size(block,1) - 1
        colorBlock.(block{b,1})( block{b,2} : block{b+1,2} ) = signal( block{b,2} : block{b+1,2} );
    end
    
    figure('Name','colorBlock','NumberTitle','off')
    hold all
    for n = 1 : length(Run{r}.names)
        plot(colorBlock.(Run{r}.names{n}),'DisplayName',Run{r}.names{n})
    end
    legend('show')
    
    
    %% AUC
    
    
    for b = 1 : size(block,1) - 1
        
        block{b,3} = trapz( signal( block{b,2} : block{b+1,2}-1 ) )*1/60;
        
    end
    
    %% Select respiration AUC
    
    resp_idx = strcmp(block(:,1),'Respiration');
    
    ben = cell2mat(block(resp_idx,3))
    
    
    %% Plot AUC for respiration
    
    figure('Name','AUC','NumberTitle','off')
    
    subplot(2,1,1)
    plot(mc{r})
    title('mc')
    
    subplot(2,1,2)
    plot(ben)
    title('ben')

    
    %% Segement
    
    segments.StartTime = {};
    segments.StopTime = {};
    segments.NULL = {};
    segments.Force = {};
    segments.Respiration = {};
    segments.Eye = {};
    
    for b = 1 : size(block,1) - 1
        
        segments.(block{b,1}) = [ segments.(block{b,1}) ; signal( block{b,2} : block{b+1,2}-1 )' ];
        
    end
    
    segments
    
    %% Reshape
    
    cond = struct;
    
    for n = 1 : length(Run{r}.names)
        
        sz = [];
        for p = 1 : length(segments.(Run{r}.names{n}))
            
            sz(p) = length(segments.(Run{r}.names{n}){p});
            
        end
        min_sz = min(sz);
        cond.(Run{r}.names{n}) = nan(p,min_sz);
        
        for p = 1 : length(segments.(Run{r}.names{n}))
            
            cond.(Run{r}.names{n})(p,:) = segments.(Run{r}.names{n}){p}(1:min_sz);
            
        end
        
    end
    
    cond
    
    
    %% Plot
    
    
    
    for n = 1 : length(Run{r}.names)
        
        figure('Name',Run{r}.names{n},'NumberTitle','off')
        hold all
        
        for p = 1 : size( cond.(Run{r}.names{n}) , 1 )
            plot(cond.(Run{r}.names{n})(p,:))
        end
        plot( mean( cond.(Run{r}.names{n}) , 1 ) ,'Color','Black','LineWidth',3)
        
        axis tight
        
    end
    
end
