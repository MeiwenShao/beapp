function eeg_msk_w_cond = beapp_create_condition_mask (grp_proc_info_in,file_proc_info,eeg_msk_curr_epoch,curr_epoch,curr_condition)

if grp_proc_info_in.src_data_type ==3
    
    curr_cond_curr_epoch_msk = ones(1,size(eeg_msk_curr_epoch,2));
    
    if ~isempty(file_proc_info.evt_info{curr_epoch})
        target_label_ind = find(ismember({file_proc_info.evt_info{curr_epoch}.type},file_proc_info.grp_wide_possible_cond_names_at_segmentation{curr_condition}));  
    else
        target_label_ind = [];
    end
    
    % for each tag associated with this condition
    for curr_target_label = 1:length(target_label_ind)
        
        % get the name and index of the relevant event tag in onset strs 
        curr_tag = file_proc_info.evt_info{curr_epoch}(target_label_ind(curr_target_label)).evt_codes; 
        curr_tag_ind_in_onset_strs = find(strcmp(grp_proc_info_in.beapp_event_code_onset_strs,curr_tag));
        
        % find the nearest paired end tag that goes with that start tag
        inds_of_end_tag = find(ismember({file_proc_info.evt_info{curr_epoch}.evt_codes},grp_proc_info_in.beapp_event_code_offset_strs{curr_tag_ind_in_onset_strs}));
        curr_end_tag_ind = inds_of_end_tag(find((inds_of_end_tag-target_label_ind(curr_target_label))>0,1));
        
        % mark all data in between sample number of start and nearest end
        % tag
        curr_cond_curr_epoch_msk (1,[file_proc_info.evt_info{curr_epoch}(target_label_ind(curr_target_label)).evt_times_samp_rel]:...
            [file_proc_info.evt_info{curr_epoch}(curr_end_tag_ind).evt_times_samp_rel])=0;
    end
    if isfield(grp_proc_info_in,'flag_for_bad_value_start_end') %Check if the flag_for_bad_value_start_end variable exists
        if ~isempty(grp_proc_info_in.flag_for_bad_value_start_end)%Check if the variable has any inputs/values
            artifact_start_ind = find(ismember({file_proc_info.evt_info{curr_epoch}.evt_codes},grp_proc_info_in.flag_for_bad_value_start_end{1})); %Find the indexes of the NS art start tags, these will be stored within the data file as an event code
            artifact_end_ind = find(ismember({file_proc_info.evt_info{curr_epoch}.evt_codes},grp_proc_info_in.flag_for_bad_value_start_end{2})); %Find the indexes of the NS end tags
            artifact_start_samp_rel = [file_proc_info.evt_info{curr_epoch}(artifact_start_ind).evt_times_samp_rel]; %Extract the time sample of each start tag
            artifact_end_samp_rel = [file_proc_info.evt_info{curr_epoch}(artifact_end_ind).evt_times_samp_rel]; %Extract the time sample of each end tag
            %Check if the number of art+ tags is equal to the number of art- tags. If there are more art+ tags, then MATLAB will display a warning and ignore the last art+ tag
            n = numel(artifact_start_samp_rel);
            if n~= numel(artifact_end_samp_rel)
                n = n-1;
                warndlg(append(file_proc_info.src_subject_id,' has ',num2str(n), ' start artifact tags and ',num2str(numel(artifact_end_samp_rel)), ' end artifact tags. Skipping the last artifact start tag.'),'Issue with trial rejection based on artifact markers');
            end
            %Extract all the time samples’ segments between each start tag and the matching end tag
            mask_indices = cell(1,n);
            for k=1:n
                mask_indices{1,k} = artifact_start_samp_rel(k):artifact_end_samp_rel(k);
            end
            mask_indices = [mask_indices{:}];

            %Set curr cond curr_epoch_msk variable back to 1 where there was artifact
            curr_cond_curr_epoch_msk (1,mask_indices)=1;
        end
    end
else 
    curr_cond_curr_epoch_msk = zeros(1,size(eeg_msk_curr_epoch,2));
end

eeg_msk_w_cond = any([curr_cond_curr_epoch_msk; eeg_msk_curr_epoch],1);