function [timeon timeoff sm_ind_shift sm_ind2_shift] = jc_dtwsyll(sm_shift, locs_onset, locs_offset)


% %%% get average waveform of aligned smooth waves and average derivative of
% %%% template wave. define onset and offsets using findpeaks and manual ID
% avsm_align = mean(sm_shift,2);
% avsm_alignder = abs(diff(avsm_align));
% 
% [pks locs] = findpeaks(avsm_alignder);
% 
% figure(100);hold on;
% plot(avsm_align,'k');
% plot(avsm_alignder,'r');

%%manually pick peaks for onset and offset
% [pks locs] = findpeaks(avsm_alignder);
% [c b] = mind(abs(locs - locs_offset));


%%do dtw on all deriv smooth waveforms against template wave. ID matching
%%onset and offset times
%%use locs from figure for avsm_alignder
fs = 32000;
timeon = [];
timeoff = [];
sm_ind_shift = [];
sm_ind2_shift = [];
avsm_align = mean(sm_shift,2);
avsm_alignder = abs(diff(avsm_align));
[pks locs] = findpeaks(avsm_alignder);
[c b] = min(abs(locs - locs_onset));
locs_onset = locs(b);
[c b] = min(abs(locs - locs_offset));
locs_offset = locs(b);

for i = 1:size(sm_shift,2)
    sm_shiftder(:,i) = abs(diff(sm_shift(:,i)));
end

for ii = 1:size(sm_shiftder,2)
   [dist,d,k,w,rw,tw] = dtw(sm_shiftder(:,ii),avsm_alignder,0);
   ind = find(w(:,2) == locs_onset);
   ind_shift = w(ind(1),1); %onset point in sm_shiftder
   ind2 = find(w(:,2) == locs_offset);
   ind2_shift = w(ind2(1),1); %offset point in sm_shiftder
   timeon(ii,1) = ind_shift/fs;
   timeoff(ii,1) = ind2_shift/fs;
   sm_ind_shift = cat(1,sm_ind_shift,ind_shift);
   sm_ind2_shift = cat(1,sm_ind2_shift,ind2_shift);
end
