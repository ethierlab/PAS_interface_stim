function varargout = PAS_Stimulation_DAQ_GUI(varargin)
% PAS_STIMULATION_DAQ_GUI MATLAB code for PAS_Stimulation_DAQ_GUI.fig
%      PAS_STIMULATION_DAQ_GUI, by itself, creates a new PAS_STIMULATION_DAQ_GUI or raises the existing
%      singleton*.
%
%      H = PAS_STIMULATION_DAQ_GUI returns the handle to a new PAS_STIMULATION_DAQ_GUI or the handle to
%      the existing singleton*.
%
%      PAS_STIMULATION_DAQ_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PAS_STIMULATION_DAQ_GUI.M with the given input arguments.
%
%      PAS_STIMULATION_DAQ_GUI('Property','Value',...) creates a new PAS_STIMULATION_DAQ_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PAS_Stimulation_DAQ_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PAS_Stimulation_DAQ_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PAS_Stimulation_DAQ_GUI

% Last Modified by GUIDE v2.5 11-Apr-2018 13:37:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PAS_Stimulation_DAQ_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PAS_Stimulation_DAQ_GUI_OutputFcn, ...
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


% --- Executes just before PAS_Stimulation_DAQ_GUI is made visible.
function PAS_Stimulation_DAQ_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PAS_Stimulation_DAQ_GUI (see VARARGIN)

% Choose default command line output for PAS_Stimulation_DAQ_GUI
handles.output = hObject;
handles.params = PAS_Stimulation_DAQ_default_params;

% Update handles structure
guidata(hObject, handles);
set(handles.animal_name_edit,'String', handles.params.animal_name);

% UIWAIT makes PAS_Stimulation_DAQ_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PAS_Stimulation_DAQ_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function animal_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to animal_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animal_name_edit as text
%        str2double(get(hObject,'String')) returns contents of animal_name_edit as a double

% --- Executes during object creation, after setting all properties.
function animal_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animal_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in uibuttongroup3.
function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup3 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch(get(eventdata.NewValue,'Tag'))
    case 'radiobuttoncortex'
        stim_type=get(handles.radiobuttoncortex,'string');
    case 'radiobuttonmuscle'
        stim_type=get(handles.radiobuttonmuscle,'string');
    case 'radiobuttoncm'
        stim_type=get(handles.radiobuttoncm,'string');
    case 'radiobuttonauto'
        stim_type=get(handles.radiobuttonauto,'string');
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PAS_Stimulation_DAQ_code(handles)



% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
