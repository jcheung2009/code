function get_trigt(bt,cntrng,refrac,NFFT,ADDX,TEMPFILE);
%get_trigt(bt,cntrng,refrac,NFFT,ADDX,TEMPFILE);
%
% bt=batch file
% cntrng = struct with MIN, MAX, TH
% refrac in seconds
% NFFT is the number of points in the templ file
%ADDX if ==1 add the X to the tmp file name to use
% termperary tmp files defualt == 1
% TEMPFILE make a .###X.rec file to avoid overwrite
%    if this is == 1 (defualt)

fid=fopen(bt,'r');
if fid==-1
    disp(['could not find batch file : ',bt]);
    return;
end

if (~exist('ADDX'))
    ADDX=1;
end
if (~exist('TEMPFILE'))
    TEMPFILE=1;
end
if (~exist('NFFT'))
    NFFT=128;
end

if (~exist('refrac'))
    refrac=100e-3;
end


NCNT=length(cntrng);
cnt=zeros([1,NCNT]);
while (1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    if (~exist(fn,'file'))
        continue;
    end
    pp=findstr(fn,'.cbin');
    if (ADDX==1)
        fnt=[fn(1:pp(end)-1),'X.tmp'];
    else
        fnt=[fn(1:pp(end)),'tmp'];
    end
    if (~exist(fnt,'file'))
        disp('hey');
        continue;
    end
    disp(fnt);

    rdat=readrecf(fn);
    tmpdat=load(fnt);
    tmpdat2=zeros([fix(length(tmpdat)/NCNT),NCNT]);
    for ii=1:NCNT
        tmpdat2(:,ii)=tmpdat(ii:NCNT:end);
    end
    tmpdat=tmpdat2;
    clear tmpdat2;

    fs=rdat.adfreq;
    %TH=1.5;fs=32000;
    refracsam=ceil(refrac/(2*NFFT/fs));
    lasttrig=-refrac;tt=[];
    cnt=0*cnt;
    for ii = 1:size(tmpdat,1)
        for kk=1:NCNT
            if (tmpdat(ii,kk)<=cntrng(kk).TH)
                cnt(kk)=cnt(kk)+1;
            else
                cnt(kk)=0;
            end
        end

        trig=0;
        for kk=1:NCNT
            if ((cnt(kk)>=cntrng(kk).MIN)&(cnt(kk)<=cntrng(kk).MAX))
                trig = 1;
            end
        end

        if (trig)
            if (abs(ii-lasttrig)>refracsam)
                tt=[tt;((ii*NFFT*2/fs)+rdat.tbefore)*1e3];
                lasttrig=ii;
            end
        end
    end
    rdat.ttimes=tt;
    tmp=zeros([length(cntrng),1]);
    for ii=1:length(tmp)
        tmp(ii)=cntrng(ii).TH;
    end
    rdat.thresh=tmp;
    if (TEMPFILE==1)
	fntemp=fn;
	pp=findstr(fn,'.cbin');
	if (length(pp)==0)
		pp=findstr(fn,'.bbin');
	end
	if (length(pp)>0)
		fntemp=[fn(1:pp(end)-1),'X',fn(pp(end):end)];
    		wrtrecf(fntemp,rdat);
	end
     else
    		wrtrecf(fn,rdat);
     end
end
