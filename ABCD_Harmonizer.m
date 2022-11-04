function ABCD_Harmonizer(varargin)

    persistent curpth F tdir ImFeat ImFeats Base featlist selected_inst loaded_inst ComBatTable RawTable

    if nargin == 0
        parpool;
        selector = 0;
        S  = get(0,'ScreenSize');
        curpth = path;
        runpth = fileparts(which('ABCD_Harmonizer'));
        addpath(fullfile(runpth,'ComBatHarmonization-master','Matlab','scripts'))
        addpath(fullfile(runpth,'ShowBrainSurf'))
        
        % Define instrument and features for parsing
        ImFeats.List = {...
            'sMRI';...
            'sMRI, Destrieux parcellation';...
            'dMRI';...
            'dMRI, Destrieux parcellation';...
            'dMRI Full-Shell';...
            'dMRI Full-Shell, Destrieux parcellation';...
            'dMRI RSI'};
        ImFeats.FileNames = {...
            {'abcd_smrip10201.txt','abcd_smrip20201.txt','abcd_smrip30201.txt'};...
            {'abcd_mrisdp10201.txt','abcd_mrisdp20201.txt','abcd_mrisdp30201.txt'};...
            {'abcd_dti_p101.txt','abcd_dti_p201.txt'};...
            {'abcd_ddtidp101.txt','abcd_ddtidp201.txt'};...
            {'abcd_dmdtifp101.txt','abcd_dmdtifp201.txt'};...
            {'abcd_ddtifp101.txt','abcd_ddtifp201.txt'};...
            {'abcd_drsip101.txt','abcd_drsip201.txt','abcd_drsip301.txt','abcd_drsip401.txt','abcd_drsip501.txt','abcd_drsip601.txt','abcd_drsip701.txt'}};
        ImFeats.FeatureSets = {...
            ["Cortical Thickness, APARC","Sulcal Depth, APARC","Cortical Area, APARC","Cortical Volume, APARC",...
            "White Matter T1 intensity, APARC","Gray Matter T1 intensity, APARC","T1 cortical contrast, APARC",...
            "White Matter T2 intensity, APARC","Gray Matter T2 intensity, APARC","T2 cortical contrast, APARC",...
            "Volume, ASEG","T1 intensity, ASEG","T2 intensity ASEG",...
            "Cortical Thickness, genetic parcellation","Sulcal Depth, genetic parcellation","Cortical Area, genetic parcellation","Cortical Volume, genetic parcellation",...
            "White Matter T1 intensity, genetic parcellation","Gray Matter T1 intensity, genetic parcellation","T1 cortical contrast, genetic parcellation",...
            "White Matter T2 intensity, genetic parcellation","Gray Matter T2 intensity, genetic parcellation","T2 cortical contrast, genetic parcellation"];...
            ["Cortical Thickness","Sulcal Depth","Cortical Area","Cortical Volume",...
            "White Matter T1 intensity","Gray Matter T1 intensity","T1 cortical contrast",...
            "White Matter T2 intensity","Gray Matter T2 intensity","T2 cortical contrast"];...
            ["FA, white matter tracts","MD, white matter tracts","LD, white matter tracts","TD, white matter tracts","Fiber tract volume (mm^3)",...
            "FA, ASEG","MD, ASEG","LD, ASEG","TD, ASEG",...
            "FA, sub-adjacent white matter, APARC","MD, sub-adjacent white matter, APARC","LD, sub-adjacent white matter, APARC","TD, sub-adjacent white matter, APARC",...
            "FA, cortical gray matter, APARC","MD, cortical gray matter, APARC","LD, cortical gray matter, APARC","TD, cortical gray matter, APARC",...
            "FA, gray/white contrast, APARC","MD, gray/white contrast, APARC","LD, gray/white contrast, APARC","TD, gray/white contrast, APARC"];...
            ["FA, white matter","MD, white matter","LD, white matter","TD, white matter",...
            "FA, gray matter","MD, gray matter","LD, gray matter","TD, gray matter",...
            "FA, gm-wm","MD, gm-wm","LD, gm-wm","TD, gm-wm"];...
            ["FA, white matter tracts","MD, white matter tracts","LD, white matter tracts","TD, white matter tracts","Fiber tract volume (mm^3)",...
            "FA, ASEG","MD, ASEG","LD, ASEG","TD, ASEG",...
            "FA, sub-adjacent white matter, APARC","MD, sub-adjacent white matter, APARC","LD, sub-adjacent white matter, APARC","TD, sub-adjacent white matter, APARC",...
            "FA, cortical gray matter, APARC","MD, cortical gray matter, APARC","LD, cortical gray matter, APARC","TD, cortical gray matter, APARC",...
            "FA, gray/white contrast, APARC","MD, gray/white contrast, APARC","LD, gray/white contrast, APARC","TD, gray/white contrast, APARC"];...
            ["FA, white matter","MD, white matter","LD, white matter","TD, white matter",...
            "FA, gray matter","MD, gray matter","LD, gray matter","TD, gray matter",...
            "FA, gm-wm","MD, gm-wm","LD, gm-wm","TD, gm-wm"];...
            ["Restricted normalized isotropic diffusion, AtlasTrack","Restricted normalized directional diffusion, AtlasTrack","Restricted normalized total diffusion, AtlasTrack","Free normalized isotropic diffusion, AtlasTrack",...
            "Restricted normalized isotropic diffusion, ASEG","Restricted normalized directional diffusion, ASEG","Restricted normalized total diffusion, ASEG","Free normalized isotropic diffusion, ASEG",...
            "Restricted normalized isotropic diffusion, peri-cortical WM Desikan","Restricted normalized directional diffusion, peri-cortical WM Desikan","Restricted normalized total diffusion, peri-cortical WM Desikan","Free normalized isotropic diffusion, peri-cortical WM Desikan",...
            "Restricted normalized isotropic diffusion, cortical GM Desikan","Restricted normalized directional diffusion, cortical GM Desikan","Restricted normalized total diffusion, cortical GM Desikan","Free normalized isotropic diffusion, cortical GM Desikan",...
            "Restricted normalized isotropic diffusion, GM-WM contrast Desikan","Restricted normalized directional diffusion, GM-WM contrast Desikan","Restricted normalized total diffusion, GM-WM contrast Desikan","Free normalized isotropic diffusion, GM-WM contrast Desikan",...
            "Restricted normalized isotropic diffusion, peri-cortical WM Destrieux","Restricted normalized directional diffusion, peri-cortical WM Destrieux","Restricted normalized total diffusion, peri-cortical WM Destrieux","Free normalized isotropic diffusion, peri-cortical WM Destrieux",...
            "Restricted normalized isotropic diffusion, cortical GM Destrieux","Restricted normalized directional diffusion, cortical GM Destrieux","Restricted normalized total diffusion, cortical GM Destrieux","Free normalized isotropic diffusion, cortical GM Destrieux",...
            "Restricted normalized isotropic diffusion, GM-WM contrast Destrieux","Restricted normalized directional diffusion, GM-WM contrast Destrieux","Restricted normalized total diffusion, GM-WM contrast Destrieux","Free normalized isotropic diffusion, GM-WM contrast Destrieux"]};
        ImFeats.FeatureStrings = {...
            ["thickness * APARC","depth * APARC","area * APARC","volume * APARC",...
            "T1 * of white * APARC","T1 * of gray * APARC","/2) of T1 * APARC",...
            "T2 * of white * APARC","T2 * of gray * APARC","/2) of T2 * APARC",...
            "Volume * ASEG","T1-weighted * ASEG","T2-weighted * ASEG"...
            "thickness * genetically","depth * genetically","area * genetically","volume * genetically",...
            "T1 * of white * genetically","T1 * of gray * genetically","/2) of T1 * genetically",...
            "T2 * of white * genetically","T2 * of gray * genetically","/2) of T2 * genetically"];...
            ["Cortical thickness","Sulcal depth","Cortical area","Cortical volume",...
            "Average T1 intensity of white matter voxels","Average T1 intensity of gray","/2) of T1",...
            "Average T2 intensity of white","Average T2 intensity of gray","/2) of T2"];...
            ["anisotropy * DTI atlas","Mean diffusivity * DTI atlas","longitudinal * DTI atlas","transverse * DTI atlas","Fiber tract volume",...
            "anisotropy * ASEG","Mean * ASEG","longitudinal * ASEG","transverse * ASEG",...
            "anisotropy, * white * cortical","Mean * white * cortical","longitudinal * white * cortical","transverse * white * cortical",...
            "anisotropy, * cortical gray * cortical","Mean * cortical gray * cortical","longitudinal * cortical gray * cortical","transverse * cortical gray * cortical",...
            "anisotropy, * matter-white * cortical","Mean * matter-white * cortical","longitudinal * matter-white * cortical","transverse * matter-white * cortical"];...
            ["anisotropy * of sub-adjacent white","Mean * of sub-adjacent white","longitudinal * of sub-adjacent white","transverse * of sub-adjacent white",...
            "anisotropy * of cortical gray","Mean * of cortical gray","longitudinal * of cortical gray","transverse * of cortical gray",...
            "anisotropy * matter-white","Mean * matter-white","longitudinal * matter-white","transverse * matter-white"];...
            ["anisotropy * DTI atlas","Mean diffusivity * DTI atlas","longitudinal * DTI atlas","transverse * DTI atlas","Fiber tract volume",...
            "anisotropy * ASEG","Mean * ASEG","longitudinal * ASEG","transverse * ASEG",...
            "anisotropy * white * cortical","Mean * white * cortical","longitudinal * white * cortical","transverse * white * cortical",...
            "anisotropy * cortical gray * cortical","Mean * cortical gray * cortical","longitudinal * cortical gray * cortical","transverse * cortical gray * cortical",...
            "anisotropy * matter-white * cortical","Mean * matter-white * cortical","longitudinal * matter-white * cortical","transverse * matter-white * cortical"];...
            ["anisotropy * of sub-adjacent white","Mean * of sub-adjacent white","longitudinal * of sub-adjacent white","transverse * of sub-adjacent white",...
            "anisotropy * of cortical gray","Mean * of cortical gray","longitudinal * of cortical gray","transverse * of cortical gray",...
            "anisotropy * matter-white","Mean * matter-white","longitudinal * matter-white","transverse * matter-white"];...
            ["restricted * isotropic * AtlasTrack","restricted * directional * AtlasTrack","restricted * total * AtlasTrack","Free * AtlasTrack",...
            "restricted * isotropic * aseg","restricted * directional * aseg","restricted * total * aseg","Free * aseg",...
            "restricted * isotropic * white * Desikan","restricted * directional * white * Desikan","restricted * total * white * Desikan","free * white * Desikan",...
            "restricted * isotropic * cortical * Desikan","restricted * directional * cortical * Desikan","restricted * total * cortical * Desikan","Free * cortical * Desikan",...
            "restricted * isotropic * contrast Desikan","restricted * directional * contrast Desikan","restricted * total * contrast Desikan","free * contrast Desikan",...
            "restricted * isotropic * white * Destrieux","restricted * directional * white * Destrieux","restricted * total * white * Destrieux","free * white * Destrieux",...
            "restricted * isotropic * cortical * Destrieux","restricted * directional * cortical * Destrieux","restricted * total * cortical * Destrieux","free * cortical * Destrieux",...
            "restricted * isotropic * contrast Destrieux","restricted * directional * contrast Destrieux","restricted * total * contrast Destrieux","free * contrast Destrieux"]};
        ImFeats.InclusionRec = {...
            [repmat("imgincl_t1w_include",1,7) repmat("imgincl_t2w_include",1,3) ...
            repmat("imgincl_t1w_include",1,10) repmat("imgincl_t2w_include",1,3)];...
            ["imgincl_t1w_include","imgincl_t1w_include","imgincl_t1w_include",...
            "imgincl_t1w_include","imgincl_t1w_include","imgincl_t1w_include","imgincl_t1w_include",...
            "imgincl_t2w_include","imgincl_t2w_include","imgincl_t2w_include"];...
            repmat("imgincl_dmri_include",1,length(ImFeats.FeatureSets{3}));...
            repmat("imgincl_dmri_include",1,length(ImFeats.FeatureSets{4}));...
            repmat("imgincl_dmri_include",1,length(ImFeats.FeatureSets{5}));...
            repmat("imgincl_dmri_include",1,length(ImFeats.FeatureSets{6}));...
            repmat("imgincl_dmri_include",1,length(ImFeats.FeatureSets{7}))};
        ImFeats.Visits = {'Baseline','2 year follow-up'};
    
        % Set initial Feature List
        featlist = ImFeats.FeatureSets{1};
        selected_inst = ImFeats.List{1}; 
        varlist = {'interview_age','sex','demo_comb_income_v2'};
    else
        selector = cell2mat(varargin);
    end

    clr1 = [1 170 199]./255;
    clr2 = 'k';%[132 198 66]./255;
    clr3 = 'w';%[1 85 99]./255;
