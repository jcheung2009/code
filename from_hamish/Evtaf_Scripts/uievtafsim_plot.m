function uievtafsim_plotdata(hObject,handles);
%uievtafsim_plotdata(hObject,handles);

set(handles.FileNumBox,'String',[num2str(handles.Nfile),'/',num2str(length(handles.files))]);

fn=handles.files{handles.Nfile};
[dat,fs]=ReadEvTAFFile(fn,str2num(handles.CHANSPEC));
[sm,sp,t,f]=evsmooth(dat,fs,0);
sp=abs(sp);

axes(handles.SpecGramAxes);
hold off;
imagesc(t,f,log(abs(sp)));
set(gca,'YD','n');
title(fn,'Interpreter','none');
xlim([0,t(end)]);
ylim([0,1e4]);

handles.SPMax=max(max(log(sp)));
handles.SPMin=min(min(log(sp)));
temp1=get(handles.SPMinLevel,'Value');
temp2=get(handles.SPMaxLevel,'Value');
mn=handles.SPMin;mx=handles.SPMax;
caxis([temp1*(mx-mn)+mn,temp2*mx]);

handles.t=t;
handles.fs=fs;
handles.dat=dat;
guidata(hObject,handles);

PlotTafVals(hObject,handles);
handles=guidata(hObject);

axes(handles.LabelAxes);cla;hold off;
if (exist('handles.ActTrigTimes'))
    delete(handles.ActTrigTimes);
    handles.ActTrigTimes=[];
end

rdata=readrecf(fn);
if (exist('rdata'))
    if (length(rdata.ttimes)>0)
        handles.ActTrigTimes=plot(rdata.ttimes*1e-3,0*rdata.ttimes,'r^');
        hold on;
    end
end

trigtimes = handles.TrigT;
tmp_plt=plot(trigtimes,0*trigtimes-0.5,'bs');
axis([0,t(end),-1,1]);
handles.TRIGPLT=tmp_plt;
set(handles.LabelAxes,'XTick',[],'YTick',[]);

linkaxes([handles.SpecGramAxes,handles.ValAxes,handles.LabelAxes],'x');

handles.tlim=[0,t(end)];
handles.sp=sp;
handles.fs=fs;
handles.TrigT=trigtimes;
guidata(hObject,handles);

return;
