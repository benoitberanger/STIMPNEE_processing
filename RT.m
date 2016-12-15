close all
clear
clc

Run{1} = load('/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/stim/2016_11_28_STIMPNEE_Temoin08_V1_S2/temoin08_V1_S2_FullMRIrun_MRI_1.mat');
Run{2} = load('/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/stim/2016_11_28_STIMPNEE_Temoin08_V1_S2/temoin08_V1_S2_FullMRIrun_MRI_2.mat');
Names = {'Force','Respiration'};


for r = 1 : length(Run)
    
    %% Make blocks
    
    rawdata = Run{r}.DataStruct.TaskData.RR.Data;
    rawdata{1,8} = Run{r}.DataStruct.TaskData.Cursor.V.NULL; % start time
    rawdata{end,8} = Run{r}.DataStruct.TaskData.Cursor.V.NULL; % stop time
    
    
    rawsignal = cell2mat(rawdata(:,8));
    
    % signal = rawsignal;
    signal = (rawsignal - Run{r}.DataStruct.TaskData.Cursor.V.NULL) * (-1);
    signal = signal/Run{r}.DataStruct.PTB.WindowRect(4) * (1/0.7);
    
    figure
    ax(1) = subplot(2,1,1);
    plot(rawsignal,'red')
    ax(2) = subplot(2,1,2);
    plot(signal,'blue')
    linkaxes(ax,'x')
    
    block = {};
    
    prev = '';
    
    for i = 1 : size(rawdata,1)
        
        current = rawdata{i,1};
        
        if ~strcmp(current,prev)
            block = [ block ; {current i}];
        end
        prev = current;
        
    end
    
    
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
    
    for n = 1 : length(Names)
        
        sz = [];
        for p = 1 : length(segments.(Names{n}))
            
            sz(p) = length(segments.(Names{n}){p});
            
        end
        min_sz = min(sz);
        cond.(Names{n}) = nan(p,min_sz);
        
        for p = 1 : length(segments.(Names{n}))
            
            cond.(Names{n})(p,:) = segments.(Names{n}){p}(1:min_sz);
            
        end
        
    end
    
    cond
    
    
    %% Plot
    
    
    
    for n = 1 : length(Names)
        
        figure
        hold all
        title(Names{n})
        
        for p = 1 : size( cond.(Names{n}) , 1 )
            plot(cond.(Names{n})(p,:))
        end
        plot( mean( cond.(Names{n}) , 1 ) ,'Color','Black','LineWidth',3)
        
        axis tight
        
    end
    
end