%     clr4 = [143 69 106]./255;
    switch selector
        case 0 % Initialize variables and objects
            F = figure('IntegerHandle', 'off', ...
                'Name',sprintf('ABCD Harmonizer'), ...
                'NumberTitle','off',...
                'Tag','Froot',...
                'Units','pixels',...
                'Position',[S(3)/2-240 S(4)/2-250 480 535],...
                'Pointer','arrow',...
                'Color',clr1,... 
                'Resize','off',...
                'MenuBar','none',...
                'HandleVisibility','On',...
                'closerequestfcn','ABCD_Harmonizer(''exit'')',...
                'Visible','On');
            
            % Path to data directory
            uipanel('Units','pixels',...
                'Position', [4 460 472 65],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'FontSize',12,...
                'Title','1. Set path to ABCD Data Download',...
                'Visible','on',...
                'Parent',F);
            uicontrol('Style','edit',...
                'Tag','datapath',...
                'Units','pixels',...
                'Position', [8 470 360 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',12,...
                'String','',...
                'Visible','on',...
                'HorizontalAlignment','Center',...
                'Callback',@UpdatePath,...
                'Parent',F);
            uicontrol('Style','pushbutton',...
                'Units','pixels',...
                'Position',[372 470 100 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',12,...
                'String','Browse',...
                'Callback',@GetDataPath)

            % Imaging Instrument Selection
            uipanel('Units','pixels',...
                'Position', [4 275 472 175],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'FontSize',12,...
                'Title','2. Select Imaging Data',...
                'Visible','on',...
                'Parent',F);
            uicontrol('Style','text',...
                'String','Instrument',...
                'Position',[8 400 92 20],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'HorizontalAlignment','right',...
                'FontSize',12)
            uicontrol('Style','popupmenu',...
                'Tag','ImInst',...
                'Units','pixels',...
                'Position', [108 395 364 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',12,...
                'String',ImFeats.List,...
                'Visible','on',...
                'HorizontalAlignment','Center',...
                'CallBack',@GetFeatureList,...
                'Parent',F);
            uicontrol('Style','text',...
                'String','Feature set',...
                'Position',[8 360 92 20],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'HorizontalAlignment','right',...
                'FontSize',12)
            uicontrol('Style','popupmenu',...
                'Tag','InstFeats',...
                'Units','pixels',...
                'Position', [108 355 364 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',12,...
                'String',featlist,...
                'CallBack',@DisableSave,...
                'HorizontalAlignment','Center',...
                'Parent',F);
            uicontrol('Style','text',...
                'String','Visit',...
                'Position',[8 320 92 20],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'HorizontalAlignment','right',...
                'FontSize',12)
            uicontrol('Style','popupmenu',...
                'Tag','Visit',...
                'Units','pixels',...
                'Position', [108 315 364 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',12,...
                'String',ImFeats.Visits,...
                'CallBack',@DisableSave,...
                'HorizontalAlignment','Center',...
                'Parent',F);
            uicontrol('Style','checkbox',...
                'Tag','ImgInc',...
                'Position',[108 285 364 30],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'FontSize',12,...
                'String','Use ABCD image inclusion recommendations',...
                'CallBack',@DisableSave,...
                'Value',1,...
                'Parent',F)

            % Biological covariate selection
            uipanel('Units','pixels',...
                'Position', [4 85 472 180],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'FontSize',12,...
                'Title','3. Select Variance Preserved Covariates',...
                'Parent',F);
            uicontrol('Style','pushbutton',...
                'Units','Pixels',...
                'Position', [304 210 168 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',10,...
                'String','Add additional covariate(s)',...
                'HorizontalAlignment','Center',...
                'Callback',@AddCovariate,...
                'Parent',F);
            uicontrol('Style','listbox',...
                'Units','pixels',...
                'Tag','varlist',...
                'Position',[8 95 292 145],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',10,...
                'String',varlist,...
                'Max',inf,'Min',1,...
                'Value',1:length(varlist),...
                'CallBack',@DisableSave,...
                'HorizontalAlignment','center',...
                'Parent',F);
            
            % ComBat panel
            uipanel('Units','pixels',...
                'Position', [4 10 472 65],...
                'ForegroundColor',clr3,...
                'BackgroundColor',clr1,...
                'FontSize',12,...
                'Title','4. Run ComBat Harmonization',...
                'Visible','on',...
                'Parent',F);
            uicontrol('Style','pushbutton',...
                'Units','Pixels',...
                'Position', [8 20 152 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',10,...
                'String','Run ComBat',...
                'Visible','on',...
                'HorizontalAlignment','Center',...
                'Callback',@ComBat,...
                'Parent',F);
            uicontrol('Style','pushbutton',...
                'Units','Pixels',...
                'Tag','Save',...
                'Position', [164 20 152 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',10,...
                'String','Save Harmonized Data',...
                'Visible','on',...
                'HorizontalAlignment','Center',...
                'Enable','off',...
                'Callback',@SaveResults,...
                'Parent',F);
            uicontrol('Style','pushbutton',...
                'Units','Pixels',...
                'Tag','View',...
                'Position', [320 20 152 30],...
                'ForegroundColor',clr2,...
                'BackgroundColor',clr3,...
                'FontSize',10,...
                'String','View Results',...
                'Visible','on',...
                'HorizontalAlignment','Center',...
                'Enable','off',...
                'Callback',@ViewResults,...
                'Parent',F);
            



            %==============================================================
            % Menu Bars
            %==============================================================
            p1 = uimenu('Label', 'File','Parent', F);
%             uimenu(p1,'Label','Help','Callback','ABCD_Harmonizer(''help'')');            
%             uimenu(p1,'Label','Check for Updates','Callback','ABCD_Harmonizer(''Check for Updates'')');
            uimenu(p1,'Label','Exit','Callback','ABCD_Harmonizer(''exit'')');            

        
        case 'help'


        case 'exit' 
            path(curpth)
            delete(F)
            return
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Nested function to perform ComBat harmonization given GUI selections%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    function ComBat(~,~)


        inst = get(findobj(F,'tag','ImInst'),'Value');
        fset = get(findobj(F,'tag','InstFeats'),'Value');
        visit = ImFeats.Visits{get(findobj(F,'tag','Visit'),'Value')};
        inlist = fullfile(tdir,ImFeats.FileNames{inst});

        % Read in imaging data
        if ~isequal(selected_inst,loaded_inst)
            filecheck = cellfun(@(f) exist(f,'file'),inlist)==2;
            if ~all(filecheck)
                missing = inlist(~filecheck);
                warndlg([{'Can''t find the following files. Please check your data path.'},' ',missing])
                return
            end
            wb = waitbar(0,'Loading imaging instrument');
            wbch = allchild(wb);
            jp = wbch(1).JavaPeer;
            jp.setIndeterminate(1);
            
            ImFeat = abcd_read_instruments(inlist);
            ImFeat.Properties.VariableDescriptions = strrep(ImFeat.Properties.VariableDescriptions,'  ',' ');
            loaded_inst = selected_inst;
            close(wb);
        end
        
        % indices of imaging features belonging to selected feature set
        varn = ImFeat.Properties.VariableDescriptions;
        vstr = ImFeats.FeatureStrings{inst}(fset);
        feati = ~cellfun(@isempty,regexp(varn,regexptranslate('wildcard',vstr)));
        
        % Merge Base and Image Feature tables using outerjoin to ensure
        % correspondance of rows
        i = ismember(ImFeat.Properties.VariableNames,{'src_subject_id','eventname'}) | feati;
        T = outerjoin(Base,ImFeat(:,i),'MergeKeys',true);

        switch visit
            % Remove rows not belonging to selected visit
            case 'Baseline'
                T(~contains(T.eventname,'baseline_year_1_arm_1'),:) = [];
            case '2 year followup'
                T(~contains(T.eventname,'2_year_follow_up_y_arm_1'),:) = [];
        end

        % Exclude if not in ABCD image inclusion recommendations, if
        % selected in GUI
        ImgInc = get(findobj(F,'Tag','ImgInc'),'Value');
        if ImgInc
            T(T.(ImFeats.InclusionRec{inst}{fset})==0,:) = [];
        end
        
        % Trim and sort columns of T
        varn = T.Properties.VariableDescriptions;
        vstr = ImFeats.FeatureStrings{inst}(fset);
        feati = ~cellfun(@isempty,regexp(varn,regexptranslate('wildcard',vstr)));
        keepvar = varlist(get(findobj(F,'tag','varlist'),'Value')); % Variance preserved covariates
        allvars = [{'src_subject_id'} {'eventname'} keepvar...
            {'mri_info_deviceserialnumber'} T.Properties.VariableNames(feati)];
        col_ord = NaN(length(allvars),1);
        for i=1:length(col_ord)
            col_ord(i) = find(ismember(T.Properties.VariableNames,allvars{i}));
        end
        T = T(:,col_ord);

        mod = [];
        j = find(ismember(T.Properties.VariableNames,keepvar));
        rmvar = zeros(length(keepvar),1);
        for v=1:length(j)
            var = table2array(T(:,j(v)));
            if iscell(var)
                % Add code here to remove categorical variables with >2
                % levels
                switch length(unique(var))
                    case 1
                        warndlg({'Categorical variable with only one level detected:',...
                            ' ',keepvar{v},' ',...
                            'Ignoring this variable'})
                        rmvar(v) = 1;
                        continue
                    case 2
                        % do nothing
                    otherwise
                        warndlg({'Categorical variable with >2 levels detected:',...
                            ' ',keepvar{v},' ',...
                            'This is not currently supported for harmonization. This variable will be ignored'})
                        rmvar(v) = 1;
                        continue
                end
                mod = cat(2,mod,double(categorical(var)));
            else
                mod = cat(2,mod,var);
            end
        end
        set(findobj(F,'tag','varlist'),'Value',find(~rmvar));
        keepvar(rmvar==1) = [];
        varn = T.Properties.VariableDescriptions;
        vstr = ImFeats.FeatureStrings{inst}(fset);
        feati = ~cellfun(@isempty,regexp(varn,regexptranslate('wildcard',vstr)));
        rdata = table2array(T(:,feati));
        exc = any(isnan(rdata),2) | any(isnan(mod),2);
        T(exc,:) = [];
        rdata(exc,:) = [];
        mod(exc,:) = [];
        [~,~,batch] = unique(T.mri_info_deviceserialnumber,'stable');
        
        cdata = combat(rdata',batch',mod,1);
        i = ismember(T.Properties.VariableNames,[{'src_subject_id','eventname','mri_info_deviceserialnumber'} keepvar]) | feati;
        RawTable = T(:,i);
        ComBatTable = T(:,i);
        varn = ComBatTable.Properties.VariableDescriptions;
        vstr = ImFeats.FeatureStrings{inst}(fset);
        feati = ~cellfun(@isempty,regexp(varn,regexptranslate('wildcard',vstr)));
        ComBatTable(:,feati) = array2table(cdata');
        ComBatTable.Properties.VariableNames(feati) = cellfun(@(f) sprintf('%s_ComBatHarmonized',f),ComBatTable.Properties.VariableNames(feati),'Uni',0);
        set(findobj(F,'tag','Save'),'Enable','on')
        set(findobj(F,'tag','View'),'Enable','on')
        
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Nested function to add covariates from ABCD instruments to model    %
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    function AddCovariate(~,~)
        [covfl,covpath] = uigetfile('*.txt','Select instrument(s) containing additional covariate(s)',tdir,'MultiSelect','on');
        if ~ischar(covfl)
            return
        end
        temp = abcd_read_instruments(fullfile(covpath,covfl));
        temp(~contains(temp.eventname,{'baseline','2_year'}),:) = [];
        [sel,ok] = listdlg("PromptString",'Select covariate(s) to add to model','ListString',temp.Properties.VariableNames,...
            'ListSize',[400 600]);
        if ~ok
            return
        end
        sel(ismember(temp.Properties.VariableNames(sel),[{'src_subject_id'} {'eventname'} varlist])) = [];
        i = [find(ismember(temp.Properties.VariableNames,{'src_subject_id','eventname'})) sel];
        newval = get(findobj(F,'tag','varlist'),'Value');
        newval = cat(2,newval,length(varlist)+1:length(varlist)+length(sel));
        varlist = cat(2,varlist,temp.Properties.VariableNames(sel));
        set(findobj(F,'tag','varlist'),'String',varlist)
        set(findobj(F,'tag','varlist'),'Value',newval)
        Base = outerjoin(Base,temp(:,i),'MergeKeys',true);
        set(findobj(F,'tag','Save'),'Enable','off')
        set(findobj(F,'tag','View'),'Enable','off')
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Nested function to display results of ComBat harmonization          %
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    function ViewResults(~,~)
        inst = get(findobj(F,'tag','ImInst'),'Value');
        fset = get(findobj(F,'tag','InstFeats'),'Value');
        varn = ComBatTable.Properties.VariableDescriptions;
        vstr = ImFeats.FeatureStrings{inst}(fset);
        feati = ~cellfun(@isempty,regexp(varn,regexptranslate('wildcard',vstr)));
        [~,~,scn] = unique(ComBatTable.mri_info_deviceserialnumber,'stable');
        figure('Position',[100 100 1200 800],'Color','w','ToolBar','none');
        ax1 = subplot(321);
        boxplot(mean(table2array(RawTable(:,feati)),2),scn);
        xlabel('Scanner #')
        ylabel('Mean image feature value')
        title('Before ComBat Harmonization')
        ax1.XTick = 1:2:29;
        ax1.XTickLabel = strsplit(num2str(1:2:29));
        ax1.Position = [1/10 2/3 3/10 3/12];

        ax2 = subplot(322);
        boxplot(mean(table2array(ComBatTable(:,feati)),2),scn);
        xlabel('Scanner #')
        ylabel('Mean image feature value')
        title('After ComBat Harmonization')
        ax2.XTick = 1:2:29;
        ax2.XTickLabel = strsplit(num2str(1:2:29));
        ax2.Position = [6/10 2/3 3/10 3/12];

        
        
        j = ~ismember(ComBatTable.Properties.VariableNames,{'src_subject_id','eventname'}) & ~feati;
        jj = find(j);
        ii = find(feati);
        uvarexp = NaN(length(ii),length(jj)+1);
        cvarexp = NaN(length(ii),length(jj)+1);
        w = waitbar(0,'Calculating variance explained by covariate...');
        for m=1:length(jj)+1
            parfor n=1:length(ii)
                if m==1
                    cols = ii(n);
                else
                    cols = [jj(1):jj(m-1) ii(n)];
                end
                umdl = fitglm(RawTable(:,cols));
                uvarexp(n,m) = umdl.Rsquared.Ordinary;
                cmdl = fitglm(ComBatTable(:,cols));
                cvarexp(n,m) = cmdl.Rsquared.Ordinary;
            end
            waitbar(m/(length(jj)+1))
        end
        close(w);
        uvarexp = diff(uvarexp,1,2);
        cvarexp = diff(cvarexp,1,2);
        [~,o] = sort(sum(uvarexp,2),'descend');

        ax3 = subplot(323);
        bar(uvarexp(o,:),'stacked','EdgeColor','none')
        legend(strrep(RawTable.Properties.VariableNames(jj),'_','\_'))
        ylabel('Variance Explained')
        xlabel('Image Feature')
        title('Before ComBat Harmonization')
        ax3.Position = [1/10 1/3 3/10 3/12];


        ax4 = subplot(324);
        bar(cvarexp(o,:),'stacked','EdgeColor','none')
        ax4.YAxis.Limits(2) = 2*ax4.YAxis.Limits(2);
        legend(strrep(ComBatTable.Properties.VariableNames(jj),'_','\_'))
        ylabel('Variance Explained')
        xlabel('Image Feature')
        title('After ComBat Harmonization')
        ax4.Position = [6/10 1/3 3/10 3/12];
        
        sgtitle(sprintf('%s: %s',ImFeats.List{get(findobj(F,'tag','ImInst'),'Value')},ImFeats.FeatureSets{inst}(fset)))
        
        switch size(uvarexp,1)
            case {68,70,148}
                % APARC or Destrieux that showbrainsurf can handle
            case {71,151}
                % APARC or Destrieux with ABCD hemispheric and whole brain
                % mean values included at end
                uvarexp(end-2:end,:) = [];
            otherwise
                % Parcellation that showbrainsurf can't handle (e.g. ASEG)
                ax5 = subplot(325);
                ax5.Position = [1/10 0/20 8/10 3/12];
                ax5.Visible = 'off';
                text(.5,.5,'[Unable to map scanner variance by feature to cortical surface]',...
                    'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',12)
                return
        end
        ut = ceil(20*max(uvarexp(:,end)))/20;
        [LL,LM,RL,RM] = showbrainsurf(uvarexp(:,end),[0 ut]);
        close(gcf);
        ax5 = subplot(325);
        imshow([LL LM RM RL]);
        ax5.Position = [1/10 0/20 8/10 3/12];
        title('Variance Attributable to Scanner')
        cb = colorbar;
        cb.Ticks = linspace(0,1,2);
        cb.TickLabels = strsplit(num2str(linspace(0,ut,2)));
        colormap(hot)

    end


    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Minor nested functions                                              %
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    function GetDataPath(~,~)
        % Browse file system to select ABCD data download path. Update
        % string in GUI
        tdir = uigetdir;
        set(findobj(F,'tag','datapath'),'String',tdir)
        Base = abcd_read_instruments({fullfile(tdir,'pdem02.txt'),...
            fullfile(tdir,'abcd_imgincl01.txt'),...
            fullfile(tdir,'abcd_mri01.txt')});
        Base.demo_comb_income_v2(ismember(Base.demo_comb_income_v2,[777 999])) = NaN;
    end

    function UpdatePath(~,~)
        % Update data path variable based on user editing of string
        tdir = get(findobj(F,'tag','datapath'),'String');
    end

    function GetFeatureList(~,~)
        % Update list of selectable feature sets when imaging instrument is
        % changed (e.g. "Cortical Thickness" when an "sMRI" instrument is
        % selected)
        inst = get(findobj(F,'tag','ImInst'),'Value');
        selected_inst = ImFeats.List{inst};
        featlist = ImFeats.FeatureSets{inst};
        set(findobj(F,'tag','InstFeats'),'Value',1)
        set(findobj(F,'tag','InstFeats'),'String',featlist);
        set(findobj(F,'tag','Save'),'Enable','off')
        set(findobj(F,'tag','View'),'Enable','off')
    end

    function DisableSave(~,~)
        % Disable saving/viewing ComBat results
        set(findobj(F,'tag','Save'),'Enable','off')
        set(findobj(F,'tag','View'),'Enable','off')
    end

    function SaveResults(~,~)
        % Save harmonized data to a file
        inst = get(findobj(F,'tag','ImInst'),'Value');
        fset = get(findobj(F,'tag','InstFeats'),'Value');
        keepvar = varlist(get(findobj(F,'tag','varlist'),'Value'));
        defname = strrep(strrep(sprintf('%s_%s_%s_ComBatHarmonized_%s.csv',...
            ImFeats.List{get(findobj(F,'tag','ImInst'),'Value')},...
            ImFeats.FeatureSets{inst}(fset),...
            ImFeats.Visits{get(findobj(F,'tag','Visit'),'Value')},...
            strjoin(keepvar,'__')),',','-'),' ','');
        [filename,fpth] = uiputfile('*.csv','Save ComBat harmonized feature set as...',defname);
        if ~ischar(filename)
            return
        end
        writetable(ComBatTable,fullfile(fpth,filename))
    end


end