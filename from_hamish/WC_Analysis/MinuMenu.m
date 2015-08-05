function varargout = MinuMenu(varargin)
% MINUMENU M-file for MinuMenu.fig
%      MINUMENU, by itself, creates a new MINUMENU or raises the existing
%      singleton*.
%
%      H = MINUMENU returns the handle to a new MINUMENU or the handle to
%      the existing singleton*.
%
%      MINUMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MINUMENU.M with the given input arguments.
%
%      MINUMENU('Property','Value',...) creates a new MINUMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MinuMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MinuMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MinuMenu

% Last Modified by GUIDE v2.5 31-Mar-2011 11:55:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MinuMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @MinuMenu_OutputFcn, ...
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


% --- Executes just before MinuMenu is made visible.
function MinuMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MinuMenu (see VARARGIN)

% Choose default command line output for MinuMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global Data;
global Xax;


% UIWAIT makes MinuMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MinuMenu_OutputFcn(hObject, eventdata, handles) 
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

buttonclick=get(gcf,'SelectionType');
ax = get(hObject, 'Parent');
pt = get(ax, 'CurrentPoint');
keyboard
if strcmp(buttonclick,'normal')    
    Yax=[pt(2)];         
    Xax=xlim;
    try
        killhand=findobj(gca,'Tag','ThreshLine');
        delete(killhand);
    catch
    end;
    ThreshLine=line(Xax(1):Xax(2),Yax(1),'Color','r','Tag','ThreshLine');
end;
    

% --- Executes on mouse press over axes background.
function MiniPlot_ButtonDownFcn(hObject, eventdata, handles)

global Xax
global ThreshLine;


buttonclick=get(gcf,'SelectionType');
ax = get(hObject, 'Parent');
pt = get(ax, 'CurrentPoint');
keyboard
if strcmp(buttonclick,'normal')    
    Yax=[pt(2)];         
    Xax=xlim;
    try
        killhand=findobj(gca,'Tag','ThreshLine');
        delete(killhand);
    catch
    end;
    ThreshLine=line(Xax(1):Xax(2),Yax(1),'Color','r','Tag','ThreshLine');
end;
    
    
