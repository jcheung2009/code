function varargout = SpikeSortGuiM(varargin)
% = SpikeSortGuiM(idx,snippets,[ICAcomp])
%
% SPIKESORTGUIM M-file for SpikeSortGuiM.fig
%      SPIKESORTGUIM, by itself, creates a new SPIKESORTGUIM or raises the existing
%      singleton*.
%
%      H = SPIKESORTGUIM returns the handle to a new SPIKESORTGUIM or the handle to
%      the existing singleton*.
%
%      SPIKESORTGUIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKESORTGUIM.M with the given input arguments.
%
%      SPIKESORTGUIM('Property','Value',...) creates a new SPIKESORTGUIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeSortGuiM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeSortGuiM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpikeSortGuiM

% Last Modified by GUIDE v2.5 15-Jun-2011 14:14:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeSortGuiM_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeSortGuiM_OutputFcn, ...
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

% --- Executes just before SpikeSortGuiM is made visible.
function SpikeSortGuiM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeSortGuiM (see VARARGIN)

% Choose default command line output for SpikeSortGuiM
handles.output = hObject;

%%%MY CODE
handles.idx = varargin{1};
handles.snippets = varargin{2};
if(length(varargin) == 3) %we were given the ica components
    handles.icacmp = varargin{3};
else
    handles.icacmp = [];
end
handles.originalidx = handles.idx;
handles.uidx = unique(handles.idx);
handles.listSingle = zeros(size(handles.uidx));
handles.toResort = 0;
%bits for plotting
handles.waveMax = max(max(handles.snippets));
handles.waveMin = min(min(handles.snippets));
handles.colorCodes = {'r','b','g','c','y','m','k','k','k','k','k','k','k','r','b','g','c','y','m','k','k','k','k','k','k','k','r','b','g','c','y','m','k','k','k','k','k','k','k','r','b','g','c','y','m','k','k','k','k','k','k','k'};
handles.colorDotCodes = {'.r','.b','.g','.c','.y','.m','.k','.k','.k','.k','.k','.k','.k','.r','.b','.g','.c','.y','.m','.k','.k','.k','.k','.k','.k','.k','r','b','g','c','y','m','k','k','k','k','k','k','k','r','b','g','c','y','m','k','k','k','k','k','k','k'};
handles.selectedPerm = randperm(sum(handles.idx == handles.uidx(get(handles.menuMainSpike, 'Value'))));
handles.selectedCounter = 1;
handles.curMax = handles.waveMax;
handles.curMin = handles.waveMin;
updateLists(handles)
%%%/MY CODE


% Update handles structure
guidata(hObject, handles);


% This sets up the initial plot - only do when we are invisible
% so window can get raised using SpikeSortGuiM.
if strcmp(get(hObject,'Visible'),'off')
    updateAllPlots(handles);
end

% UIWAIT makes SpikeSortGuiM wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpikeSortGuiM_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;

%apparently I can't get output working
varargout{1} = handles.uidx;
varargout{2} = handles.idx;
varargout{3} = handles.listSingle;
varargout{4} = '0 - unclassified, 1 - Single Unit, 2 - Multi Unit, 3 - noise';
varargout{5} = handles.toResort;
delete(handles.figure1)


% --- Executes on button press in buttonResort.
function buttonResort_Callback(hObject, eventdata, handles)
% hObject    handle to buttonResort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.idx = handles.originalidx;
handles.uidx = unique(handles.idx);
handles.listSingle = zeros(size(handles.uidx));
% Update handles structure
guidata(hObject, handles);
updateAllPlots(handles);
updateLists(handles);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
uiresume(handles.figure1);


% --- Executes on selection change in menuMainSpike.
function menuMainSpike_Callback(hObject, eventdata, handles)
% hObject    handle to menuMainSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menuMainSpike contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menuMainSpike
handles.selectedPerm = randperm(sum(handles.idx == handles.uidx(get(handles.menuMainSpike, 'Value'))));
handles.selectedCounter = 1;
guidata(hObject,handles)
updateCompPlot(handles)
updateWaveformPlot(handles)


% --- Executes during object creation, after setting all properties.
function menuMainSpike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menuMainSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in menuSecondarySpike.
function menuSecondarySpike_Callback(hObject, eventdata, handles)
% hObject    handle to menuSecondarySpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menuSecondarySpike contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menuSecondarySpike
updateCompPlot(handles);


