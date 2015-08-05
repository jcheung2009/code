function [out] = feature_means(strct_list,days)
%
%
%
%
% in progress oct 6, 2009
%

if(length(strct_list) ~= length(days))
    disp('Feature Struct list & Day list are different lengths. Aborting.');
end

% making hardcoded lookup table of stat names. corresponds to those in
% feature_vect_name.m :
stat_names = {'mean_freq' 'spec_ent' 'peak_amp' 'dur' 'amp_ent' 'crct_mean_freq' 'crct_max_freq'};
stat_names = horzcat(stat_names, {'freq_slope' 'time_to_halfamp' 'cep_peak' 'amp_slope' 'amp_peak_loc' 'harm_freq_mag'});
stat_names = horzcat(stat_names,{'spec_peak' 'full_spec_ent' 'mean_amp'});

out = stat_names;

for i=1:length(stat_names); % each stat
    the_stat = stat_names(i);

    mean_stat_str = [the_stat '_m'];
    sd_stat_str = [the_stat '_sd'];

    mean_ptr = zeros(1,length(days));
    sd_ptr = zeros(1,length(days));

    for dindex=1:length(days); % each day
        the_struct = strct_list(dindex);

        %mean_ptr(dindex) = mean(the_struct.templates(:,i));
        mean_ptr(dindex) = the_struct.template_mean(i);
        sd_ptr(dindex) = std(the_struct.templates(:,i));
    end

    fig_handle = figure();errorbar(days,mean_ptr,sd_ptr,'o');title(the_stat);xlabel('days post tutoring');
    set(fig_handle,'Color','white');

end