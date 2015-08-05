function varargout = ASSLReviewTemplateMatching(varargin)
% ASSLREVIEWTEMPLATEMATCHING MATLAB code for ASSLReviewTemplateMatching.fig
%      ASSLREVIEWTEMPLATEMATCHING, by itself, creates a new ASSLREVIEWTEMPLATEMATCHING or raises the existing
%      singleton*.
%
%      H = ASSLREVIEWTEMPLATEMATCHING returns the handle to a new ASSLREVIEWTEMPLATEMATCHING or the handle to
%      the existing singleton*.
%
%      ASSLREVIEWTEMPLATEMATCHING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSLREVIEWTEMPLATEMATCHING.M with the given input arguments.
%
%      ASSLREVIEWTEMPLATEMATCHING('Property','Value',...) creates a new ASSLREVIEWTEMPLATEMATCHING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASSLReviewTemplateMatching_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASSLReviewTemplateMatching_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASSLReviewTemplateMatching

% Last Modified by GUIDE v2.5 06-Mar-2014 22:36:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASSLReviewTemplateMatching_OpeningFcn, ...
                   'gui_OutputFcn',  @ASSLReviewTemplateMatching_OutputFcn, ...
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


% --- Executes just before ASSLReviewTemplateMatching is made visible.
function ASSLReviewTemplateMatching_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASSLReviewTemplateMatching (see VARARGIN)

% Choose default command line output for ASSLReviewTemplateMatching
handles.output = hObject;

% Initialise some variables using either default values or values that have
% been passed while calling the function (RR 07 Jan 2013)

if (nargin >= 1)
    handles.ASSLReviewTMResults = varargin{1};
 
    cla(handles.TemplateSpecAxis);
    axes(handles.TemplateSpecAxis);
    if (exist('../SyllableTemplates.tif', 'file'))
        imshow('../SyllableTemplates.tif', 'Border', 'tight');
    end
    
    handles.ASSLReviewTMResults.FileIndex = 1;
    set(handles.SongFileNameTextLabel, 'String', ['Song File Name : ', handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, ' : #', num2str(handles.ASSLReviewTMResults.FileIndex), ' of ', num2str(length(handles.ASSLReviewTMResults.FileName)), ' files']);
    
    [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);

    Time = (1:1:length(RawData))/Fs;

    [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

%    set(handles.SongFileNameText, 'String', ['Song File Name : ', handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}]);

    if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
        if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
        end
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end

end

handles.ASSLReviewTMResults.ZoomSpecAxisLimits = handles.ASSLReviewTMResults.SpecAxisLimits;
handles.ASSLReviewTMResults.ZoomAmpAxisLimits = handles.ASSLReviewTMResults.AmpAxisLimits;
handles.ASSLReviewTMResults.ZoomLabelAxisLimits = handles.ASSLReviewTMResults.LabelAxisLimits;

handles.ASSLReviewTMResults.TimeStep = str2double(get(handles.TimeStepEdit, 'String'));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ASSLReviewTemplateMatching wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ASSLReviewTemplateMatching_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in DeleteSyllButton.
function DeleteSyllButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteSyllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.InstructionsTextLabel, 'String', 'Instructions: Click within the syllable that needs to be deleted');

handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

SyllableChanged = 0;

axes(handles.ReviewSpecAxis);
[x, y, button] = ginput(1);
x(1) = x(1) * 1000;

SyllableStart = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
if (x(1) > handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart))
    msgbox('Click within a syllable');
else
    handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = [];
    handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = [];
    handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = [];
    SyllableChanged = 1;
end

if (SyllableChanged == 1)
    [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
    Time = (1:1:length(RawData))/Fs;
    [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

    if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
        if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
        end
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end
    
    axes(handles.ReviewSpecAxis);
    axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

    axes(handles.ReviewLabelAxis);
    axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);
    
    axes(handles.ReviewAmplitudeAxis);
    axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
end

set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);

% --- Executes on button press in AddSyllButton.
function AddSyllButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSyllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

set(handles.InstructionsTextLabel, 'String', 'Instructions: Click within the syllable that needs to be added and type a label for the new syllable');

SyllableChanged = 0;