% --- Executes during object creation, after setting all properties.
function menuSecondarySpike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menuSecondarySpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonCombine.
function buttonCombine_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%find the id's of selector one and two
popup_sel_index = get(handles.menuMainSpike, 'Value');
idxMain = handles.uidx(popup_sel_index);
popup_sel_index = get(handles.menuSecondarySpike, 'Value');
if(popup_sel_index ~= 1)
    idxSecond = handles.uidx(popup_sel_index-1);
    % relabel idx2's to idx1's
    handles.idx(handles.idx == idxSecond) = idxMain;
    % update data
    handles.uidx = unique(handles.idx); %refresh idx list
    %wipe all classifications
    handles.listSingle = zeros(size(unique(handles.idx)));
%     handles.listSingle = handles.listSingle(handles.uidx ~= idxSecond); %remove idx classification
    set(handles.togglePlotSingle,'value',1); %turn of single plotting

    updateAllPlots(handles);
    updateLists(handles);
    handles.selectedPerm = randperm(sum(handles.idx == handles.uidx(get(handles.menuMainSpike, 'Value'))));
    handles.selectedCounter = 1;
    % Update handles structure
    guidata(hObject, handles);
end
    
% --- Executes on button press in buttonSingleUnit.
function buttonSingleUnit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSingleUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popup_sel_index = get(handles.menuMainSpike, 'Value');
handles.listSingle(popup_sel_index) = 1;
% Update handles structure
guidata(hObject, handles);
updateLists(handles);

% --- Executes on button press in buttonMultiUnit.
function buttonMultiUnit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonMultiUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popup_sel_index = get(handles.menuMainSpike, 'Value');
handles.listSingle(popup_sel_index) = 2;
% Update handles structure
guidata(hObject, handles);
updateLists(handles);

% --- Executes on button press in buttonNoise.
function buttonNoise_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popup_sel_index = get(handles.menuMainSpike, 'Value');
handles.listSingle(popup_sel_index) = 3;
% Update handles structure
guidata(hObject, handles);
updateLists(handles);

% --- Executes on button press in buttonSaveAndQuit.
function buttonSaveAndQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveAndQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(1,'please resort this channel\n');
handles.toResort = 1;
guidata(hObject,handles);
% idx = handles.idx;
% uidx = handles.uidx;
% isSingleUnit = handles.listSingle;
% singleUnitDescriptions = '0 - unclassified, 1 - Single Unit, 2 - Multi Unit, 3 - noise';
% save('temp','idx','uidx','isSingleUnit','singleUnitDescriptions');

% --- Executes on button press in buttonQuit.
function buttonQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(sum(handles.listSingle == 0))
    selection = questdlg('Continue without classifying all units?',...
                         'Unclassified Units',...
                         'Yes','No','No');
    if strcmp(selection,'No')
        return;
    end
end
uiresume(handles.figure1);


% --- Executes on button press in buttonSwitch.
function buttonSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popup_sel_index1 = get(handles.menuMainSpike, 'Value');
popup_sel_index2 = get(handles.menuSecondarySpike, 'Value');
if(popup_sel_index1 ~= popup_sel_index2-1 && popup_sel_index2 ~= 1)
    set(handles.menuMainSpike,'Value',popup_sel_index2-1);
    set(handles.menuSecondarySpike,'Value',popup_sel_index1+1);
    handles.selectedPerm = randperm(sum(handles.idx == handles.uidx(popup_sel_index2-1)));
    handles.selectedCounter = 1;
    
    updateCompPlot(handles);
    updateWaveformPlot(handles);
    guidata(hObject,handles)
end

% --- utility function to update comparison plot
function updateCompPlot(handles)
numWaveformsToPlot = 500;
%handles - the structure with handles and user data
hold(handles.axesSelectWaveform,'off');
firstIndex = get(handles.menuMainSpike, 'Value');
secondIndex = get(handles.menuSecondarySpike, 'Value')-1;

%indicies to plot of waveform
plotIndicies = 1:size(handles.snippets,2);

%update stationarity plot
if(secondIndex ~= 0)
    plot(handles.axesStationarity,find(handles.idx == handles.uidx(secondIndex)),min(handles.snippets(handles.idx == handles.uidx(secondIndex),plotIndicies),[],2),'.r'); %
    hold(handles.axesStationarity,'on');
