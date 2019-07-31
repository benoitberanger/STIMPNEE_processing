clear
clc

load e

par.run     = 0;
par.display = 1;
par.sge     = 0;


%% get ROIs

dirROI  = '/mnt/data/benoit/protocol/STIMPNEE/fmri/roi';
fileROI = cellstr(char(gfile(dirROI,'nii$'))); fileROI = remove_regex(fileROI,'T1');
char(fileROI)


%% prepare job

% select models
models = e.getModel('electrophySpectralPower_phy').getPath;
nRun   = 2;


for j = 1 : length(models)
    
    for r = 1 : nRun
        
        for i = 1 : numel(fileROI)
            
            [~,nameROI] = spm_fileparts(fileROI{i});
            
            % Load deconvoved BOLD signal
            %--------------------------------------------------------------
            model_path  = fileparts(models{j});
            deconv_path = fullfile(model_path,sprintf('PPI_%s_run%d.mat',nameROI,r));
            DECONV      = load(deconv_path); DECONV = DECONV.PPI;
            xY          = DECONV.xY;
            
            % Load SPM.mat
            %--------------------------------------------------------------
            SPM    = load( models{j} ); SPM = SPM.SPM;
            RT      = SPM.xY.RT;
            dt      = SPM.xBF.dt;
            NT      = round(RT/dt);
            fMRI_T0 = SPM.xBF.T0;
            N       = length(xY(1).u);
            k       = 1:NT:N*NT;       % microtime to scan time indices
            hrf     = spm_hrf(dt);
            
            
            % Generate PPI.Y, PPI.P, PPI.ppi
            %--------------------------------------------------------------
            PPI             = struct;
            PPI.model_path  = model_path;
            PPI.deconv_path = deconv_path;
            PPI.iRun        = r;
            PPI.nameROI     = nameROI;
            Y = [];
            
            % Y ===========================================================
            
            % Get confounds (in scan time) and constant term
            %--------------------------------------------------------------
            X0 = xY(1).X0;
            
            % Get response variable
            %--------------------------------------------------------------
            for i = 1:size(xY,2)
                Y(:,i) = xY(i).u;
            end
            
            % Remove confounds and save Y in ouput structure
            %--------------------------------------------------------------
            Yc    = Y - X0*inv(X0'*X0)*X0'*Y; %#ok<MINV>
            PPI.Y = Yc(:,1);
            %             if size(Y,2) == 2
            %                 PPI.P = Yc(:,2);
            %             end
            
            % Get scan index for run "r" in the model
            run_column = strcmp(SPM.xX.name,sprintf('Sn(%d) constant',r));
            assert( any(run_column)    ) % just to be sure
            assert( sum(run_column)==1 ) % just to be sure
            run_scan_idx = logical(SPM.xX.X(:,run_column));
            
            regressor_name = {'Belt', 'Grip'};
            
            for reg = 1 : length(regressor_name)
                
                PPI.reg_name = regressor_name{reg};
                
                reg_name   = sprintf('Sn(%d) %s',r,regressor_name{reg});
                reg_column = strcmp(SPM.xX.name,reg_name);
                assert( any(reg_column)    ) % just to be sure
                assert( sum(reg_column)==1 ) % just to be sure
                reg_timeserie = SPM.xX.X(run_scan_idx,reg_column);
                
                % P ===========================================================
                PPI.P = reg_timeserie;
                
                % ppi =========================================================
                PPI.ppi = PPI.Y .* PPI.P;
                PPI.ppi = spm_detrend(PPI.ppi);
                
                fname = fullfile(model_path,sprintf('modelPPI_%s_%s_run%d.mat',regressor_name{reg},nameROI,r));
                fprintf('Writing %s \n',fname)
                save(fname,'PPI')
                
            end
            
        end
        
    end
    
end