axes(handles.ReviewSpecAxis);
[x, y, button] = ginput(2);
x(1) = x(1) * 1000;

SyllableStart = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
if (x(1) <= handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart))
    msgbox('Click outside a syllable');
else
    NewThreshold = inputdlg('Enter the amplitude threshold for segmenting new syllable', 'Syllable threshold');
    NewThreshold = str2double(NewThreshold{1});
    SyllableChanged = 1;
end

if (SyllableChanged == 1)
    [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
    Time = (1:1:length(RawData))/Fs;
    [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);
    
    NewThresholdCrossings = Time(find(LogAmplitude < NewThreshold))*1000;
    NewSyllableStart = NewThresholdCrossings(find(NewThresholdCrossings < x(1), 1, 'last'));
    NewSyllableEnd = NewThresholdCrossings(find(NewThresholdCrossings > x(1), 1, 'first'));
    
    if (isempty(handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}))
        handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex} = char(button(2));
    else
        handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(end + 1) = char(button(2));
    end

    handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(end + 1) = NewSyllableStart;
    handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(end + 1) = NewSyllableEnd;
    
    [SortedVals, SortedIndices] = sort(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex});
    handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
    handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
    handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
    
    if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
        if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
        end
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end
    
    axes(handles.ReviewSpecAxis);
    axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

    axes(handles.ReviewLabelAxis);
    axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);
    
    axes(handles.ReviewAmplitudeAxis);
    axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
end

set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);

% --- Executes on button press in MergeSyllButton.
function MergeSyllButton_Callback(hObject, eventdata, handles)
% hObject    handle to MergeSyllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

set(handles.InstructionsTextLabel, 'String', 'Instructions: First click on the two extreme syllables that need to be merged and then type the new syllable label');

SyllableChanged = 0;

axes(handles.ReviewSpecAxis);
[x, y, button] = ginput(3);
x(1) = x(1) * 1000;
x(2) = x(2) * 1000;

FirstSyllable = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
LastSyllable = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(2), 1, 'last');

if (x(1) > handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(FirstSyllable))
    msgbox('Click within a syllable');
else
    if (x(2) > handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(LastSyllable))
        msgbox('Click within a syllable');
    else
        handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(FirstSyllable) = char(button(3));
        handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(FirstSyllable) = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(LastSyllable);
        
        handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(LastSyllable) = [];
        handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(LastSyllable) = [];
        handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(LastSyllable) = [];
        SyllableChanged = 1;
    end
end

if (SyllableChanged == 1)
    [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
    Time = (1:1:length(RawData))/Fs;
    [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

    if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
        if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
        end
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end
    
    axes(handles.ReviewSpecAxis);
    axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

    axes(handles.ReviewLabelAxis);
    axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);
    
    axes(handles.ReviewAmplitudeAxis);
    axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
end

set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);

% --- Executes on button press in SplitSyllButton.
function SplitSyllButton_Callback(hObject, eventdata, handles)
% hObject    handle to SplitSyllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

Flag = 1;

set(handles.InstructionsTextLabel, 'String', 'Instructions: First click within the syllable that needs to be split and then enter the threshold that has to be used to split the syllable. Type q to quit');
axes(handles.ReviewSpecAxis);
[x, y, button] = ginput(1);
x(1) = x(1) * 1000;

NewThreshold = inputdlg('Enter the amplitude threshold for splitting the syllable', 'Syllable threshold');
NewThreshold = str2double(NewThreshold{1});

