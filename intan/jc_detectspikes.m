function [index,xf,thr] = jc_detectspikes(x)
% return the spike times within a channel
%adapted from wave_clus, uses amplitude threshold
%to be used for real time analysis in surgery

%PARAMETERS
sr=32000;
w_pre=22;
w_post=44;
ref=floor(3 *32000/1000);
detect = 'both';%'pos','neg','both' type of threshold
stdmin = 5;
stdmax = 50;
fmin_detect = 300;
fmax_detect = 10000;
fmin_sort = 300;
fmax_sort = 10000;

% HIGH-PASS FILTER OF THE DATA
xf=zeros(length(x),1);
if exist('ellip')                         %Checks for the signal processing toolbox
    [b,a]=ellip(2,0.1,40,[fmin_detect fmax_detect]*2/sr);
    xf_detect=filtfilt(b,a,x);
    [b,a]=ellip(2,0.1,40,[fmin_sort fmax_sort]*2/sr);
    xf=filtfilt(b,a,x);
else
    xf=fix_filter(x);                   %Does a bandpass filtering between [300 3000] without the toolbox.
    xf_detect = xf;
end
lx=length(xf);
clear x;

noise_std_detect = median(abs(xf_detect))/0.6745;
noise_std_sorted = median(abs(xf))/0.6745;
thr = stdmin * noise_std_detect;        %thr for detection is based on detected settings.
thrmax = stdmax * noise_std_sorted;     %thrmax for artifact removal is based on sorted settings.

% LOCATE SPIKE TIMES
switch detect
    case 'pos'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2) > thr) + w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [maxi iaux]=max((xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) - 1; % we selec the max value among the values over the threshold
                % minimum value for index is "w_pre+2"
                xaux0 = index(nspk);

                % plot(1:floor(ref/2),xf(xaux(i):xaux(i)+floor(ref/2)-1),'b')

            end
        end
    case 'neg'
        nspk = 0;
        xaux = find(xf_detect(w_pre+2:end-w_post-2) < -thr) + w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [maxi iaux]=min((xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end
    case 'both'
        nspk = 0;
        xaux = find(abs(xf_detect(w_pre+2:end-w_post-2)) > thr) + w_pre+1;
        xaux0 = 0;
        for i=1:length(xaux)
            if xaux(i) >= xaux0 + ref
                [maxi iaux]=max(abs(xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                nspk = nspk + 1;
                index(nspk) = iaux + xaux(i) -1;
                xaux0 = index(nspk);
            end
        end

end

aux = [];
for i=1:nspk                          %Eliminates artifacts
    if max(abs( xf(index(i)-w_pre:index(i)+w_post) )) > thrmax
        %         spikes(i,:)=xf(index(i)-w_pre-1:index(i)+w_post+2);
        aux(i)=1;
    end
end
% aux = find(spikes(:,w_pre)==0);       %erases indexes that were artifacts, every spike over thrmax is erased
% spikes(aux,:)=[];
index(find(aux==1))=[];
