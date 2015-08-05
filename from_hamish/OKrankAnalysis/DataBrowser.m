function varargout = DataBrowser(varargin)
% DATABROWSER MATLAB code for DataBrowser.fig
%      DATABROWSER, by itself, creates a new DATABROWSER or raises the existing
%      singleton*.
%
%      H = DATABROWSER returns the handle to a new DATABROWSER or the handle to
%      the existing singleton*.
%
%      DATABROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABROWSER.M with the given input arguments.
%
%      DATABROWSER('Property','Value',...) creates a new DATABROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataBrowser

% Last Modified by GUIDE v2.5 15-Mar-2012 13:49:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @DataBrowser_OutputFcn, ...
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


% --- Executes just before DataBrowser is made visible.
function DataBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataBrowser (see VARARGIN)

handles.output = hObject;

% Update handles structure


set(handles.ChannelPlot,'ButtonDownFcn',@MainPlot_ButtonDownFcn);%(hObject, eventdata, handles));
guidata(hObject, handles);

global FileName;
global PathDir;


% --- Outputs from this function are returned to the command line.
function varargout = DataBrowser_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in NextChan.
function NextChan_Callback(hObject, eventdata, handles)

    global Path;
    global FileName;
    global Idx;
    global Data;
    global ExpType;
    global ChanNo;
    
    Idx=Idx+1;

    if Idx > ChanNo-1
        Idx=1;
    end;
    
    [Data Fs]=ReadOKrankDataFilt('./',FileName,Idx,900,9000);
    hand=plot(handles.ChannelPlot,Data);
    set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);%(hObject, eventdata, handles));
    set(handles.CurrentChannel,'String',num2str(Idx));

% --- Executes on button press in PrevChan.
function PrevChan_Callback(hObject, eventdata, handles)
    global Path;
    global FileName;
    global Idx;
    global Data;
    global ExpType;
    global ChanNo;
    
    Idx=Idx-1;
     
    if Idx < 1
        Idx=ChanNo-1;
    end;
    
        
    [Data Fs]=ReadOKrankDataFilt('./',FileName,Idx,900,9000);
    hand=plot(handles.ChannelPlot,Data);
    set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);
    set(handles.CurrentChannel,'String',num2str(Idx));

% --- Executes on button press in CallThreshold.
function CallThreshold_Callback(hObject, eventdata, handles)

    global Data;
    global Yax;
    
    
    UpperLim=Yax(1);
    LowerLim=Yax(2);
    
    ThreshCrossings=find(Data>UpperLim);
    killidx=find(diff(ThreshCrossings>2));
    keyboard
    


% --------------------------------------------------------------------
function OpenFile_ClickedCallback(hObject, eventdata, handles)

    global Path;
    global FileName;
    global Idx;
    global Data;  
    global Fs;
    global ChanNo;
    
    [FileName Path]=uigetfile('*','*.rec');

    if strfind(FileName,'.rec');
        FileName=FileName(1:end-4);
    end;
       
    Idx=1;
    [Song Fs ChanNo]=ReadOKrankData('./',FileName,0);
    plot(handles.SpectrogramPlot,Song);
    clear Song;
    [Data]=ReadOKrankData('./',FileName,Idx);
    plot(handles.ChannelPlot,Data);
    set(handles.FileName,'String',FileName);
    set(handles.CurrentChannel,'String',num2str(Idx));
    
   
    hand=plot(handles.ChannelPlot,Data);
    set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);

%     [spect freq time_song] = CalcPlotSpectrogram(Path,FileName,'okrank',handles.SpectrogramPlot);

% --- Executes on mouse press over axes background.
function MainPlot_ButtonDownFcn(hObject, eventdata, handles)


global Yax;
global Data;
global StartLine;
global EndLine;

buttonclick=get(gcf,'SelectionType');
ax = get(hObject, 'Parent');
pt = get(ax, 'CurrentPoint');


if strcmp(buttonclick,'normal')    
    Xax=xlim;       
    Yax=[pt(1,2) 0];
    try
        killhand=findobj(gca,'Tag','StartLine');
        delete(killhand);
    catch
    end;
    StartLine=line(Xax(1):Xax(2),Yax(1),'Color','r','LineWidth',4,'Tag','StartLine');
    
    
  elseif strcmp(buttonclick,'alt')
    try
        killhand=findobj(gca,'Tag','EndLine');
        delete(killhand);
    catch
    end;
      Xax=xlim;
      Yax(2)=pt(1,2);           
      StartLine=line(Xax(1):Xax(2),Yax(2),'Color','k','LineWidth',4,'Tag','EndLine');  
end;

% function Update_All(hObject,eventdata,handles)

%     set(handles.ChannelPlot,'ButtonDownFcn',@MainPlot_ButtonDownFcn);%(hObject, eventdata, handles));



function CurrentChannel_Callback(hObject, eventdata, handles)
    global Idx;
    global ChanNo;
    global Data;
    global FileName;
    
    NewChan=str2num(get(hObject,'string'));
    
    if NewChan > 1 && NewChan < ChanNo-1
        Idx=NewChan;
    end;
    

    
     [Data Fs]=ReadOKrankDataFilt('./',FileName,Idx,900,9000);
    plot(handles.ChannelPlot,Data);
    set(handles.FileName,'String',FileName);
    set(handles.CurrentChannel,'String',num2str(Idx));
    
    keyboard;    