if (button ~= 113)
    
    SyllableStart = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
    if (x(1) > handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart))
        msgbox('Click inside a syllable');
    else
        [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
        Time = (1:1:length(RawData))/Fs;
        [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

        SyllStart = round(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) * Fs/1000);
        SyllEnd = round(handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) * Fs/1000);
        [TempOnsets, TempOffsets] = ASSLSegmentData(LogAmplitude(SyllStart:SyllEnd), Fs, 0, 0, NewThreshold);
        
        TempOnsets = TempOnsets + handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart);
        TempOffsets = TempOffsets + handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart);
        
        handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = TempOffsets(1);
        
        for i = 2:length(TempOnsets),
            handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(end + 1) = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SyllableStart);
            handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(end + 1) = TempOnsets(i);
            handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(end + 1) = TempOffsets(i);

            [SortedVals, SortedIndices] = sort(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex});
            handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
            handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
            handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
        end
        
        if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
            if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
                [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
            else
                [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
            end
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
        end

        axes(handles.ReviewSpecAxis);
        axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

        axes(handles.ReviewLabelAxis);
        axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

        axes(handles.ReviewAmplitudeAxis);
        axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
    end
end
    
set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);

% --- Executes on button press in EditSyllLabelButton.
function EditSyllLabelButton_Callback(hObject, eventdata, handles)
% hObject    handle to EditSyllLabelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

set(handles.InstructionsTextLabel, 'String', 'Instructions: First click within the syllable that needs to be changed and then type the new syllable label');

SyllableChanged = 0;

axes(handles.ReviewSpecAxis);

if (ismac)
    [x, y, button] = ginputax(2, handles.ReviewSpecAxis);
else
    [x, y, button] = ginput(2);
end
x(1) = x(1) * 1000;

SyllableStart = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
if (x(1) > handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart))
    msgbox('Click within a syllable');
else
    handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = char(button(2));
    SyllableChanged = 1;
end

if (SyllableChanged == 1)
    [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
    Time = (1:1:length(RawData))/Fs;
    [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

    if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
        if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
        end
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end
    
    axes(handles.ReviewSpecAxis);
    axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

    axes(handles.ReviewLabelAxis);
    axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);
    
    axes(handles.ReviewAmplitudeAxis);
    axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
end

set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);

% --- Executes on button press in ReturnEditedSyllablesButton.
function ReturnEditedSyllablesButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReturnEditedSyllablesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ASSLMainWindow = findobj('Name', 'AutoSongSegmentLabel');
if (length(ASSLMainWindow) > 0)
    ASSLData = guidata(ASSLMainWindow);
    ASSLData.ASSL.SyllLabels = handles.ASSLReviewTMResults.SyllLabels;
    ASSLData.ASSL.SyllOnsets = handles.ASSLReviewTMResults.SyllOnsets;
    ASSLData.ASSL.SyllOffsets = handles.ASSLReviewTMResults.SyllOffsets;
    guidata(ASSLMainWindow, ASSLData);
    msgbox('Returned edit syllable details to Auto Song Segment Label');
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NextFileButton.
function NextFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ASSLReviewTMResults.FileIndex = handles.ASSLReviewTMResults.FileIndex + 1;
if (handles.ASSLReviewTMResults.FileIndex < 1)
    handles.ASSLReviewTMResults.FileIndex = 1;
end

if (handles.ASSLReviewTMResults.FileIndex > length(handles.ASSLReviewTMResults.FileName))
    handles.ASSLReviewTMResults.FileIndex = length(handles.ASSLReviewTMResults.FileName);
end

set(handles.SongFileNameTextLabel, 'String', ['Song File Name : ', handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, ' : #', num2str(handles.ASSLReviewTMResults.FileIndex), ' of ', num2str(length(handles.ASSLReviewTMResults.FileName)), ' files']);
[RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
Time = (1:1:length(RawData))/Fs;
[LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
    if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
    end
else
    [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
end

handles.ASSLReviewTMResults.ZoomSpecAxisLimits = handles.ASSLReviewTMResults.SpecAxisLimits;
handles.ASSLReviewTMResults.ZoomAmpAxisLimits = handles.ASSLReviewTMResults.AmpAxisLimits;
handles.ASSLReviewTMResults.ZoomLabelAxisLimits = handles.ASSLReviewTMResults.LabelAxisLimits;

guidata(hObject, handles);

% --- Executes on button press in PrevFileButton.
function PrevFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ASSLReviewTMResults.FileIndex = handles.ASSLReviewTMResults.FileIndex - 1;
if (handles.ASSLReviewTMResults.FileIndex < 1)
    handles.ASSLReviewTMResults.FileIndex = 1;
end

if (handles.ASSLReviewTMResults.FileIndex > length(handles.ASSLReviewTMResults.FileName))
    handles.ASSLReviewTMResults.FileIndex = length(handles.ASSLReviewTMResults.FileName);
end

set(handles.SongFileNameTextLabel, 'String', ['Song File Name : ', handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, ' : #', num2str(handles.ASSLReviewTMResults.FileIndex), ' of ', num2str(length(handles.ASSLReviewTMResults.FileName)), ' files']);
[RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
Time = (1:1:length(RawData))/Fs;
[LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
    if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
    end
else
    [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
end

handles.ASSLReviewTMResults.ZoomSpecAxisLimits = handles.ASSLReviewTMResults.SpecAxisLimits;
handles.ASSLReviewTMResults.ZoomAmpAxisLimits = handles.ASSLReviewTMResults.AmpAxisLimits;
handles.ASSLReviewTMResults.ZoomLabelAxisLimits = handles.ASSLReviewTMResults.LabelAxisLimits;

guidata(hObject, handles);


% --- Executes on button press in NextTimeButton.
function NextTimeButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextTimeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ((handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) - handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1)) > 1.1*handles.ASSLReviewTMResults.TimeStep)
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.SpecAxisLimits(1) + handles.ASSLReviewTMResults.TimeStep;
else
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) + 0.9*handles.ASSLReviewTMResults.TimeStep;
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) + handles.ASSLReviewTMResults.TimeStep;
end

if (handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) < 0)
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) = 0;
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) + handles.ASSLReviewTMResults.TimeStep;
end

