clear
clc

main_dir = pwd;

% get ROIs
dirROI  = '/mnt/data/benoit/protocol/STIMPNEE/fmri/roi';
fileROI = cellstr(char(gfile(dirROI,'nii$'))); fileROI = remove_regex(fileROI,'T1');
char(fileROI)

all_contrasts = {
    
'ppi'

};

for i = 1 : numel(fileROI)
    
    [~,nameROI] = spm_fileparts(fileROI{i});
    
    regressor_name = {'Belt', 'Grip'};
    
    for reg = 1 : length(regressor_name)
        
        inputdir     = sprintf('PPI_%s_%s',regressor_name{reg},nameROI);
        
        for c = 1 : length(all_contrasts)
            
            modeldir     = sprintf('PPI/%s',regexprep(all_contrasts{c},' ',''))
            contrastname = sprintf('con_%04d.nii',c)
            
            %%
            
            maindir = pwd;
            
            designdir = r_mkdir(fullfile(maindir,'Analyse_2ndlevel','PPI'),inputdir);
            
            imagepath = get_subdir_regex(maindir,'img');
            
            myScans = tools.rando;
            
            % procedure = 1 => yellow, procedure = 2 => blue
            
            lvl_11 = [];
            lvl_12 = [];
            lvl_21 = [];
            lvl_22 = [];
            
            for s = 1 : size(myScans,1)
                
                lvl  = cell2mat( myScans(s,[2 3]) );
                
                current_imagepath = get_subdir_regex(imagepath,myScans{s,1},'stat','electrophySpectralPower_phy',inputdir);
                
                current_contrastfile = get_subdir_regex_files(current_imagepath,contrastname);
                
                if isequal(lvl, [1 1])
                    lvl_11 = [ lvl_11 current_contrastfile ];
                elseif isequal(lvl, [1 2])
                    lvl_12 = [ lvl_12 current_contrastfile ];
                elseif isequal(lvl, [2 1])
                    lvl_21 = [ lvl_21 current_contrastfile ];
                elseif isequal(lvl, [2 2])
                    lvl_22 = [ lvl_22 current_contrastfile ];
                end
                
            end
            
            char(lvl_11), size(lvl_11)
            char(lvl_12), size(lvl_12)
            char(lvl_21), size(lvl_21)
            char(lvl_22), size(lvl_22)
            
            
            %% Fill the 2nd lvl design job
            
            %-----------------------------------------------------------------------
            % Job saved on 01-Dec-2016 16:23:13 by cfg_util (rev $Rev: 6460 $)
            % spm SPM - SPM12 (6685)
            % cfg_basicio BasicIO - Unknown
            %-----------------------------------------------------------------------
            job1{1}.spm.stats.factorial_design.dir = designdir;
            job1{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Procedure';
            job1{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
            job1{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Time';
            job1{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
            job1{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
            job1{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
            job1{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1 1];
            job1{1}.spm.stats.factorial_design.des.fd.icell(1).scans = lvl_11';
            job1{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1 2];
            job1{1}.spm.stats.factorial_design.des.fd.icell(2).scans = lvl_12';
            job1{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2 1];
            job1{1}.spm.stats.factorial_design.des.fd.icell(3).scans = lvl_21';
            job1{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2 2];
            job1{1}.spm.stats.factorial_design.des.fd.icell(4).scans = lvl_22';
            job1{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
            job1{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            job1{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            job1{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            job1{1}.spm.stats.factorial_design.masking.im = 1;
            job1{1}.spm.stats.factorial_design.masking.em = {''};
            job1{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            job1{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            job1{1}.spm.stats.factorial_design.globalm.glonorm = 1;
            
            
            spm('defaults', 'FMRI');
            
            % spm_jobman('interactive',job1);
            % spm('show');
            
            
            %% Prepare the job for estimation
            
            do_delete(designdir,0)
            mkdir(designdir{1})
            spm_jobman('run', job1);
            
            
            %% Estimate : Prepare
            
            fspm = get_subdir_regex_files( designdir , 'SPM.mat' , 1 );
            
            job2{1}.spm.stats.fmri_est.spmmat = fspm ;
            job2{1}.spm.stats.fmri_est.write_residuals = 0;
            job2{1}.spm.stats.fmri_est.method.Classical = 1;
            
            
            %% Estimate : Run
            
            spm_jobman('run', job2);
            
            
            %% Contraste
            
            contrast.names = {
                'P2_J5 > P1_J5';
                'P2_J1 > P1_J1';
                'P2_J5 - P2_J1'; % <--- img
                'P2_J1 - P2_J5';
                'P1_J5 > P2_J5';
                'P1_J1 > P2_J1';
                'P1_J5 - P1_J1'; % <--- img
                'P1_J1 - P1_J5';
                }';
            
            contrast.values = {
                [0 -1 0 1]
                [-1 0 1 0]
                [0 0 -1 1]
                [0 0 1 -1]
                
                [-1 0 1 0]
                [0 -1 0 1]
                [-1 1 0 0]
                [1 -1 0 0]
                }';
            
            contrast.types = cat(1,repmat({'T'},[1 length(contrast.names)]));
            par.delete_previous=0;
            par.run=1;
            
            
            %% Write contrasts
            
            job_first_level_contrast(fspm,contrast,par)
            
            
            %% Prepare display
            
            show{1}.spm.stats.results.spmmat = fspm;
            show{1}.spm.stats.results.conspec.titlestr = '';
            show{1}.spm.stats.results.conspec.contrasts = 1;
            show{1}.spm.stats.results.conspec.threshdesc = 'FWE'; % 'none' 'FWE' 'FDR'
            show{1}.spm.stats.results.conspec.thresh = 0.05;
            show{1}.spm.stats.results.conspec.extent = 10;
            show{1}.spm.stats.results.conspec.conjunction = 1;
            show{1}.spm.stats.results.conspec.mask.none = 1;
            show{1}.spm.stats.results.units = 1;
            show{1}.spm.stats.results.print = false;
            show{1}.spm.stats.results.write.none = 1;
            
            
            %% Display
            
            spm_jobman('run', show );
            
            cd(main_dir)
            
            
        end
        
    end % reg
    
end % roi

