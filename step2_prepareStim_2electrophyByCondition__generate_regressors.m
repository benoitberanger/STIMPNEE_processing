%% Init

clear
% close all
clc

% Fetch files and infos
[ TR, freq, stim_files_char, rp_files_char ] = tools.electrophy.prepare_extraction;


%%  Loop

for idx = 1 : size(stim_files_char,1)
    %% Prepare run data
    
    input    = deblank(stim_files_char(idx,:));
    input_rp = deblank(rp_files_char  (idx,:));
    
    fprintf('input : %s \n', input)
    
    [ X_raw, X_filtered, Time ] = tools.electrophy.filter( input, freq );
    
    %% Specifique part
    
    
    
    
    [ R, names ] = tools.electrophy.U2R( U, TR, freq, input_rp );
    
    
    %% Save
    
    dit_to_save = get_parent_path( input );
    output = fullfile(dit_to_save, sprintf('R_Global_%s.mat', input(end-4)) );
    
    fprintf('output : %s \n\n', output)
    
    save( output, 'R', 'names' )
    
    
    %% Plot
    
    %     figure
    %     plot(R(:,1:4))
    %
    %     for i = 1 : 4
    %         figure
    %         hold on
    %         plot(Time,U(i).raw,'black')
    %         plot(Time,U(i).u,'blue')
    %         plot(Time,X(:,i),'magenta')
    %         plot((0:size(X_reg,1)-1)*TR,X_reg(:,i),'red')
    %     end
    
    
end % for each run
