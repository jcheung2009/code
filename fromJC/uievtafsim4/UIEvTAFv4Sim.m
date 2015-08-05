function varargout = UIEvTAFv4Sim(varargin)
% UIEVTAFV4SIM M-file for UIEvTAFv4Sim.fig
%   RUN AS UIEvTAFv4Sim(batchfile,NoteDetectStruct);
%   if NoteDetectStruct is a strucutre of size > 1 then the first index is
%   taken.  To simulate the second index (for example) use :
%       UIEvTAFv4Sim('batch',ND(2));

%      UIEVTAFV4SIM, by itself, creates a new UIEVTAFV4SIM or raises the existing
%      singleton*.
%
%      H = UIEVTAFV4SIM returns the handle to a new UIEVTAFV4SIM or the handle to
%      the existing singleton*.
%
%      UIEVTAFV4SIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIEVTAFV4SIM.M with the given input arguments.
%
%      UIEVTAFV4SIM('Property','Value',...) creates a new UIEVTAFV4SIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UIEvTAFv4Sim_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UIEvTAFv4Sim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UIEvTAFv4Sim

% Last Modified by GUIDE v2.5 17-Aug-2009 10:51:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UIEvTAFv4Sim_OpeningFcn, ...
                   'gui_OutputFcn',  @UIEvTAFv4Sim_OutputFcn, ...
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
return;

% --- Executes just before UIEvTAFv4Sim is made visible.
function UIEvTAFv4Sim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UIEvTAFv4Sim (see VARARGIN)

% Choose default command line output for UIEvTAFv4Sim
handles.output = hObject;

fid=fopen(varargin{1},'r');
if (fid==-1)
    disp(['Bad batchfile']);
    return;
end

ind=0;
while (1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    if (~exist(fn,'file'))
        continue;
    end
    ind=ind+1;
    files{ind}=fn;
end
if (ind <1)
    disp(['No input files found']);
    return;
end

%FIX HERE
ND=varargin{2};
if (length(ND)>1)
    disp(['USEING THE FIRST INDEX OF A MULTIPLE ELEMENT NoteDetect Strucutre (input 2)']);
    disp(['If THIS IS NOT WHAT YOU WANT CALL THE PROGRAM WITH THE NoteDetect INDEXED']);
    disp(['e.g. UIEvTAFv4Sim(''batch'',ND(2));']);
end

ND=ND(1);
templates = ND.Templ;
tmp=CounterSetupv4(ND);
ND=tmp;
handles.ND=tmp;
handles.Templ = templates;

handles.NTempl = size(templates,2);
handles.TemplLen = size(templates,1);
set(handles.NTemplBox,'String',num2str(handles.TemplLen));

handles.files=files;
handles.Nfile=1;
handles.CHANSPEC=get(handles.ChanSpecBox,'String');
handles.SEGTH=str2num(get(handles.SegThreshBox,'String'));
handles.USEXTMP=0;
set(handles.SPMinLevel,'Value',0.7);
set(handles.SPMaxLevel,'Value',1);
handles.REFRAC=str2num(get(handles.RefracPerBox,'String'));

handles.TrigT=[];
handles.TRIGPLT=-1;
guidata(hObject, handles);

UIEvTAFv4Sim_PlotData(hObject,handles);
handles=guidata(hObject);

axes(handles.ValAxes);ylim([0,5]);
linkaxes([handles.SpecGramAxes,handles.LabelAxes,handles.ValAxes],'x');
% UIWAIT makes UIEvTAFv4Sim wait for user response (see UIRESUME)
uiwait(handles.UIEvTAFv4Sim);
return;

% --- Outputs from this function are returned to the command line.
function varargout = UIEvTAFv4Sim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.UIEvTAFv4Sim);
return;

% --- Executes on button press in PrevFileBtn.
function PrevFileBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PrevFileBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.Nfile>1)
    handles.Nfile=handles.Nfile-1;
    uievtafsim_plot(hObject,handles);
end
return;

% --- Executes on button press in NextFileBtn.
function NextFileBtn_Callback(hObject, eventdata, handles)
% hObject    handle to NextFileBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.Nfile<length(handles.files))
    handles.Nfile=handles.Nfile+1;
    uievtafsim_plot(hObject,handles);
end
return;

% --- Executes on button press in MoveRightBtn.
function MoveRightBtn_Callback(hObject, eventdata, handles)
% hObject    handle to MoveRightBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.SpecGramAxes);
v=axis;
xlim(v(1:2)-0.9*(v(2)-v(1)));
return;

% --- Executes on button press in MoveLeftBtn.
function MoveLeftBtn_Callback(hObject, eventdata, handles)
% hObject    handle to MoveLeftBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.SpecGramAxes);
v=axis;
xlim(v(1:2)+0.9*(v(2)-v(1)));
return;

