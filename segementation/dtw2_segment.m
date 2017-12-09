function [sm_ons sm_offs]  = dtw2_segment(sm,dtwtemplate,fs);
%performs dtw on the amplitude envelope with a exemplar 
%returns time in seconds into sm that corresponds to onsets and offsets of
%template

temp = dtwtemplate.sm;
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
temp=log(temp);temp=temp-min(temp);temp=temp./max(temp);
temp_onind = NaN(length(temp_ons),1);temp_offind = NaN(length(temp_offs),1);
dtwtemp_tb = [0:length(temp)-1]./fs;
for m = 1:length(temp_ons)
    [~, temp_onind(m)] = min(abs(temp_ons(m)-dtwtemp_tb));
    [~, temp_offind(m)]=min(abs(temp_offs(m)-dtwtemp_tb));
end

samp_tb = [0:length(sm)-1]./fs;
sm_ons = NaN(length(temp_onind),1);sm_offs = NaN(length(temp_offind),1);
[dist ix iy] = dtw(temp,sm);
for m = 1:length(temp_onind)
    ind = find(ix==temp_onind(m));
    ind = ind(ceil(length(ind)/2));
    sm_ons(m) = samp_tb(iy(ind));
    ind = find(ix==temp_offind(m));
    ind = ind(ceil(length(ind)/2));
    sm_offs(m) = samp_tb(iy(ind));
end
