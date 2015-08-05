function varargout = MiniMenu(varargin)
% MINIMENU M-file for MiniMenu.fig
%      MINIMENU, by itself, creates a new MINIMENU or raises the existing
%      singleton*.
%
%      H = MINIMENU returns the handle to a new MINIMENU or the handle to
%      the existing singleton*.
%
%      MINIMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MINIMENU.M with the given input arguments.
%
%      MINIMENU('Property','Value',...) creates a new MINIMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MiniMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MiniMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MiniMenu

% Last Modified by GUIDE v2.5 01-Apr-2011 12:12:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MiniMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @MiniMenu_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MiniMenu is made visible.
function MiniMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MiniMenu (see VARARGIN)

% Choose default command line output for MiniMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global Data;
global Yax;
global Selection;
global dt;
global times;
global diffsel;

Selection=varargin(1);
Selection=Selection{1};
% Selection=Selection-mean(Selection); %detrend;

% keyboard

i=0;
while (i<(length(Selection)-10000)/10000)
    Selection(i*10000+1:i*10000+10000)=Selection(i*10000+1:i*10000+10000)-mean(Selection(i*10000+1:i*10000+10000));
    i=i+1;
end;
Selection(i*10000+1:end)=Selection(i*10000+1:end)-mean(Selection(i*10000+1:end));

dt=Data.dt;

diffsel=diff(smooth(Selection,80));
% diffel=smooth(diff(Selection,80))

times=dt:dt:length(Selection)*dt;
times=times/1000; % minis in S

hand=plot(handles.MiniPlot,times,Selection);
set(hand,'ButtonDownFcn',{@MiniPlot_ButtonDownFcn,handles});     
hand=plot(handles.dIplot,times(2:end),diffsel);
set(hand,'ButtonDownFcn',{@dIplot_ButtonDownFcn,handles});     


% --- Outputs from this function are returned to the command line.
function varargout = MiniMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse press over axes background.
function dIplot_ButtonDownFcn(hObject, eventdata, handles)
   
global Yax
global ThreshLine;
global Selection
global times;
global Idx;
global diffsel;

buttonclick=get(gcf,'SelectionType');
ax = get(hObject, 'Parent');
pt = get(ax, 'CurrentPoint');

if strcmp(buttonclick,'normal')    
    Yax=[pt(1,2)];         
    Xax=xlim;
    try
        killhand=findobj(gca,'Tag','ThreshLine');
        delete(killhand);
        killhand=findobj(gca,'Tag','Threshdata');    
        delete(killhand);
        killhand=findobj(handles.MiniPlot,'Tag','Threshdata');
        delete(killhand); 
    catch
    end;
    
    axes(ax);
    ThreshLine=line(Xax(1):0.01:Xax(2),Yax(1),'Color','r','LineStyle','-','Tag','ThreshLine');
      
    axes(handles.MiniPlot);
               
    if mean(diffsel)<Yax
        
    elseif mean(diffsel)>Yax
        [Idx]=find(diffsel<Yax);           
        a=find(diff(Idx)>10)
        Idx=[Idx(1); Idx(a)];
%         temp=Idx(1);
%         Idx=Idx(a);
%         Idx=[temp;Idx]; 
        a=find(Selection(Idx)>-15);
        Idx(a)=[]; 
        Idx(end)=[];
        
        line(times(Idx),Selection(Idx),'Marker','.','LineStyle','none','Color','r','Tag','Threshdata');        
    end%     
    set(handles.EventCount,'String',[num2str(length(Idx)) ' events']);
end;
    
    

% --- Executes on mouse press over axes background.
function MiniPlot_ButtonDownFcn(hObject, eventdata, handles)

global Yax
global ThreshLine;
global Selection
global times;
global diffsel
global Idx;


buttonclick=get(gcf,'SelectionType');
ax = get(hObject, 'Parent');
pt = get(ax, 'CurrentPoint');