if (handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) > handles.ASSLReviewTMResults.SpecAxisLimits(2))
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.SpecAxisLimits(2) + handles.ASSLReviewTMResults.TimeStep*0.1;
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) - handles.ASSLReviewTMResults.TimeStep;
end

handles.ASSLReviewTMResults.ZoomAmpAxisLimits(1:2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1:2);
handles.ASSLReviewTMResults.ZoomLabelAxisLimits(1:2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1:2);

axes(handles.ReviewSpecAxis);
axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

axes(handles.ReviewLabelAxis);
axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

axes(handles.ReviewAmplitudeAxis);
axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);

guidata(hObject, handles);

% --- Executes on button press in PrevTimeButton.
function PrevTimeButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevTimeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if ((handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) - handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1)) > 1.1*handles.ASSLReviewTMResults.TimeStep)
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.SpecAxisLimits(1) + handles.ASSLReviewTMResults.TimeStep;
else
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) - 0.9*handles.ASSLReviewTMResults.TimeStep;
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) + handles.ASSLReviewTMResults.TimeStep;
end

if (handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) < 0)
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) = 0;
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) + handles.ASSLReviewTMResults.TimeStep;
end

if (handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) > handles.ASSLReviewTMResults.SpecAxisLimits(2))
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) = handles.ASSLReviewTMResults.SpecAxisLimits(2) + handles.ASSLReviewTMResults.TimeStep*0.1;
    handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(2) - handles.ASSLReviewTMResults.TimeStep;
end


handles.ASSLReviewTMResults.ZoomAmpAxisLimits(1:2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1:2);
handles.ASSLReviewTMResults.ZoomLabelAxisLimits(1:2) = handles.ASSLReviewTMResults.ZoomSpecAxisLimits(1:2);

axes(handles.ReviewSpecAxis);
axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

axes(handles.ReviewLabelAxis);
axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

axes(handles.ReviewAmplitudeAxis);
axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);

guidata(hObject, handles);


function TimeStepEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TimeStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeStepEdit as text
%        str2double(get(hObject,'String')) returns contents of TimeStepEdit as a double

handles.ASSLReviewTMResults.TimeStep = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes on button press in DeleteMultipleSyllButton.
function DeleteMultipleSyllButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteMultipleSyllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.InstructionsTextLabel, 'String', 'Instructions: Left click within syllables that needs to be deleted and right click when done deleting');

Flag = 1;

