function varargout = CropPosSample(varargin)
% CROPPOSSAMPLE MATLAB code for CropPosSample.fig
%      CROPPOSSAMPLE, by itself, creates a new CROPPOSSAMPLE or raises the existing
%      singleton*.
%
%      H = CROPPOSSAMPLE returns the handle to a new CROPPOSSAMPLE or the handle to
%      the existing singleton*.
%
%      CROPPOSSAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CROPPOSSAMPLE.M with the given input arguments.
%
%      CROPPOSSAMPLE('Property','Value',...) creates a new CROPPOSSAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CropPosSample_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CropPosSample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CropPosSample

% Last Modified by GUIDE v2.5 30-Jun-2015 00:19:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CropPosSample_OpeningFcn, ...
                   'gui_OutputFcn',  @CropPosSample_OutputFcn, ...
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


% --- Executes just before CropPosSample is made visible.
function CropPosSample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CropPosSample (see VARARGIN)

global imgs imgsDir dataBaseDir mouseDown regionFid fileList;
mouseDown = 0;

% Choose default command line output for CropPosSample
handles.output = hObject;

% Initialize file list box.
dataBaseDir = ['./database'];
imgsDir = [dataBaseDir '/positive/'];
imgs = dir([imgsDir '*.jpg']);
imgsLen = length(imgs);
fileList = [];
for k = 1:imgsLen
    fileList = [fileList; {imgs(k).name}];
end
set(handles.fileListBox, 'String', fileList);
regionFid = -1;

% Initialize show area
axes(handles.showArea);

% Update handles structure
guidata(hObject, handles);

imgFileLoad(handles);

% UIWAIT makes CropPosSample wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CropPosSample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function imgFileLoad(handles)
global imgs imgsDir dataBaseDir imgShow gtPath regionList areaEndPoint areaStartPoint;
% Show selected image on show area
imgShow = imread([imgsDir imgs(get(handles.fileListBox, 'Value')).name]);
% Initialize regionListBox
[pathSrc, name, ext] = fileparts(imgs(get(handles.fileListBox, 'Value')).name);
regionList = [];
gtPath = [dataBaseDir '/posGt/' name '.txt'];
if(exist(gtPath, 'file'))
    regionFid = fopen(gtPath, 'r');
    pat = '^\w+ (?<left>\d+) (?<top>\d+) (?<width>\d+) (?<height>\d+) \d+ \d+ \d+ \d+ \d+ \d+ \d+';
    while(~feof(regionFid))
        lineStr = fgetl(regionFid);
        if(lineStr == -1)
            break;
        end
        result = regexp(lineStr, pat, 'names');
        if(~isempty(result))
            regionList = [regionList; [str2num(result.left), str2num(result.top), str2num(result.width), str2num(result.height)]];
        end
    end
    fclose(regionFid);
else
    regionFid = fopen(gtPath, 'w+');
    fclose(regionFid);
end

if(isempty(regionList))
    regionList = [0 0 0 0];
end
regionListStr = [];
for k = 1:size(regionList, 1)
    regionListStr = [regionListStr; {num2str(k)}];
end
set(handles.regionListBox, 'Value', 1);
set(handles.regionListBox, 'String', regionListStr);
region = regionList(1, :);
areaStartPoint(1) = region(1);
areaStartPoint(2) = region(2);
areaEndPoint(1) = region(1) + region(3);
areaEndPoint(2) = region(2) + region(4);
set(handles.leftEdit, 'String', num2str(region(1)));
set(handles.topEdit, 'String', num2str(region(2)));
set(handles.widthEdit, 'String', num2str(region(3)));
set(handles.heightEdit, 'String', num2str(region(4)));
uicontrol(handles.nextButton);
showRegionList(imgShow, regionList, handles);


% --- Executes on selection change in fileListBox.
function fileListBox_Callback(hObject, eventdata, handles)
% hObject    handle to fileListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileListBox
imgFileLoad(handles);



% --- Executes during object creation, after setting all properties.
function fileListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imgs imgsDir dataBaseDir fileList;
dataBaseDir = uigetdir('./samples/post', 'Select a database directory');
imgsDir = [dataBaseDir '/positive/'];
imgs = dir([imgsDir '*.jpg']);
imgsLen = length(imgs);
fileList = [];
for k = 1:imgsLen
    fileList = [fileList; {imgs(k).name}];