end
plot(handles.axesStationarity,find(handles.idx == handles.uidx(firstIndex)),min(handles.snippets(handles.idx == handles.uidx(firstIndex),plotIndicies),[],2),'.b'); %
hold(handles.axesStationarity,'off');

%update plots of waveforms

% get number of waveforms
numWaves = sum(handles.idx == handles.uidx(firstIndex));
% determine indicies within that list
accessIdx = ceil(numWaves*rand(1,min(numWaveformsToPlot,numWaves)));   
% generate the list of snippets with that idx
lists = handles.snippets(handles.idx == handles.uidx(firstIndex),:);
% plot the random subset of that idx
plot(handles.axesSelectWaveform,plotIndicies,lists(accessIdx,plotIndicies)','b');

if(secondIndex ~= 0)
    hold(handles.axesSelectWaveform,'on');
    % get number of waveforms
    numWaves = sum(handles.idx == handles.uidx(secondIndex));
    % determine indicies within that list
    accessIdx = ceil(numWaves*rand(1,min(numWaveformsToPlot,numWaves)));   
    % generate the list of snippets with that idx
    lists = handles.snippets(handles.idx == handles.uidx(secondIndex),:);
    % plot the random subset of that idx
    plot(handles.axesSelectWaveform,plotIndicies,lists(accessIdx,plotIndicies)','r');
end
set(handles.axesSelectWaveform,'ylim',[handles.curMin handles.curMax]);
% %update probability text
% if(secondIndex == 0)
%     p = 0;
% else
%     [h,p] = ttest2(handles.snippets(handles.idx == handles.uidx(firstIndex),:),handles.snippets(handles.idx == handles.uidx(secondIndex),:));
%     p = log(prod(p));
% end
% set(handles.textP2P1,'String',['logP(Secondary|Main) = ',num2str(p)]);

% --- utility function to update the plot that normally holds all waveforms
function updateWaveformPlot(handles)
%handles - the structure with handles and user data

%update list of units
set(handles.textP2P1,'text',[num2str(sum(handles.idx == handles.uidx(get(handles.menuMainSpike, 'Value')))),' events']);
% plot(handles.axesISI,

numWaveformsToPlot = 500;
%indicies to plot of waveform
plotIndicies = 1:size(handles.snippets,2);
%plot all overlapping waveforms
hold(handles.axesAllWaveforms,'off');
if(get(handles.togglePlotSingle,'Value')) %value of 1 plots a single waveform
    indicies = find(handles.idx == handles.uidx(get(handles.menuMainSpike, 'Value')));
    plot(handles.axesAllWaveforms,mean(handles.snippets(indicies,plotIndicies),1),'b');
    hold(handles.axesAllWaveforms,'on')
    plot(handles.axesAllWaveforms,handles.snippets(indicies(handles.selectedPerm(handles.selectedCounter)),plotIndicies),'k');
else
    for i = 1:length(handles.uidx);
        if(get(handles.togglePlotMean,'Value'))%plot the mean waveform or plot many waveforms
            plot(mean(handles.snippets(handles.idx == handles.uidx(i),plotIndicies),1),handles.colorCodes{i},'parent',handles.axesAllWaveforms)
        else
            % get number of waveforms
            numWaves = sum(handles.idx == handles.uidx(i));
            % determine indicies within that list
            accessIdx = ceil(numWaves*rand(1,min(numWaveformsToPlot,numWaves)));   
            % generate the list of snippets with that idx
            lists = handles.snippets(handles.idx == handles.uidx(i),:);
            % plot the random subset of that idx
            plot(lists(accessIdx,plotIndicies)', handles.colorCodes{i},'parent',handles.axesAllWaveforms);
        end
        hold(handles.axesAllWaveforms,'on');
    end
end
set(handles.axesAllWaveforms,'ylim',[handles.curMin handles.curMax]);


% --- utility function to update all plots
function updateAllPlots(handles)
%handles - the structure with handles and user data
numWaveformsToPlot = 500;

%set up pulldown menus
plotLabels = cell(1,length(handles.uidx)+1);
plotLabels{1} = 'None';
for i = 1:length(handles.uidx)
    plotLabels{i+1} = num2str(handles.uidx(i));
end
set(handles.menuMainSpike, 'String', plotLabels(2:end));
set(handles.menuSecondarySpike, 'String', plotLabels);
%plot first waveform, don't plot second yet
set(handles.menuMainSpike, 'Value',1);
set(handles.menuSecondarySpike, 'Value',1);

updateCompPlot(handles);
updateWaveformPlot(handles);

%plot the ICA components if given
if(~isempty(handles.icacmp))
    handlesList = [handles.axesICA12,handles.axesICA13,handles.axesICA14,handles.axesICA15;
                   0                ,handles.axesICA23,handles.axesICA24,handles.axesICA25;
                   0                ,0                ,handles.axesICA34,handles.axesICA35;
                   0                ,0                ,0                ,handles.axesICA45;];
    for i = 1:4
        for j = i:4 %note this is offset by one
            hold(handlesList(i,j),'off');
            for k = 1:length(handles.uidx)
                % get number of waveforms
                numWaves = sum(handles.idx == handles.uidx(k));
                % determine indicies within that list
                accessIdx = ceil(numWaves*rand(1,min(numWaveformsToPlot,numWaves)));   
                % combine the components of interest
                lists = [handles.icacmp(handles.idx == handles.uidx(k),i), handles.icacmp(handles.idx == handles.uidx(k),j+1)];
                % plot the subset of those components
                plot(lists(accessIdx,1),lists(accessIdx,2), handles.colorDotCodes{k},'parent',handlesList(i,j));
                hold(handlesList(i,j),'on');
            end
        end
    end
end

% --- utility function to update the text lists
function updateLists(handles)
%handles - handles to components and data

str = sprintf('Unsorted: %s',sprintf('%d ',handles.uidx(handles.listSingle == 0)));
set(handles.textUnsorted,'String',str);
str = sprintf('Sinlge: %s',sprintf('%d ',handles.uidx(handles.listSingle == 1)));
set(handles.textSingle,'String',str);
str = sprintf('Multi: %s',sprintf('%d ',handles.uidx(handles.listSingle == 2)));
set(handles.textMulti,'String',str);
str = sprintf('Noise: %s',sprintf('%d ',handles.uidx(handles.listSingle == 3)));
set(handles.textNoise,'String',str);


% --- Executes on button press in buttonSingleModelPlot.
function buttonSingleModelPlot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSingleModelPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%I don't believe this exists any more

% --- Executes on button press in buttonNextSpike.
function buttonNextSpike_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNextSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedCounter = handles.selectedCounter + 1;
if(handles.selectedCounter > length(handles.selectedPerm))
    handles.selectedCounter = 1;
end
guidata(hObject,handles)
updateWaveformPlot(handles);

% --- Executes on button press in buttonPrevSpike.
function buttonPrevSpike_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrevSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedCounter = handles.selectedCounter - 1;
if(handles.selectedCounter < 1)
    handles.selectedCounter = length(handles.selectedPerm);
end
guidata(hObject,handles)
updateWaveformPlot(handles);

% --- Executes on slider movement.
function sliderScaleSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to sliderScaleSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.curMax = handles.waveMax*get(handles.sliderScaleSpikes,'Value');
handles.curMin = handles.waveMin*get(handles.sliderScaleSpikes,'Value');
guidata(hObject,handles);
updateWaveformPlot(handles);

% --- Executes during object creation, after setting all properties.
function sliderScaleSpikes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderScaleSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglePlotSingle.
function togglePlotSingle_Callback(hObject, eventdata, handles)
% hObject    handle to togglePlotSingle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglePlotSingle
updateWaveformPlot(handles);


% --- Executes on button press in togglePlotMean.
function togglePlotMean_Callback(hObject, eventdata, handles)
% hObject    handle to togglePlotMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglePlotMean
updateWaveformPlot(handles);


% --- Executes on button press in buttonAllNoise.
function buttonAllNoise_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAllNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.idx(:) = 1;
handles.uidx = 1; 
handles.listSingle = 3;
updateAllPlots(handles);
updateLists(handles);
handles.selectedPerm = randperm(sum(handles.idx == handles.uidx(get(handles.menuMainSpike, 'Value'))));
handles.selectedCounter = 1;
% Update handles structure
guidata(hObject, handles);
