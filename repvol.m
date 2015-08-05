function [rep] = repvol(batch,filestart,fileend,repeat,syll)

TIMESHIFT = 0.04;
FVALBND=[2000 4000];
PRENOTE = '';
POSTNOTE = '';
USEFIT = 1;
fs = 32000;
NFFT = 512;
CHANSPEC = 'obs0';



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

rep = [];
for i = filestart:fileend;
    load(strcat(files(i).fn,'.not.mat'))
    a = ismember(labels,repeat);

        ii = find(diff([-1 a -1])~=0);
        runlength = diff(ii);
        runlength1 = runlength(1 + (a(1)==0):2:end);
        medianrep = median(runlength1);
        
    p = findstr(labels,[PRENOTE, syll, POSTNOTE])+length(PRENOTE);
    
     [pthstr,tnm,ext] = fileparts(files(i).fn);
    if (strcmp(CHANSPEC,'w'))
            [dat,fs] = wavread(files(i).fn);
    elseif (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(files(i).fn,CHANSPEC);
    else
        [dat,fs]=evsoundin('',files(i).fn,CHANSPEC);
    end
    
    freq = [];
    for ii = 1:length(p)
        if(length(onsets)==length(labels))
            ton=onsets(p(ii));toff=offsets(p(ii));

         

            ti1=ceil((TIMESHIFT + ton*1e-3)*fs);
            onsamp = ceil((ton*1e-3)*fs);
            offsamp = ceil((toff*1e-3)*fs);
            if (ti1+NFFT-1<=length(dat))
            
                dattmp=dat([ti1:(ti1+NFFT-1)]);
                
                 smtemp=dat(onsamp-128:offsamp+128);
                 sm = filter(ones(1,256)/256,1,(smtemp.^2));
                 
                 fdattmp=abs(fft(dattmp.*hamming(length(dattmp))));
     

                %get the freq vals in Hertz
                fvals=[0:length(fdattmp)/2]*fs/(length(fdattmp));
                fdattmp=fdattmp(1:end/2);
                mxtmpvec=zeros([1,size(FVALBND,1)]);
                for kk = 1:size(FVALBND,1)
                    tmpinds=find((fvals>=FVALBND(kk,1))&(fvals<=FVALBND(kk,2)));

                    NPNTS=10;
                    [tmp,pf] = max(fdattmp(tmpinds));
                    pf = pf + tmpinds(1) - 1;
                    if (USEFIT==1)
                        tmpxv=pf + [-NPNTS:NPNTS];
                        tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(fvals))));

                        mxtmpvec(kk)=fvals(tmpxv)*fdattmp(tmpxv);
                        mxtmpvec(kk)=mxtmpvec(kk)./sum(fdattmp(tmpxv));
                    else
                        mxtmpvec(kk) = fvals(pf);
                    end
                    
                end
            end
        end
        freq = cat(1,mxtmpvec);

        
    end
    meanfreq = mean(freq);
    meanvol = mean(sm);
   dn = fn2datenum(files(i).fn);
   rep = [rep; dn, medianrep, meanfreq, meanvol];
   
            
               

    
%          [pth,nm,ext]=fileparts(files(i).fn);
%            if(strncmp('.cbin',ext,length(ext)))
%                [rawsong,fs] = ReadCbinFile(files(i).fn);
%            elseif(strncmp('.wav',ext,length(ext)))
%                [rawsong,fs] = wavread(files(i).fn);
%            end
%    
%        sm = mquicksmooth(rawsong,fs);
%        sm = decimate(sm,5);
%        vol = mean(sm);
%        dn = fn2datenum(files(i).fn);
%        rep(i,:) = [dn, medianrep, vol];
    
   
end