end
set(handles.fileListBox, 'String', fileList);



% --- Executes on button press in lastButton.
function lastButton_Callback(hObject, eventdata, handles)
% hObject    handle to lastButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr = get(handles.fileListBox, 'Value');
total = size(get(handles.fileListBox, 'String'), 1);
if(curr < total)
    curr = curr + 1;
    set(handles.fileListBox, 'Value', curr);
    imgFileLoad(handles);
end


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global areaStartPoint areaEndPoint areaClickPoint mouseDown mouseRegion regionDrawMode;
point = get(handles.showArea, 'currentpoint');
x = round(point(1, 1)); y = round(point(1, 2));
if(mouseDown == 1)
    if(regionDrawMode == 0)
        areaEndPoint = [x, y];
    elseif(regionDrawMode == 1)
        dx = x - areaClickPoint(1);
        dy = y - areaClickPoint(2);
        areaStartPoint(1) = areaStartPoint(1) + dx;
        areaStartPoint(2) = areaStartPoint(2) + dy;
        areaEndPoint(1) = areaEndPoint(1) + dx;
        areaEndPoint(2) = areaEndPoint(2) + dy;
        areaClickPoint = [x, y];
    elseif(regionDrawMode == 2)
        dx = x - areaClickPoint(1);
        areaStartPoint(1) = areaStartPoint(1) + dx;
        areaClickPoint(1) = x;
    elseif(regionDrawMode == 3)
        dx = x - areaClickPoint(1);
        areaEndPoint(1) = areaEndPoint(1) + dx;
        areaClickPoint(1) = x;
    elseif(regionDrawMode == 4)
        dy = y - areaClickPoint(2);
        areaStartPoint(2) = areaStartPoint(2) + dy;
        areaClickPoint(2) = y;
    elseif(regionDrawMode == 5)
        dy = y - areaClickPoint(2);
        areaEndPoint(2) = areaEndPoint(2) + dy;
        areaClickPoint(2) = y;
    end
    
    w = (areaEndPoint(1) - areaStartPoint(1));
    h = (areaEndPoint(2) - areaStartPoint(2));
    if(w < 0)
        w = 0;
    end
    if(h < 0)
        h = 0;
    end
   if(~isempty('mouseRegin'))
%       if(~isempty(mouseRegin))  
        delete(mouseRegion);  %May be some problem
    end
    mouseRegion = rectangle('Position', [areaStartPoint(1), areaStartPoint(2), w, h]);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global areaStartPoint areaEndPoint imgShow mouseDown regionList regionDrawMode;
mouseDown = 0;
regionListIndex = get(handles.regionListBox, 'Value');
if(regionListIndex > 0)

    w = (areaEndPoint(1) - areaStartPoint(1));
    h = (areaEndPoint(2) - areaStartPoint(2));
    if(w < 0)
        w = 0;
    end
    if(h < 0)
        h = 0;
    end

    regionList(regionListIndex, 1) = areaStartPoint(1);
    regionList(regionListIndex, 2) = areaStartPoint(2);
    regionList(regionListIndex, 3) = w;
    regionList(regionListIndex, 4) = h;
    set(handles.leftEdit, 'String', num2str(regionList(regionListIndex, 1)));
    set(handles.topEdit, 'String', num2str(regionList(regionListIndex, 2)));
    set(handles.widthEdit, 'String', num2str(regionList(regionListIndex, 3)));
    set(handles.heightEdit, 'String', num2str(regionList(regionListIndex, 4)));
    showRegionList(imgShow, regionList, handles);
    saveRegionList(regionList);
end
uicontrol(handles.nextButton)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imgShow areaStartPoint areaEndPoint areaClickPoint mouseDown regionList regionDrawMode;
mouseDown = 1;
point = get(handles.showArea, 'currentpoint');
x = round(point(1, 1)); y = round(point(1, 2));
% Calculate region draw mode
if(areaEndPoint(1) == areaStartPoint(1) || areaEndPoint(2) == areaStartPoint(2))
    areaStartPoint = [x, y];
    regionDrawMode = 0;
