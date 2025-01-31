%% This function marks all events occurring between each behavior coding start and end as bad trials

function evt_info = update_behavioral_coding(evt_info,flag_for_bad_value_start_end,bad_trial_label,epoch_inds_to_process)

for curr_epoch = 1:size(evt_info,2)
    if ~isempty(epoch_inds_to_process) && curr_epoch ~= epoch_inds_to_process
        continue
    end

    start_bad_trial_idxs = find(strcmp({evt_info{curr_epoch}.evt_codes},flag_for_bad_value_start_end{1,1}));

    end_bad_trial_idxs = find(strcmp({evt_info{curr_epoch}.evt_codes},flag_for_bad_value_start_end{1,2}));

    n_start_trials =  length(start_bad_trial_idxs);
    n_end_trials =  length(end_bad_trial_idxs);

    if n_start_trials ~= n_end_trials % handles the situation when the user presses an unequal number of start and end buttons


        if n_start_trials > n_end_trials
            for ii = 1:n_start_trials

                difference = (end_bad_trial_idxs - start_bad_trial_idxs(ii));
                %mask for positive values
                difference(difference < 0) = NaN;
                [vals(ii),idxs(ii)] = min(difference);

            end
            [v, w] = unique( idxs, 'stable' );
            duplicate_indices = setdiff( 1:numel(idxs), w );
            start_bad_trial_idxs(duplicate_indices) = [];
            for ii = 1:length(end_bad_trial_idxs)
                [evt_info{curr_epoch}([start_bad_trial_idxs(ii)+1]:[end_bad_trial_idxs(ii)-1]).behav_code] = deal(bad_trial_label{1,1});
            end
        end

        if n_start_trials < n_end_trials
            for ii = 1:n_end_trials

                difference = (end_bad_trial_idxs(ii) - start_bad_trial_idxs);
                %mask for positive values
                difference(difference < 0) = NaN;
                [vals(ii),idxs(ii)] = min(difference);

            end
            [v, w] = unique( idxs, 'stable' );
            duplicate_indices = setdiff( 1:numel(idxs), w );
            end_bad_trial_idxs(duplicate_indices) = [];
            for ii = 1:length(end_bad_trial_idxs)
                [evt_info{curr_epoch}([start_bad_trial_idxs(ii)+1]:[end_bad_trial_idxs(ii)-1]).behav_code] = deal(bad_trial_label{1,1});
            end
        end

    else

        for ii = 1:length(end_bad_trial_idxs)
            [evt_info{curr_epoch}([start_bad_trial_idxs(ii)+1]:[end_bad_trial_idxs(ii)-1]).behav_code] = deal(bad_trial_label{1,1});
        end

    end
end

end