function varargout = FileViewer(varargin)
% FILEVIEWER M-file for FileViewer.fig
%      FILEVIEWER, by itself, creates a new FILEVIEWER or raises the existing
%      singleton*.
%
%      H = FILEVIEWER returns the handle to a new FILEVIEWER or the handle to
%      the existing singleton*.
%
%      FILEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEVIEWER.M with the given input arguments.
%
%      FILEVIEWER('Property','Value',...) creates a new FILEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FileViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FileViewer

% Last Modified by GUIDE v2.5 20-May-2013 16:04:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @FileViewer_OutputFcn, ...
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


% --- Executes just before FileViewer is made visible.
function FileViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileViewer (see VARARGIN)

% Choose default command line output for FileViewer
handles.output = hObject;

% Update handles structure

set(handles.MainPlot,'ButtonDownFcn',@MainPlot_ButtonDownFcn);
guidata(hObject, handles);

global FileName;
global PathDir;

% UIWAIT makes FileViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FileViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% keyboard

% --- Executes on button press in NextFile.
function NextFile_Callback(hObject, eventdata, handles)

    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    
    FileIdx=FileIdx+1;
    PathDir=dir([Path '/*.mat']);
    FileName=PathDir(FileIdx).name;
    set(handles.FileNameString,'String',FileName);    
    load([Path FileName])
    Data=output;

    ExpType=DataFileType(Data,FileName);    
    Update_All(handles);     

% --- Executes on button press in PrevFile.
function PrevFile_Callback(hObject, eventdata, handles)


    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;    
    
    FileIdx=FileIdx-1;
    PathDir=dir([Path '/*.mat']);
    FileName=PathDir(FileIdx).name;
    set(handles.FileNameString,'String',FileName);
    load([Path FileName])
    
    try
    Data=output;
    catch
        keyboard
    end;
    ExpType=DataFileType(Data,FileName);    
    Update_All(handles); 


% --------------------------------------------------------------------
function OpenFile_ClickedCallback(hObject, eventdata, handles)

    global Path;
    global FileName;
    global FileIdx;
    global Data;    
    global ExpType;
    
    [FileName Path]=uigetfile('*','*.mat');
    
    PathDir=dir([Path '/*.mat']);
    PathDir=char(PathDir.name); % extract filenames to char array for search;

    [FileIdx]=strmatch(FileName,PathDir); %get index. 
    
    load([Path FileName]);
    cd(Path);
    Data=output;

    ExpType=DataFileType(Data,FileName);    
dir
Update_All(handles); 

% --- Executes on button press in DecaysButton.
function DecaysButton_Callback(hObject, eventdata, handles)
    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax;
        
    a=find(Data.time>Xax(1));
    StartIdx=a(1);
    a=find(Data.time>Xax(2));
    StopIdx=a(1);
    clear a;

    dt=Data.time(2)-Data.time(1); 
    
    temp=Data.I{1}(StartIdx:StopIdx,:);
    PeakIdx=max(temp,2)';
    V=Data.Out(StartIdx,:)';
    x=(0:dt:dt*(StopIdx-StartIdx))';
    
    for i=1:size(temp,2)
        y=temp(:,i);
        [Amp(i) Tau(i) FitPlot]=ExpFitter(x,y);
        line(x+Xax(1),FitPlot,'Color','r','Tag','FitLine');
    end;
    
    Amp=Amp';
    Tau=Tau';
    open('V');
    open('Amp');
    open('Tau');
    keyboard;
    
    killhand=findobj(gca,'Tag','FitLine');
    delete(killhand);

