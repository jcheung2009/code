function [boutfreq_pre boutfreq_post ind_pre ind_post] = jc_pitchbout(pre_cell, post_cell, tb_pre, tb_post)
%

%% Divide pitch data into epochs 
dur = [];%inter syllable durations
for i = 1:length(tb_pre)
    dur = cat(1,dur,diff(tb_pre{i}));
end

[n b] = hist(dur,[0:10:3300]); %counts for each 10 second bin up to 3300 seconds ~55 minutes
[pks locs] = findpeaks(n); %find peaks and locations of inter syllable durations 

boutfreq_pre = {};
ind_pre = {};
for i = 1:length(tb_pre)
    ISD = diff(tb_pre{i});
    
%     %find highest pklocs (longest ISD threshold) that would make less than
%     %5 epochs
%     nbouts = length(find(ISD > b(locs(1))-10));
%     ii = 2;
%     while nbouts > 4  
%     nbouts = length(find(ISD > b(locs(ii))-10));
%     ii = ii + 1;
%     end
%     maxloc = ii-2;
%     
    %find lowest pklocs (shortest ISD threshold) that would make epochs
    %with more than 10 syllable members
    boutendpts = find(ISD > b(locs(1))-10);
    boutmem = isempty(find(diff(boutendpts) < 10));
    ii = 2;
    while boutmem == 0
        boutendpts = find(ISD > b(locs(ii))-10);
        boutmem = isempty(find(diff(boutendpts) < 10));
        ii = ii + 1;
    end
    minloc = ii - 1;
   

    ind = find(ISD > b(locs(minloc))-10);
    ind = [1; ind; length(tb_pre{i})];
    ind_pre{i} = ind;
    boutfreq = [];
    for iii = 1:length(ind)-1
           boutfreq(iii) = mean(pre_cell{i}(ind(iii):ind((iii+1))-1));
    end
   
    boutfreq_pre{i} = boutfreq;
    
end


boutfreq_post = {};
ind_post = {};
for i = 1:length(tb_post)
    ISD = diff(tb_post{i});
    
    boutendpts = find(ISD > b(locs(1))-10);
    boutmem = isempty(find(diff(boutendpts) < 10));
    ii = 2;
    while boutmem == 0
        boutendpts = find(ISD > b(locs(ii))-10);
        boutmem = isempty(find(diff(boutendpts) < 10));
        ii = ii + 1;
    end
    minloc = ii - 1;
   

    ind = find(ISD > b(locs(minloc))-10);
    ind = [1; ind; length(tb_post{i})];  
    ind_post{i} = ind;
    boutfreq = [];
    for iii = 1:length(ind)-1
           boutfreq(iii) = mean(post_cell{i}(ind(iii):ind((iii+1))-1));
    end

    boutfreq_post{i} = boutfreq;
end