while (Flag == 1)
    SyllableChanged = 0;
    
    axes(handles.ReviewSpecAxis);
    [x, y, button] = ginput(1);
    
    if (button == 3)
        Flag = 0;
        break;
    end
    
    x(1) = x(1) * 1000;

    SyllableStart = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
    if (x(1) > handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart))
        disp('Click within a syllable');
    else
        handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = [];
        handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = [];
        handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart) = [];
        SyllableChanged = 1;
    end

    if (SyllableChanged == 1)
        [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
        Time = (1:1:length(RawData))/Fs;
        [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

        if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
            if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
                [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
            else
                [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
            end
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
        end

        axes(handles.ReviewSpecAxis);
        axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

        axes(handles.ReviewLabelAxis);
        axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

        axes(handles.ReviewAmplitudeAxis);
        axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
        guidata(hObject, handles);
    end
end

set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);

% --- Executes on button press in AddMultipleSyllablesButton.
function AddMultipleSyllablesButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddMultipleSyllablesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

Flag = 1;

set(handles.InstructionsTextLabel, 'String', 'Instructions: First click within the axes and then type a common label for all new syllables');
axes(handles.ReviewSpecAxis);
[x, y, NewLabel] = ginput(2);

NewLabel = NewLabel(2);

NewThreshold = inputdlg('Enter the amplitude threshold for segmenting new syllable', 'Syllable threshold');
NewThreshold = str2double(NewThreshold{1});

while (Flag == 1)
    set(handles.InstructionsTextLabel, 'String', 'Instructions: Left click within individual syllables that need to be added; right click when done');

    SyllableChanged = 0;

    axes(handles.ReviewSpecAxis);
    [x, y, button] = ginput(1);
    
    if (button == 3)
        Flag = 0;
        break;
    end
    
    x(1) = x(1) * 1000;

    SyllableStart = find(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= x(1), 1, 'last');
    if (x(1) <= handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStart))
        msgbox('Click outside a syllable');
    else
        SyllableChanged = 1;
    end

    if (SyllableChanged == 1)
        [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
        Time = (1:1:length(RawData))/Fs;
        [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

        NewThresholdCrossings = Time(find(LogAmplitude < NewThreshold))*1000;
        NewSyllableStart = NewThresholdCrossings(find(NewThresholdCrossings < x(1), 1, 'last'));
        NewSyllableEnd = NewThresholdCrossings(find(NewThresholdCrossings > x(1), 1, 'first'));

        if (isempty(handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}))
            handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex} = char(NewLabel);
        else
            handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(end + 1) = char(NewLabel);
        end

        handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(end + 1) = NewSyllableStart;
        handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(end + 1) = NewSyllableEnd;

        [SortedVals, SortedIndices] = sort(handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex});
        handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
        handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);
        handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SortedIndices);

        if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
            if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
                [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
            else
                [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
            end
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
        end

        axes(handles.ReviewSpecAxis);
        axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

        axes(handles.ReviewLabelAxis);
        axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

        axes(handles.ReviewAmplitudeAxis);
        axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
    end
end
    
set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);


% --- Executes on button press in JumpFileButton.
function JumpFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to JumpFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NewFileIndex = inputdlg('Enter the file # to jump to', 'File #');
NewFileIndex = str2double(NewFileIndex{1});

handles.ASSLReviewTMResults.FileIndex = NewFileIndex;
if (handles.ASSLReviewTMResults.FileIndex < 1)
    handles.ASSLReviewTMResults.FileIndex = 1;
end

if (handles.ASSLReviewTMResults.FileIndex > length(handles.ASSLReviewTMResults.FileName))
    handles.ASSLReviewTMResults.FileIndex = length(handles.ASSLReviewTMResults.FileName);
end

set(handles.SongFileNameTextLabel, 'String', ['Song File Name : ', handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, ' : #', num2str(handles.ASSLReviewTMResults.FileIndex), ' of ', num2str(length(handles.ASSLReviewTMResults.FileName)), ' files']);
[RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
Time = (1:1:length(RawData))/Fs;
[LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
    if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
    end
else
    [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
end

handles.ASSLReviewTMResults.ZoomSpecAxisLimits = handles.ASSLReviewTMResults.SpecAxisLimits;
handles.ASSLReviewTMResults.ZoomAmpAxisLimits = handles.ASSLReviewTMResults.AmpAxisLimits;
handles.ASSLReviewTMResults.ZoomLabelAxisLimits = handles.ASSLReviewTMResults.LabelAxisLimits;

guidata(hObject, handles);


% --- Executes on button press in DeleteSyllsWithinLimitsButton.
function DeleteSyllsWithinLimitsButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteSyllsWithinLimitsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex};

set(handles.InstructionsTextLabel, 'String', 'Instructions: Left click to specify the left limit; right click to specify the right limit and then hit enter. Type q to quit at any time without deleting');
Flag = 1;
temp = axis;
LeftLimit = temp(1)*1000;
RightLimit = temp(2)*1000;

hold on;
LeftLimitLine = plot([LeftLimit LeftLimit], [temp(3) temp(4)], 'r--');
RightLimitLine = plot([RightLimit RightLimit], [temp(3) temp(4)], 'g--');

DeleteSylls = 0;

while (Flag == 1)
    
    axes(handles.ReviewSpecAxis);
    [x, y, button] = ginput(1);
    
    if (button == 1)
        LeftLimit = x(1) * 1000;
    end
    
    if (button == 3)
        RightLimit = x(1) * 1000;
    end

    delete(LeftLimitLine);
    delete(RightLimitLine);
    LeftLimitLine = plot([LeftLimit LeftLimit], [temp(3) temp(4)], 'r--');
    RightLimitLine = plot([RightLimit RightLimit], [temp(3) temp(4)], 'g--');
    
    if (isempty(button))
        DeleteSylls = 1;
        break;
    end
    
    if (button == 113)
        Flag = 0;
        break;
    end
end

delete(LeftLimitLine);
delete(RightLimitLine);

if (DeleteSylls == 1)

    SyllableStarts = find((handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} >= LeftLimit) & (handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} <= RightLimit));

    handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex}(SyllableStarts) = [];
    handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStarts) = [];
    handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}(SyllableStarts) = [];
    SyllableChanged = 1;