else
    dx = (x - areaStartPoint(1)) / (areaEndPoint(1) - areaStartPoint(1));
    dy = (y - areaStartPoint(2)) / (areaEndPoint(2) - areaStartPoint(2));
    if((dx < -0.2 || dx > 1.2) && (dy < -0.2 || dy > 1.2))
        areaStartPoint = [x, y];
        regionDrawMode = 0;
    elseif((dx > 0.2 && dx < 0.8) && (dy > 0.2 && dy < 0.8))
        areaClickPoint = [x, y];
        regionDrawMode = 1;
    elseif(abs(dx) < 0.1 && (dy > 0.2 && dy < 0.8))
        areaClickPoint = [x, y];
        regionDrawMode = 2;
    elseif((dx > 0.9 && dx < 1.1) && (dy > 0.2 && dy < 0.8))
        areaClickPoint = [x, y];
        regionDrawMode = 3;
    elseif(abs(dy) < 0.1 && (dx > 0.2 && dx < 0.8))
        areaClickPoint = [x, y];
        regionDrawMode = 4;
    elseif((dy > 0.9 && dy < 1.1) && (dx > 0.2 && dx < 0.8))
        areaClickPoint = [x, y];
        regionDrawMode = 5;
    end
end
showRegionList(imgShow, regionList, handles);


% --- Executes on selection change in regionListBox.
function regionListBox_Callback(hObject, eventdata, handles)
% hObject    handle to regionListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regionListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regionListBox
global imgShow regionList areaStartPoint areaEndPoint;
region = regionList(eventdata.Source.Value, :);
regionListIndex = eventdata.Source.Value;

areaStartPoint(1) = regionList(regionListIndex, 1);
areaStartPoint(2) = regionList(regionListIndex, 2);
areaEndPoint(1) = regionList(regionListIndex, 3) + areaStartPoint(1);
areaEndPoint(2) = regionList(regionListIndex, 4) + areaStartPoint(2);

set(handles.leftEdit, 'String', num2str(region(1)));
set(handles.topEdit, 'String', num2str(region(2)));
set(handles.widthEdit, 'String', num2str(region(3)));
set(handles.heightEdit, 'String', num2str(region(4)));

showRegionList(imgShow, regionList, handles);
uicontrol(handles.nextButton)


% --- Executes during object creation, after setting all properties.
function regionListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regionListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function leftEdit_Callback(hObject, eventdata, handles)
% hObject    handle to leftEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leftEdit as text
%        str2double(get(hObject,'String')) returns contents of leftEdit as a double
global imgShow regionList;
val = str2num(get(hObject, 'String'));
if(isempty(val))
    val = 0;
end
regionList(get(handles.regionListBox, 'Value'), 1) = val;
showRegionList(imgShow, regionList, handles);


% --- Executes during object creation, after setting all properties.
function leftEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function topEdit_Callback(hObject, eventdata, handles)
% hObject    handle to topEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of topEdit as text
%        str2double(get(hObject,'String')) returns contents of topEdit as a double
global imgShow regionList;
val = str2num(get(hObject, 'String'));
if(isempty(val))
    val = 0;
end
regionList(get(handles.regionListBox, 'Value'), 2) = val;
showRegionList(imgShow, regionList, handles);

% --- Executes during object creation, after setting all properties.
function topEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function widthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to widthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widthEdit as text
%        str2double(get(hObject,'String')) returns contents of widthEdit as a double
global imgShow regionList;
val = str2num(get(hObject, 'String'));
if(isempty(val))
    val = 0;
end
regionList(get(handles.regionListBox, 'Value'), 3) = val;
showRegionList(imgShow, regionList, handles);

% --- Executes during object creation, after setting all properties.
function widthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function heightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to heightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of heightEdit as text
%        str2double(get(hObject,'String')) returns contents of heightEdit as a double
global imgShow regionList;
val = str2num(get(hObject, 'String'));
if(isempty(val))
    val = 0;
end
regionList(get(handles.regionListBox, 'Value'), 4) = val;
showRegionList(imgShow, regionList, handles);

% --- Executes during object creation, after setting all properties.
function heightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function showRegionList(imgShow, regionList, handles)
global regionFid;
imshow(imgShow);
for k = 1:size(regionList, 1)
    if(regionList(k, 3) > 0 && regionList(k, 4) > 0)
        if(k == get(handles.regionListBox, 'Value'))
            rectangle('Position', [regionList(k, 1), regionList(k, 2), regionList(k, 3), regionList(k, 4)], 'EdgeColor', 'blue');
        else
            rectangle('Position', [regionList(k, 1), regionList(k, 2), regionList(k, 3), regionList(k, 4)], 'EdgeColor', 'red');
        end
    end