if strcmp(buttonclick,'normal')    
    Yax=[pt(1,2)];         
    Xax=xlim;
    try
        killhand=findobj(gca,'Tag','ThreshLine');
        delete(killhand);
        killhand=findobj(gca,'Tag','Threshdata');    
        delete(killhand);
        killhand=findobj(handles.dIplot,'Tag','Threshline');
        delete(killhand);
    catch
    end;
    
    ThreshLine=line(Xax(1):0.01:Xax(2),Yax(1),'Color','r','LineStyle','-','Tag','ThreshLine');
               
    if mean(Selection)<Yax
        
    elseif mean(Selection)>Yax
        [Idx]=find(Selection<Yax);        
        line(times(Idx),Selection(Idx),'Marker','.','LineStyle','none','Color','r','Tag','Threshdata');
        a=find(diff(Idx)>5);
        temp=Idx(1);
        Idx=Idx(a);
        Idx=[temp;Idx];            
    end
    set(handles.EventCount,'String',[num2str(length(Idx)) ' events']);
end;
 

% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
global Selection
global times;
global Yax;
global Idx;
global AmpSave;
global FreqSave;
    
dt=times(2)-times(1); 

% %SubtractedSelection=Selection-mean(Selection); % detrend;
% Thresh=Yax; %-mean(Selection);

% if mean(Selection)<Thresh
%     Idxs=find(Selection>Thresh);    
% elseif mean(Selection)>Thresh
%     Idxs=find(Selection<Thresh);
% end;


% keyboard;

% a=find(diff(Idxs)>12);
% temp=Idxs(1);
% Idxs=Idxs(a+1);
% Idxs=[temp;Idxs]; 

Idxs=Idx;

hold on;
axes(handles.dIplot);
% times=0:dt:Data.dt*length(Selection);
cla;
line(times,Selection,'LineStyle','-','Color','b');
line(times(Idxs),Selection(Idxs),'Marker','o','LineStyle','none','Color','r','Tag','Threshdata');
eventtime=(0:dt:dt*600)*1000;
%eventtime=eventtime*1000; %in ms;

cla(handles.AcceptFig);  % There are still some 
cla(handles.RejectFig);

start=find(Idxs>200);
stop=find(Idxs>length(Selection)-401);
killidx=1:start;
Idxs(stop)=[];

for i=start:length(Idxs-2);    
    disp(Idxs(i))
    [Amp(i) Offset]=min(Selection(Idxs(i):Idxs(i)+150)); %thresh detects upstroke, so peak will be in the 5 ms preceding. 
    %Offset(i)=Offset(i);
    Idxs(i)=Idxs(i)+Offset;
    event(:,i)=Selection(Idxs(i)-200:Idxs(i)+400); 
    event(:,i)=event(:,i)-mean(event(1:10,i));
    
    Amp(i)=Amp(i)-mean(event(1:10,i)); % correct for baseline shifts;
    
     
%      if (mean(diff(event))) < -0.05 %reject uneven events
%         axes(handles.RejectFig);                  
%         line(eventtime,event-mean(event(1:10)),'Color','r','LineStyle','-','Tag',num2str('i'));
%         axes(handles.dIplot);
%         line(times(Idxs(i)),Selection(Idxs(i)),'LineStyle','none','Color','k','Marker','o');
%         killidx=[killidx i];
%           %keyboard;
%       keyboard;
        axes(handles.AcceptFig);         
        line(eventtime,event(:,i)-mean(event(1:10,i)),'Color','b','LineStyle','-','Tag',num2str('i'));
        axes(handles.dIplot);
        line(times(Idxs(i)),Selection(Idxs(i)),'LineStyle','none','Color','g','Marker','o');
%      end;
end;

        axes(handles.AcceptFig);         
        keyboard;
        line(eventtime,mean(event'),'Color','r','LineStyle','-','LineWidth',2,'Tag',num2str('i'));


Idxs(killidx)=[];
Amp(killidx)=[];

set(gca,'HitTest','On');

axes(handles.CumFreqFig);
Freq=(1./diff(Idxs*dt));


[h FreqStats]=cdfplot(Freq)
xlabel('Freq (Hz)');
axes(handles.CumAmpFig);
[h AmpStats]=cdfplot(abs(Amp))
Amp=Amp';
xlabel('Amplitude, pA')
open('Freq');
open('Amp');

keyboard