% --- Executes on button press in SkipToFileBtn.
function SkipToFileBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SkipToFileBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[nf,canc]=SkipToFile(handles.files,handles.Nfile);
if (canc==0)
    handles.Nfile=nf;
    uievtafsim_plot(hObject,handles);
end
return;

function SegThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to SegThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SegThreshBox as text
%        str2double(get(hObject,'String')) returns contents of SegThreshBox as a double

handles.SEGTH=str2num(get(handles.SegThreshBox,'String'));
guidata(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function SegThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SegThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --- Executes on button press in ZoomOnBtn.
function ZoomOnBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOnBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on;
return;

% --- Executes on button press in PanOnBtn.
function PanOnBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PanOnBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan xon;
return;

function ChanSpecBox_Callback(hObject, eventdata, handles)
% hObject    handle to ChanSpecBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChanSpecBox as text
%        str2double(get(hObject,'String')) returns contents of ChanSpecBox
%        as a double

handles.CHANSPEC=get(handles.ChanSpecBox,'String');
guidata(hObject,handles);
uievtafsim_plot(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function ChanSpecBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChanSpecBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes on button press in ZoomXonBtn.
function ZoomXonBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomXonBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off;
zoom xon;
return;

% --- Executes on button press in ReplotBtn.
function ReplotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ReplotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uievtafsim_plot(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function FileNumBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNumBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes on button press in QuitBtn.
function QuitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to QuitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.UIEvTAFv4Sim);
return;

% --- Executes on button press in UseSim.
function UseSim_Callback(hObject, eventdata, handles)
% hObject    handle to UseSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseSim

PlotTafVals(hObject,handles);

return;

% --- Executes on button press in SetCntrBtn.
function SetCntrBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SetCntrBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tmp=CounterSetup(handles.ND);
handles=guidata(hObject);
handles.ND=tmp;
guidata(hObject,handles);

uievtafsim_plot(hObject,handles);

return;

% --- Executes on button press in UseXTmpFile.
function UseXTmpFile_Callback(hObject, eventdata, handles)
% hObject    handle to UseXTmpFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseXTmpFile

if (get(hObject,'Value')==get(hObject,'Max'))
    handles.USEXTMP=1;
    guidata(hObject, handles);
else
    handles.USEXTMP=0;
    guidata(hObject, handles);
end
PlotTafVals(hObject,handles);
return;

% --- Executes on slider movement.
function SPMinLevel_Callback(hObject, eventdata, handles)
% hObject    handle to SPMinLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if (get(handles.SPMinLevel,'Value')<get(handles.SPMaxLevel,'Value'))
    axes(handles.SpecGramAxes);
    temp1=get(handles.SPMinLevel,'Value');temp2=get(handles.SPMaxLevel,'Value');
    mn=handles.SPMin;mx=handles.SPMax;
    caxis([temp1*(mx-mn)+mn,temp2*mx]);
else
    set(handles.SPMinLevel,'Value',.999*get(handles.SPMaxLevel,'Value'));
end
return;

% --- Executes during object creation, after setting all properties.
function SPMinLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPMinLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;

% --- Executes on slider movement.
function SPMaxLevel_Callback(hObject, eventdata, handles)
% hObject    handle to SPMaxLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if (get(handles.SPMaxLevel,'Value')>get(handles.SPMinLevel,'Value'))
    axes(handles.SpecGramAxes);
    temp1=get(handles.SPMinLevel,'Value');temp2=get(handles.SPMaxLevel,'Value');
    mn=handles.SPMin;mx=handles.SPMax;
    caxis([temp1*(mx-mn)+mn,temp2*mx]);
else
    set(handles.SPMaxLevel,'Value',1.001*get(handles.SPMinLevel,'Value'));
end
return;

% --- Executes during object creation, after setting all properties.
function SPMaxLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPMaxLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;


% --- Executes on button press in WrtRecFile.
function WrtRecFile_Callback(hObject, eventdata, handles)
% hObject    handle to WrtRecFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return;

function RefracPerBox_Callback(hObject, eventdata, handles)
% hObject    handle to RefracPerBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefracPerBox as text
%        str2double(get(hObject,'String')) returns contents of RefracPerBox as a double

handles.REFRAC=str2num(get(handles.RefracPerBox,'String'));
guidata(hObject, handles);
PlotTafVals(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function RefracPerBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefracPerBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function NTemplBox_Callback(hObject, eventdata, handles)
% hObject    handle to NTemplBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NTemplBox as text
%        str2double(get(hObject,'String')) returns contents of NTemplBox as a double

handles.TemplLen=str2num(get(handles.NTemplBox,'String'));
guidata(hObject, handles);
PlotTafVals(hObject,handles);
return;

% --- Executes during object creation, after setting all properties.
function NTemplBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NTemplBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

