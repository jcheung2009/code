function [durations gaps] = jc_repdurgap(batch, filestart, fileend, syll)
% get durs and gaps for strings of repeats by pulling out onsets/offsets from not mats


fid=fopen(batch,'r');
files=[];cnt=0;
while (1)
       fn=fgetl(fid);
       if (~ischar(fn))
               break;
       end
       cnt=cnt+1;
       files(cnt).fn=fn;
end
fclose(fid);

if isempty(filestart)
    filestart = 1;
end
if isempty(fileend)
    fileend = length(files);
end

durations = {};
gaps = {};
for i = filestart:fileend;
    load(strcat(files(i).fn,'.not.mat'));
    a = ismember(labels,syll);
    ii = [find(diff([-1 a -1])~=0)];
    ii(1) = [];
    ii(end) = [];
    string_start = ii(1:2:end);
    string_end = ii(2:2:end) - 1;
    b = {};
    c = {};
    if length(string_start) == length(string_end)
        for iii = 1:length(string_start)
            string_onsets = onsets(string_start(iii):string_end(iii));
            string_offsets = offsets(string_start(iii):string_end(iii));
            string_durs = string_offsets - string_onsets;
            string_gaps = string_onsets(2:end) - string_offsets(1:end-1);
                if isempty(string_gaps)
                    string_gaps = NaN;
                end
            b{iii} = string_durs;
            c{iii} = string_gaps;
        end
    else
        disp('error')
    end
    durations = [durations, b];
    gaps = [gaps, c];
            
end

maxlengthdur = max(cellfun(@(x)numel(x),durations));
maxlengthgap = max(cellfun(@(x)numel(x),gaps));

durations = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlengthdur-length(x),1)),durations,'UniformOutput',false));
gaps = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlengthgap-length(x),1)),gaps,'UniformOutput',false));