% --- Executes on button press in IVButton.
function IVButton_Callback(hObject, eventdata, handles)
    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax    
        
    a=find(Data.time>Xax(1));
    StartIdx=a(1);
    a=find(Data.time>Xax(2));
    StopIdx=a(1);
    clear a;
        
    figure;
    hold on;    
    
    
    if strmatch(ExpType,'VC')
        Leak=mean(Data.I{1}(200:500,:));
        temp=Data.I{1}(StartIdx:StopIdx,:);
        xlabel('Voltage (mV)');
        ylabel('Current (pA)'); 
        IPeak=mean(temp)'-Leak';        
    elseif strmatch(ExpType,'IC');
        temp=Data.Vm{1}(StartIdx:StopIdx,:);
        ylabel('Voltage (pA)');
        xlabel('Current (mV)'); 
        IPeak=mean(temp)';        
    end;  

    
    V=Data.Out(StartIdx,:)';
    keyboard;
    plot(V,IPeak);


% --- Executes on button press in PeaksButton.
function PeaksButton_Callback(hObject, eventdata, handles)
    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax
    
    a=find(Data.time>Xax(1));
    StartIdx=a(1);
    a=find(Data.time>Xax(2));
    StopIdx=a(1);
    clear a;
    
    Baseline=mean(Data.I{1}(800:900,:))';
    
    temp=Data.I{1}(StartIdx:StopIdx,:);
    

    
    IPeak=max(temp)'-Baseline;
    IMin=min(temp)'-Baseline;
    
    V=Data.Out(StartIdx,:)';
    
    
    open('V');
    open('IPeak');    
    open('IMin'); 
    open('Baseline');
    keyboard;


% --- Executes on button press in KbdButton.
function KbdButton_Callback(hObject, eventdata, handles)
% 
global Data;
keyboard;


% --- Executes on button press in EPSCButton.
function EPSCButton_Callback(hObject, eventdata, handles)

    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax
 
    
      if ~exist('Data.dt')
          Data.dt=0.1;
      end;
    
%       if (isfield(Data,'data'))
%           Data.HVc=Data.data;
%           clear Data.data;
%       end;
      
      
      if isfield(Data,'lMAN');
          try                     
            time=Data.lMAN.time{1};            
            tempout=Data.lMAN.signal{1}';
          catch
              keyboard
%             time=Data.time;
         end;
%             
%             for i=1:size(Data.lMAN.signal,2)                                
%                tempout(:,i)=Data.lMAN.signal{i}';               
%             end;
%             
        a=find(time>Xax(1));
        StartIdx=a(1);
        a=find(time>Xax(2));
        StopIdx=a(1);
        clear a;
        
        temp=tempout(StartIdx:StopIdx,:);
        baseline=tempout(StartIdx-1000:StartIdx-400,:); % Immediately prior.
        baseline=mean(baseline)';
        [LMANPks LMANJit]=min(temp);                   
        [LMANmax]=max(temp)';
        LMANPks=LMANPks';
        LMANJit=LMANJit'*Data.dt;   
        LMANPks(:,2)=baseline;
        LMANPks(:,3)=LMANPks(:,1)-LMANPks(:,2);
%         LMANPks(:,4)=LMANmax-LMANPks(:,2);
        open('LMANPks');
        open('LMANJit');
        clear tempout;
     end;
     
    if (isfield(Data,'HVc'))
