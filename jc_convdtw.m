function [onsets offsets string_ons string_offs] = jc_convdtw(sm_ind_shift, sm_ind2_shift, sm_offsets, sm_st,stringind);
% make sure all input vectors are same length

onsets = [];
offsets = [];
fs = 32000;
for i = 1:length(sm_offsets);
    onset = (sm_ind_shift(i) - sm_offsets(i) - 1 + sm_st(i))*1000/fs;
    offset = (sm_ind2_shift(i) - sm_offsets(i) - 1 + sm_st(i))*1000/fs;
    onsets = cat(1,onsets,onset);
    offsets = cat(1,offsets,offset);
end

if ~isempty(stringind)
    stringen = [];
    stringst = [];
    for ii = 1:length(stringind)
        string_en = sum(stringind(1:ii));
        stringen = cat(1,stringen,string_en);
    end
    stringst = [1; (stringen(1:end-1) + 1)];
    if ~isequal ((stringen-stringst+1),stringind)
        disp('error!')
    end
    string_ons = {};
    string_offs = {};
    for iii = 1:length(stringst)
        string_ons{iii} = onsets(stringst(iii):stringen(iii));
        string_offs{iii} = offsets(stringst(iii):stringen(iii));
    end
end


maxlengthons = max(cellfun(@(x)numel(x),string_ons));
maxlengthoffs = max(cellfun(@(x)numel(x),string_offs));

string_ons = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlengthons-length(x),1)),string_ons,'UniformOutput',false));
string_offs = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlengthoffs-length(x),1)),string_offs,'UniformOutput',false));