colordef black
figure

fs=44100
startsong=0.01
endsong=2
lowfiltval=100
highfiltval=20000


datinfiles={'examplewn.wav'};
aifffile='3667.aiff';
%datoutfiles={'3667s1' '3667s2'};
aif_outfiles={'34.aif' '34p5.aif' '34p10.aif' '34m5.aif' '34m10.aif'}



[datoutfiles{1}]=wavread(datinfiles{1});

for i=1:length(datoutfiles)
    [sm,sp,t,f]=evsmooth(datoutfiles{1},fs,.005);
    imagesc(t,f,log(abs(sp)));syn;ylim([0,1e4]);
end
%linkaxes2

datsong=datoutfiles{1}(fs*startsong:fs*endsong);

%highpassfiltertoremovelow
 [datsong]=bandpass(datsong,fs,lowfiltval,highfiltval,'butter');


normvec(1)=max(datsong);
normvec(2)=abs(min(datsong));
normfactor=max(normvec);

datsong=32768*(1/normfactor)*datsong;

%writeaiff_file
aiffwrite(aiffile,datsong,fs,16);


%Write the aif files back to regular data%
for(i=1:length(aif_outfiles))
    pshift{i}=aiffread(aif_outfiles{i});
end

%for i=1:length(pshift)
    %pshift{i}=pshift{i}(1:262000)
    %[pshift{i}]=bandpass(pshift{i},fs,lowfiltval,highfiltval,'butter');
    %normvec(1)=max(pshift{i});
    %normvec(2)=abs(min(pshift{i}))

    %normfactor(i)=max(pshift{i});

    %ind{i}=find(pshift{i}==normfactor(i));
%end


renormalize the data
for(i=1:length(pshift))
 pshift{i}=pshift{i}/32768
end

figure;
numfiles=length(pshift)

%Examine the data
for(i=1:length(pshift))
    ax(i)=subplot(numfiles,1,i);
    [sm,sp,t,f]=evsmooth(pshift{i},fs,1);
    imagesc(t,f,log(abs(sp)));syn;ylim([0,1e4]);
    smarray{i}=sm;
    spectarray{i}=sp;
    tarray{i}=t;
    farray{i}=f;
    %title();
    %axis([2 4 1 10000]);
    
end

linkaxes(ax,'x');


%Calculate the cross-correlation of the smoothed data
figure;
norm=smarray{1};
for(i=1:length(smarray))
       
        xcorrarray=xcorr(smarray{i},norm,5000);
        subplot(4,2,i)
        plot(-5000:5000,xcorrarray)
        offsetarray(i)=find(xcorrarray==max(xcorrarray))-5000;
end

%shift data back in time
for(i=1:length(pshift))
    %corpshift7980{i}=circshift(pshift7980{i}(:,1),-offsetarray{i});
    lng=length(pshift{i});

%instead cut out points
    tester=pshift{i};
    corpshift=tester(offsetarray(i)+1:lng);
%now add points at end%
    %if offset is 1, I want to just add the same point)
    sampvec=lng:-1:(lng-offsetarray(i)+1)
    pshiftbit=(tester(sampvec,1));
    corpshift=[corpshift ;pshiftbit];
    corpshifted{i}=corpshift;
    %check to make sure total power is constant
end

%check total power
figure
for(i=1:length(pshift))
    fftarray{i}=fft(corpshifted{i})
    fftfreqs=0:((44100/2)/(length(corpshifted{i})/2)):44100/2;
    subplot(4,2,i)
    absarray=abs(fftarray{i}).^2;
    plot(fftfreqs(1:100000), log(absarray(1:100000)))
end

%cut out initial points...6616 is a good blank spot
%for(i=1:length(pshift7980))
 %   corpshifted7980{i}=corpshifted7980{i}(6616:length(corpshifted7980{i}));
%end
%produce a reverse bos stimulus
testvec=length(corpshifted{1}):-1:1;  
corpshifted{numfiles+1}=corpshifted{1}(testvec);

%THIS NORMALIZATION IS OUT OF ORDER%
%Then normalize
%for i=1:length(corpshifted)

%normvec(1)=max(corpshifted{i});
%normvec(2)=abs(min(corpshifted{i}));
%normfactor=max(normvec);


%corpshiftednorm{i}=corpshifted{i}.*(1/normfactor);
%end


%and weight the first 100 ms, 
%and the last 100 ms, with a

corpshiftednorm=corpshifted;

ln_endpoints=.1*fs
slope=1/ln_endpoints
inwtvector=0:slope:1
%fnwtvector=1:-slope:0;
begvector=1:1:length(inwtvector);
endvector=length(corpshiftednorm{1}):-1:length(corpshiftednorm{1})-length(inwtvector)+1;

for i=1:length(corpshiftednorm)
    corpshiftednormg{i}=corpshiftednorm{i}
    corpshiftednormg{i}(begvector)=corpshiftednorm{i}(begvector).*inwtvector'
    corpshiftednormg{i}(endvector)=corpshiftednorm{i}(endvector).*inwtvector'
end




initbuff=zeros(2*fs,1);
    finalbuff=zeros(fs,1);

%FINALLY, WRITE TO WAV FILES*/
wavstring={'34.wav' '34p5.wav' '34p10.wav' '34m5.wav' '34m10.wav' '34rev.wav'}
for i=1:length(corpshiftednormg)
    %corpshiftednormg{i}=[initbuff;corpshiftednormg{i};finalbuff];
    wavwrite(corpshiftednormg{i}, fs,16,wavstring{i});
end
wavstring={'34.wav' '34p10tl.wav' '34m10tl.wav'}
for i=2:3
    %sngshift{i}=[initbuff;sngshift{i};finalbuff];
    wavwrite(sngshift{i}, fs,16,wavstring{i});
end
