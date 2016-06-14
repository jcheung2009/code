function jc_deletebatchdcrd(batchdcrd,cspec)

ff = load_batchf(batchdcrd);

for i = 1:length(ff)
    notmat = [ff(i).name '.not.mat'];
%     if ~exist(ff(i).name) && ~exist(notmat)
%         continue
%     else
        delete(ff(i).name);
        delete(notmat);
        if strcmp(cspec,'obs0')
            delete([ff(i).name(1:end-4) 'rec']);
            delete([ff(i).name(1:end-4) 'tmp']);
        end
%         notmat = [ff(i).name '.not.mat'];
%             if exist(notmat)
%                 delete(notmat);
%             end
    end
        
end
