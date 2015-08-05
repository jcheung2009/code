function varargout = UIChanSubtract(varargin)
% UICHANSUBTRACT M-file for UIChanSubtract.fig
%      UICHANSUBTRACT, by itself, creates a new UICHANSUBTRACT or raises the existing
%      singleton*.
%
%      H = UICHANSUBTRACT returns the handle to a new UICHANSUBTRACT or the handle to
%      the existing singleton*.
%
%      UICHANSUBTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UICHANSUBTRACT.M with the given input arguments.
%
%      UICHANSUBTRACT('Property','Value',...) creates a new UICHANSUBTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UIChanSubtract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UIChanSubtract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UIChanSubtract

% Last Modified by GUIDE v2.5 06-Mar-2013 15:27:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UIChanSubtract_OpeningFcn, ...
                   'gui_OutputFcn',  @UIChanSubtract_OutputFcn, ...
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
    
    global CtrlTrace;
    global SubTrace;

% --- Executes just before UIChanSubtract is made visible.
function UIChanSubtract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UIChanSubtract (see VARARGIN)

% Choose default command line output for UIChanSubtract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UIChanSubtract wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UIChanSubtract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoodNuff.
function GoodNuff_Callback(hObject, eventdata, handles)

        global ResultTrace;    
        global SubFileName;
        global FileName;
        
        if (~exist('./Subtracted'))
            mkdir('./Subtracted');
        end;
        FileOut=['./Subtracted/' FileName(1:end-4) 'Subtracted.mat'];
        data=ResultTrace.data;
        save(FileOut,'data');        
        


% --- Executes on button press in OrigTraceNewFile.
function OrigTraceNewFile_Callback(hObject, eventdata, handles)

        global CtrlTrace;
        global FileName;

        FileName=uigetfile('CtrlTrace');
        CtrlTrace=load(FileName);        
        set(handles.edit1,'String',FileName);
%         CtrlTrace.filtdata=bandpass(CtrlTrace.data,32000,600,9000);
        CtrlTrace.filtdata=CtrlTrace.data;
        
        update(hObject,handles);  

% --- Executes on button press in SubTraceNewFile.
function SubTraceNewFile_Callback(hObject, eventdata, handles)
        global SubTrace;
        global SubFileName;

        SubFileName=uigetfile('SubtraceTrace');
        SubTrace=load(SubFileName);        
        set(handles.edit2,'String',SubFileName);
%         SubTrace.filtdata=bandpass(SubTrace.data,32000,600,9000);

        SubTrace.filtdata=SubTrace.data;
  
        update(hObject,handles);
         
function update(hObject, handles)

% %     disp('a')
%      keyboard;
    global CtrlTrace;
    global SubTrace;
    global ResultTrace;    
    
    Fs=32000;
    
    dt=1/Fs;
    t=dt:dt:length(CtrlTrace.data)*dt;

    
    plot(handles.CtrlPlot,t,CtrlTrace.filtdata);
    plot(handles.SubtractPlot,t,SubTrace.filtdata);

    if length(CtrlTrace.data)==length(SubTrace.data);
        V=axis(handles.ResultPlot);
        cla(handles.ResultPlot);
        ResultTrace.filtdata=CtrlTrace.filtdata-SubTrace.filtdata;
        ResultTrace.data=CtrlTrace.data-SubTrace.data;
        plot(handles.ResultPlot,t,bandpass(ResultTrace.data,32000,900,6000));
        hold on;
        plot(handles.ResultPlot,t,bandpass(CtrlTrace.data,32000,900,6000),'r');
        if V(2)~=1
            axis(V);
        end;
    end;
    
    


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
