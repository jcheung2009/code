function label_trigs(batch,NT,CSPEC);
%trigger is labelled nt

fid=fopen(batch,'r');
if (fid==-1)
        disp(['could not find batch file :',batch]);
        return;
end

while (1)
        fn=fgetl(fid);
        if (~ischar(fn))
                break;
        end

        if (~exist(fn,'file'));
                continue;
        end
    if(isempty(readrecf(fn)))
        continue
    end

    if (~exist([fn,'.not.mat'],'file'))
        continue
    else
        load([fn,'.not.mat']);
    end

    rd=readrecf(fn);
    if (~isfield(rd,'ttimes'))
            rd.ttimes=[];
    end
    for ii = 1:length(rd.ttimes)
            pp=find((onsets<=rd.ttimes(ii))&(offsets>=rd.ttimes(ii)));
            if (length(pp)>0)
                    labels(pp(end))=NT;
            end

            fname=fn;
            cmd = ['save ',fn,'.not.mat fname Fs labels min_dur min_int ',...
                                  'offsets onsets sm_win threshold'];
            eval(cmd);
            clear sm;
    end
end
fclose(fid);
return;