%         keyboard
%         tempout=Data.HVc.signal{1}';  
        
          if isfield(Data,'HVc.time');
            if iscell(Data.HVc.time')  
                time=Data.HVc.time{1};   
                tempout=Data.HVc.signal{1}';                
            else
                time=Data.HVc.time;
                tempout=Data.HVc.signal{1}'; 
            end
          else
             
              tempout=Data.HVc.signal{1}';
             
            
         end;
%        elseif isfield(Data,'time')
% 
%            time=Data.time;
%           end;
% 
%          
        a=find(time>Xax(1));
        StartIdx=a(1);
        a=find(time>Xax(2));
        StopIdx=a(1);
        clear a;       

        temp=tempout(StartIdx:StopIdx,:);
        baseline=tempout(StartIdx-1000:StartIdx-400,:); % Immediately prior.
        baseline=mean(baseline)';

        [HVcPks HVcJit]=min(temp);    
        [HVcmax]=max(temp)';
        HVcPks=HVcPks';
        
        HVcPks(:,2)=baseline;
        HVcPks(:,3)=HVcPks(:,1)-HVcPks(:,2);

        HVcPks(:,4)=HVcmax-baseline;
        HVcJit=HVcJit'*Data.dt;
        open('HVcJit');
        open('HVcPks');
        
    end;

      
      if isfield(Data,'Vm');
        Data.lMAN.signal=Data.Vm;
          
        time=Data.time;            
            
            for i=1:size(Data.lMAN.signal,2)                                
               tempout(:,i)=Data.lMAN.signal{i}';               
            end;
            
        a=find(time>Xax(1));
        StartIdx=a(1);
        a=find(time>Xax(2));
        StopIdx=a(1);
        clear a;
        
        temp=tempout(StartIdx:StopIdx,:);
        baseline=tempout(StartIdx-1000:StartIdx-400,:); % Immediately prior.
        baseline=mean(baseline)';
        LMANPks=min(temp)';                   
        LMANPks(:,2)=baseline;
        LMANPks(:,3)=LMANPks(:,1)-LMANPks(:,2);
        open('LMANPks');
        clear Data.lMAN;
     end;
      
      
          keyboard;
        
    

    
% --- Executes on button press in PPRButton.
function PPRButton_Callback(hObject, eventdata, handles)
   global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax
 
    
      if isfield(Data,'lMAN');
          
        time=Data.lMAN.time{1};            
            
%             for i=1:size(Data.lMAN.signal,2)                                
%                tempout(:,i)=Data.lMAN.signal{i}';               
%             end;
        tempout=Data.lMAN.signal{1}';
           
        a=find(time>Xax(1));
        StartIdx=a(1);
        a=find(time>Xax(2));
        StopIdx=a(1);
        clear a;
%         
%         keyboard;
        
        temp=tempout(StartIdx-50:StartIdx+50,:);
        baseline=tempout(1:1000,:); % Beginning of Trace
        baseline=mean(baseline)';        

        LMANPks(:,1)=min(temp)'-baseline;   
        temp=tempout(StopIdx-50:StopIdx+50,:);                
        LMANPks(:,2)=min(temp)'-baseline;          
        LMANPks(:,3)=LMANPks(:,2)./LMANPks(:,1);                  
        open('LMANPks');
     end;
       

     if isfield(Data,'HVc');
            time=Data.HVc.time{1};              
%             for i=1:size(Data.HVc.signal,2)      
%                tempout(:,i)=Data.HVc.signal{i}';               
%             end;
        tempout=Data.HVc.signal{1}';
        
        a=find(time>Xax(1));
        StartIdx=a(1);
        a=find(time>Xax(2));
        StopIdx=a(1);
        clear a;       

        temp=tempout(StartIdx-50:StartIdx+50,:);
        baseline=tempout(1:1000,:); % Beginning of Trace
        baseline=mean(baseline)';        
        HVcPks(:,1)=min(temp)'-baseline;   
        temp=tempout(StopIdx-50:StopIdx+50,:);                
        HVcPks(:,2)=min(temp)'-baseline;          
        HVcPks(:,3)=HVcPks(:,2)./HVcPks(:,1);    
        open('HVcPks');
        
      end;    
      
      keyboard;


% --- Executes on button press in MinisMenu.
function MinisMenu_Callback(hObject, eventdata, handles)
    global Data;
    global Xax;
    
    selection=Data.Vm(Xax(1)/Data.dt:Xax(2)/Data.dt);
    
    MiniMenu(selection); 
    

% --- Executes on button press in AvgButton.
function AvgButton_Callback(hObject, eventdata, handles)
% hObject    handle to AvgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global Data;
    global Xax;
    
    if isfield(Data,'Vm')
        selection=Data.Vm(Xax(1)/Data.dt:Xax(2)/Data.dt);
        AvgTween=mean(Data.Vm(Xax(1)/Data.dt:Xax(2)/Data.dt));
        set(handles.AvgAnswer,'String',num2str(AvgTween)); 
        RootMean=RMS(Data.Vm(Xax(1)/Data.dt:Xax(2)/Data.dt));
        set(handles.RMSOut,'String',num2str(RootMean));
    end;
    
    if isfield(Data,'HVc')
        temp=output.HVc.signal{1}
        for i=10:length(length(output.HVc.signal));
           temp=temp+(output.HVc.signal{i});
        end;
        
        temp=temp./length(length(output.HVc.signal));   
    end;
     
    if isfield(Data,'lMAN');
        selection=Data.lMAN(Xax(1)/Data.dt:Xax(2)/Data.dt);
        temp=output.lMAN.signal{1}
        for i=10:length(length(output.lMAN.signal));
         temp=temp+output.lMAN.signal{i};
        end;
        temp=temp./length(length(output.lMAN.signal));   
    end;

    


% --- Executes during object creation, after setting all properties.
function RMSOut_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DeltaTButton.
function DeltaTButton_Callback(hObject, eventdata, handles)

    global Xax
    
    DeltaT=(Xax(2)-Xax(1));
    set(handles.TimeText,'String',num2str(DeltaT));


% --- Executes on button press in FIButton.
function FIButton_Callback(hObject, eventdata, handles)

    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax

    dt=Data.time(2)-Data.time(1);
    Idx=round(Xax/dt);
    Traces=Data.Vm{1}(Idx(1):Idx(2),:);     
    I=mean(Data.Out(Idx(1)+150:Idx(2)-150,:));
    
    figure;    
    
 
    ColOrd = get(gca,'ColorOrder');
    [m,n] = size(ColOrd);
    hold on

    
    
    for i=1:size(Traces,2);

        ColRow = rem(i,m);
        if ColRow == 0
        ColRow = m;
        end

        % Get the color
        Col = ColOrd(ColRow,:);
        
        [Times{i} Freq{i} ISI{i}]=SpikeTimes(Traces(:,i),0.1,0);
        FreqOut(i)=mean(Freq{i});
        AdaptFig=plot(1:length(Freq{i}),Freq{i},'Color',Col);
        hold on;
        legend(AdaptFig,num2str(I(i)));        
        
     end;
    
    figure;
    title('FI');
    plot(I,FreqOut);
    xlabel('pA');
    ylabel('freq (Hz');
    
    keyboard;



function AbsMax_Callback(hObject, eventdata, handles)
    % hObject    handle to TimeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax    
        
    a=find(Data.time>Xax(1));
    StartIdx=a(1);
    a=find(Data.time>Xax(2));
    StopIdx=a(1);
    clear a;
        
    figure;
    hold on;    
    
    if strmatch(ExpType,'VC')
        temp=Data.I{1}(StartIdx:StopIdx,:);
        base=mean(Data.I{1}(5000:7500,:))';        
        xlabel('Voltage (mV)');
        ylabel('Current (pA)');                 
        a=bsxfun(@minus,temp,base')
        [IPeak id]=max(abs(a));
        g=0:length(base)-1;    
        g=(g'*length(a))+id';                
        IPeak=a(g);

    elseif strmatch(ExpType,'IC');
        temp=Data.Vm{1}(StartIdx:StopIdx,:);
        base=mean(Data.Vm{1}(StartIdx-500:StartIdx-250,:))';        
        ylabel('Voltage (pA)');
        xlabel('Current (mV)'); 
        IPeak=mean(temp)';        
    end;  

    V=Data.Out(StartIdx,:)';
    plot(V,IPeak);    
    
%     open(V);
%     open(IPeak);
    assignin('base', 'V', V);
    assignin('base', 'IPeak', IPeak);
    keyboard;

% --- Executes on button press in Export.
function Export_Callback(hObject, eventdata, handles)

hand=figure;
temp=copyobj(handles.MainPlot,hand)


% --- Executes on button press in ExportStimPlot.
function ExportStimPlot_Callback(hObject, eventdata, handles)
hand=figure;
temp=copyobj(handles.StimPlot,hand)



% --- Executes during object creation, after setting all properties.
function TimeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function AvgAnswer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AvgAnswer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Untitled_1_Callback(hObject, eventdata, handles)