end

if (SyllableChanged == 1)
    [RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
    Time = (1:1:length(RawData))/Fs;
    [LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

    if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
        if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
        else
            [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
        end
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end

    axes(handles.ReviewSpecAxis);
    axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

    axes(handles.ReviewLabelAxis);
    axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

    axes(handles.ReviewAmplitudeAxis);
    axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
    guidata(hObject, handles);
end

set(handles.InstructionsTextLabel, 'String', 'Instructions:');
guidata(hObject, handles);


% --- Executes on button press in UndoPreviousButton.
function UndoPreviousButton_Callback(hObject, eventdata, handles)
% hObject    handle to UndoPreviousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.PrevSyllLabels{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.PrevSyllOnsets{handles.ASSLReviewTMResults.FileIndex};
handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex} = handles.ASSLReviewTMResults.PrevSyllOffsets{handles.ASSLReviewTMResults.FileIndex};

[RawData, Fs] = ASSLGetRawData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, handles.ASSLReviewTMResults.SongChanNo);
Time = (1:1:length(RawData))/Fs;
[LogAmplitude] = ASSLCalculateLogAmplitude(RawData, Fs, Time, handles.ASSLReviewTMResults.FFTWinSizeSegmenting, handles.ASSLReviewTMResults.FFTWinOverlapSegmenting);

if (isfield(handles.ASSLReviewTMResults, 'SyllOnsets'))
    if (isfield(handles.ASSLReviewTMResults, 'SyllLabels'))
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllLabels{handles.ASSLReviewTMResults.FileIndex});
    else
        [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, handles.ASSLReviewTMResults.Threshold{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOnsets{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.SyllOffsets{handles.ASSLReviewTMResults.FileIndex});
    end
else
    [handles.ASSLReviewTMResults.SpecAxisLimits, handles.ASSLReviewTMResults.LabelAxisLimits, handles.ASSLReviewTMResults.AmpAxisLimits] = ASSLReviewPlotData(handles.ASSLReviewTMResults.DirName, handles.ASSLReviewTMResults.FileName{handles.ASSLReviewTMResults.FileIndex}, handles.ASSLReviewTMResults.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
end

axes(handles.ReviewSpecAxis);
axis(handles.ASSLReviewTMResults.ZoomSpecAxisLimits);

axes(handles.ReviewLabelAxis);
axis(handles.ASSLReviewTMResults.ZoomLabelAxisLimits);

axes(handles.ReviewAmplitudeAxis);
axis(handles.ASSLReviewTMResults.ZoomAmpAxisLimits);
guidata(hObject, handles);