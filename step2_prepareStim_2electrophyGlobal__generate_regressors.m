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
    [ X_filtered_derivate ]     = tools.electrophy.derivate( X_filtered, freq );
    
    
    %% Specifique part
    
    U(1).u    = X_filtered(:,1);
    U(1).raw  = X_raw     (:,1);
    U(1).name = {'Belt'};
    
    U(2).u    = X_filtered(:,2);
    U(2).raw  = X_raw     (:,2);
    U(2).name = {'Grip'};
    
    
    U(3).u    = X_filtered_derivate(:,1);
    U(3).raw  = X_filtered(:,2);
    U(3).name = {'Diff_Belt'};
    
    U(4).u    = X_filtered_derivate(:,2);
    U(4).raw  = X_filtered(:,2);
    U(4).name = {'Diff_Grip'};
    
    
    %% Generate regressors
    
    [ R, names, X, X_reg ] = tools.electrophy.U2R( U, TR, freq, input_rp );
    
    
    %% Save
    
    dit_to_save = get_parent_path( input );
    output = fullfile(dit_to_save, sprintf('R_Global_%s.mat', input(end-4)) );
    
    fprintf('output : %s \n\n', output)
    
    save( output, 'R', 'names' )
    
    
    %% Plot
    
    %     figure
    %     plot(R)
    %
    %     for i = 1 : numel(U)
    %         figure('Name',U(i).name{1},'NumberTitle','off')
    %         hold on
    %         plot(Time,U(i).raw,'black')
    %         plot(Time,U(i).u,'blue')
    %         plot(Time,X(:,i),'magenta')
    %         plot((0:size(X_reg,1)-1)*TR,X_reg(:,i),'red')
    %     end
    
    
end % for each run
