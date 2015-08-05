function [] = autosegments(batch,threshold,min_int, min_dur)
%
%
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
    
    if (~exist([fn,'.not.mat'],'file'))
        
        [dat,Fs]=evsoundin('',fn,CSPEC);
        if(size(dat)==0)
            continue
        end
        sm=evsmooth(dat,Fs,0);
        [ons,offs]=SegmentNotes(sm,Fs,min_int,min_dur,threshold);
        onsets=ons*1e3;offsets=offs*1e3;
        fname=fn;
        labels=char(ones([1,length(onsets)])*45);
  
    
    fname=fn;
	cmd = ['save ',fn,'.not.mat fname Fs labels min_dur min_int ',...
	                      'offsets onsets sm_win threshold'];
	eval(cmd);
    clear sm;
end
    fclose(fid);
    return;
    