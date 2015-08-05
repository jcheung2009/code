%this is being rewritten in order to analyze two channels with two distinct
%thresholds in dual RA-HVC inactivation experiment
%

function [TH]=get_thresh3(batch,song_chan,tet_chans,chns2plot);
%data is scaled to actual units for this thresh
%plot the data,when the user hits return, prompt a ginput statment
fid=fopen(batch,'r');
fn=fgetl(fid);
ptstoplt=1:32000;
TH=-2000;
sfct=(1e3/2^15);
[data,fs]=ReadCbinfile(fn);
a=size(data)

figure;
data=-sfct.*data;

lnchns=length(chns2plot)
for i=1:lnchns
    lnchns
    chn=chns2plot(i)
    subplot(lnchns,1,i)

    yvec=data(ptstoplt,chn);
    xvec=0:1/fs:(length(yvec)-1)/fs;
    xvec2=0:1/100:(length(yvec)-1)/fs;

    plot(xvec,yvec);
    hold on;
    %[ans]=input('press return when zoomed in');
    [x,y]=ginput();

    mn_dat=mean(data(floor(x(1)*fs):ceil(x(2)*fs),chn));
    st_dat=std(data(floor(x(1)*fs):ceil(x(2)*fs),chn));
    TH(i)=mn_dat+6*st_dat;
    thvec=TH(i)*ones(length(xvec2),1);
    plot(xvec2,thvec','r','Linewidth',2);
    ans=input('Threshold okay?')
    if(isempty(ans))
   
    else
        [x,y]=ginput();
        TH(i)=y;
    
    end
end