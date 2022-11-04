function instrument = abcd_read_instruments(inputs,timepoint)
    if ~exist('timepoint','var')
        timepoint = 'all';
    end
    if ~ismember(timepoint,{'all','baseline','baseline_year_1_arm_1',...
            'year1','1_year_follow_up_y_arm_1',...
            'year2','2_year_follow_up_y_arm_1',...
            'year3','3_year_follow_up_y_arm_1'})
        fprintf(2,'Specified timepoint not recognized: %s\n',timepoint)
        instrument = [];
        return
    end
    if ischar(inputs) || isstring(inputs)
        inputs = {inputs};
    end

    for n=1:length(inputs)
        opts = detectImportOptions(inputs{n});
        opts.VariableDescriptionsLine = 2;
        temp = readtable(inputs{n},opts);
        % remove unnecessary variables
        temp.collection_id = [];
        temp.collection_title = [];
        temp.study_cohort_name = [];
        temp.dataset_id = [];
        [~,ivn,~] = fileparts(inputs{n});
        temp.([ivn '_id']) = [];
        temp(:,contains(temp.Properties.VariableNames,'_visitid')) = [];
    
        switch timepoint
            case {'baseline','baseline_year_1_arm_1'}
                temp = temp(ismember(temp.eventname,'baseline_year_1_arm_1'),:);
            case {'year1','1_year_follow_up_y_arm_1'}
                temp = temp(ismember(temp.eventname,'1_year_follow_up_y_arm_1'),:);
            case {'year2','2_year_follow_up_y_arm_1'}
                temp = temp(ismember(temp.eventname,'2_year_follow_up_y_arm_1'),:);
            case {'year3','3_year_follow_up_y_arm_1'}
                temp = temp(ismember(temp.eventname,'3_year_follow_up_y_arm_1'),:);
        end

        % remove variables that are blank/empty for all rows
        empt = false(1,width(temp));
        for v=1:length(empt)
            var = table2array(temp(:,v));
            if iscell(var)
                if all(cellfun(@isempty,var))
                    empt(v) = true;
                end
            end
        end
        temp(:,empt) = [];

        if n==1
            instrument = temp;
        else
            instrument = outerjoin(instrument,temp,'MergeKeys',true);
        end
    end
end