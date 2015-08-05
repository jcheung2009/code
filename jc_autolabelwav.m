function jc_autolabelwav(batchfile,template,cntrng,syl,refrac,ampThresh,min_dur,min_int,EVMODE,NFFT,sm_win,chcklbl)

currentDir = pwd;

if isempty(EVMODE)
	EVMODE=0;
elseif (length(EVMODE)==0)
	EVMODE=0;
end
if isempty(sm_win)
    sm_win = 2.0;
end
if isempty(NFFT)
    NFFT=128;
end

CHANSPEC='w';
sylLabel = syl;

fid=fopen(batchfile,'r');
count = 1;
while (1)
	fn=fgetl(fid);
    
    disp(fn)
	if (~ischar(fn))
        break;
    end;
    if (~exist(fn,'file'))
        continue;
    end

    PREDATATIME = 2.0;
    
    [dat,fs]=evsoundin('',fn,CHANSPEC);
    datFull = dat;
    dat=dat(fix(PREDATATIME*fs):end);
    vals=evtafsim(dat,fs,template,EVMODE);
    

    for ii=1:length(cntrng)     % get_trig2 part
        if (~isfield(cntrng(ii),'NOT'))
            cntrng(ii).NOT=0;
        end
        if (~isfield(cntrng(ii),'MODE'))
            cntrng(ii).MODE=1;
        end
    end

    NCNT=length(cntrng);
    cnt=zeros([1,NCNT]);
    trigs=[];
    pp=findstr(fn,'.cbin');
    tmpdat=vals;
    refracsam=ceil(refrac/(2*NFFT/fs));
    lasttrig=-refrac;tt=[];
    cnt=0*cnt;
    for kk=1:NCNT
        if (cntrng(kk).MODE==0)
            cnt(kk)=cntrng(kk).MAX+1;
        end
    end
	
    cntvals=zeros([NCNT,size(tmpdat,1)]);
    for ii = 1:size(tmpdat,1)
        for kk=1:NCNT
            if (tmpdat(ii,kk)<=cntrng(kk).TH)
                if (cntrng(kk).MODE==1)
                    cnt(kk)=cnt(kk)+1;
                else
                    if (cnt(kk)>=cntrng(kk).BTMIN)
                        cnt(kk)=0;
                    else
                        cnt(kk)=cnt(kk)+1;
                    end
                end
            else
                if (cntrng(kk).MODE==0)
                    cnt(kk)=cnt(kk)+1;
                else
                    cnt(kk)=0;
                end
            end
        end
	cntvals(:,ii)=cnt.';
        for kk=1:NCNT
            if ((cnt(kk)>=cntrng(kk).MIN)&(cnt(kk)<=cntrng(kk).MAX))
                ntrig=1;
            else
                ntrig=0;
            end
            if (cntrng(kk).NOT==1)
                ntrig=~ntrig;
            end
            if (kk==1)
                trig=ntrig;
            else
                if (cntrng(kk-1).AND==1)
                    trig = trig & ntrig;
                else
                    trig = trig | ntrig;
                end
            end
        end
        
        if (trig)
            if (abs(ii-lasttrig)>refracsam)
                tt=[tt;((ii*NFFT*2/fs)+PREDATATIME)*1e3];
                lasttrig=ii;
            end
        end
    end
    
   
    if (~exist([currentDir,'/',fn,'.not.mat'],'file'))
        if(size(dat)==0)
            continue
        end
        [sm]=SmoothData(datFull,fs,1,'hanningfirff');
        sm(1)=0.0;sm(end)=0.0;
        [ons,offs]=SegmentNotes(sm,fs,min_int,min_dur,ampThresh);
        onsets=ons*1e3;offsets=offs*1e3;
        labels = char(ones([1,length(onsets)])*fix('-'));
    else
        load([fn,'.not.mat']);
    end
	for ii = 1:length(tt)
		pp=find((onsets<=tt(ii))&(offsets>=tt(ii)));
		if (length(pp)>0)
			labels(pp(end))=sylLabel;
        end
    end
	fname=fn;
    Fs = fs;
    threshold = ampThresh;
	cmd = ['save ',fn,'.not.mat fname Fs labels min_dur min_int ',...
	                      'offsets onsets sm_win threshold'];
	eval(cmd);
    clear sm;
    count = count + 1;
    
end
%%
if chcklbl == 1
    result = input('PRETIME,POSTTIME,PRENT,POSTNT,repsyl:');
    jc_chcklbl(batchfile,syl,result{1},result{2},result{3},result{4},CHANSPEC);
    !ls syllwv* > wav
    evsonganaly
    load('syllwv1.wav.not.mat');labels1 = labels;
    load('syllwv2.wav.not.mat');labels2 = labels;
    labels = [labels1 labels2];
    [vlsorfn vlsorind] = jc_vlsorfn(batchfile,syl,result{3},result{4});
    if size(vlsorfn) == size(labels)
        ind = strfind(labels,'x');
        jc_fndlbl(vlsorind,vlsorfn,ind,result{5})
    else
        disp('size vlsorfn ~= size labels')
    end
end