end



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global regionFid;
if(regionFid > 0)
    fclose(regionFid);
end

function saveRegionList(regionList)
global gtPath;
%Save region list as ground truth file
regionFid = fopen(gtPath, 'w');
fprintf(regionFid, '%% bbGt version=3\n');
if(regionFid > 0)
    for k = 1:size(regionList, 1)
        if(regionList(k, 3) > 0 && regionList(k, 4) > 0)
            fprintf(regionFid, 'car %d %d %d %d 0 0 0 0 0 0 0\n', regionList(k, 1), regionList(k, 2), regionList(k, 3), regionList(k, 4));
        end
    end
end
fclose(regionFid);


% --- Executes on button press in addRegionButton.
function addRegionButton_Callback(hObject, eventdata, handles)
% hObject    handle to addRegionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global regionList areaStartPoint areaEndPoint;
areaStartPoint = [0 0];
areaEndPoint = [0 0];
regionList = [regionList; [0 0 0 0]];
regionListStr = get(handles.regionListBox, 'String');
regionListLen = size(regionList, 1);
regionListStr = [regionListStr; {num2str(regionListLen)}];
set(handles.regionListBox, 'String', regionListStr);
set(handles.regionListBox, 'Value', regionListLen);
saveRegionList(regionList);
uicontrol(handles.nextButton)

% --- Executes on button press in delRegionButton.
function delRegionButton_Callback(hObject, eventdata, handles)
% hObject    handle to delRegionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imgShow regionList;
regionList(get(handles.regionListBox, 'Value'), :) = [];
regionListStr = [];
for k = 1:size(get(handles.regionListBox, 'String'), 1)-1
    regionListStr = [regionListStr, {num2str(k)}];
end
set(handles.regionListBox, 'String', regionListStr);
set(handles.regionListBox, 'Value', 1);
showRegionList(imgShow, regionList, handles);
saveRegionList(regionList);
uicontrol(handles.nextButton);



% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
uicontrol(handles.nextButton)
nextButton_KeyPressFcn(handles.nextButton, eventdata, handles);

% --- Executes on key press with focus on nextButton and none of its controls.
function nextButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global areaStartPoint areaEndPoint imgShow regionList;
if(size(regionList, 1) > 0)
    region = regionList(get(handles.regionListBox, 'Value'), :);
    if(strcmp(eventdata.Key, 'leftarrow'))
        left = region(1);
        if(left >= 1)
            left = left - 1;
        end
        region(1) = left;
    elseif(strcmp(eventdata.Key, 'rightarrow'))
        left = region(1);
        left = left + 1;
        region(1) = left;
    elseif(strcmp(eventdata.Key, 'uparrow'))
        up = region(2);
        if(up >= 1)
            up = up - 1;
        end
        region(2) = up;
    elseif(strcmp(eventdata.Key, 'downarrow'))
        up = region(2);
        up = up + 1;
        region(2) = up;
    elseif(strcmp(eventdata.Key, 'escape'))
        region = [0 0 0 0];
    end
    areaStartPoint(1) = region(1);
    areaStartPoint(2) = region(2);
    areaEndPoint(1) = region(1) + region(3);
    areaStartPoint(2) = region(2) + region(4);
    set(handles.leftEdit, 'String', num2str(region(1)));
    set(handles.topEdit, 'String', num2str(region(2)));
    set(handles.widthEdit, 'String', num2str(region(3)));
    set(handles.heightEdit, 'String', num2str(region(4)));
    regionList(get(handles.regionListBox, 'Value'), :) = region;
    showRegionList(imgShow, regionList, handles);
    saveRegionList(regionList);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over nextButton.
function nextButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deleteButton.
function deleteButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imgs imgsDir fileList;
%Delete the showing image
delete([imgsDir imgs(get(handles.fileListBox, 'Value')).name]);
lastIndex = get(handles.fileListBox, 'Value');
fileList(lastIndex) = [];
set(handles.fileListBox, 'String', fileList);
if(lastIndex > length(fileList))
    lastIndex = length(fileList);
end
imgs = dir([imgsDir '*.jpg']);
set(handles.fileListBox, 'Value', lastIndex);
imgFileLoad(handles);


% --- Executes during object deletion, before destroying properties.
function deleteButton_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to deleteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
