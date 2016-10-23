function jc_deletebatchdcrd(batchdcrd,cspec)

ff = load_batchf(batchdcrd);

for i = 1:length(ff)
    notmat = [ff(i).name '.not.mat'];
    if exist(notmat)
        delete(notmat);
    end
        delete(ff(i).name);
        if strcmp(cspec,'obs0')
            if exist([ff(i).name(1:end-4) 'rec'])
                delete([ff(i).name(1:end-4) 'rec']);
            end
            if exist([ff(i).name(1:end-4) 'tmp']);
                delete([ff(i).name(1:end-4) 'tmp']);
            end
        end
%         notmat = [ff(i).name '.not.mat'];
%             if exist(notmat)
%                 delete(notmat);
%             end
    end
        
end
