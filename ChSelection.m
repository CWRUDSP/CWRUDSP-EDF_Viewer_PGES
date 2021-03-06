%--------------------------------------------------------------------------
% @license
% Copyright 2018 IDAC Signals Team, Case Western Reserve University 
%
% Lincensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public 
% you may not use this file except in compliance with the License.
%
% Unless otherwise separately undertaken by the Licensor, to the extent possible, 
% the Licensor offers the Licensed Material as-is and as-available, and makes no representations 
% or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. 
% This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, 
% non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, 
% whether or not known or discoverable. 
% Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.
%
% To the extent possible, in no event will the Licensor be liable to You on any legal theory 
% (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, 
% consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of 
% this Public License or use of the Licensed Material, even if the Licensor has been advised of 
% the possibility of such losses, costs, expenses, or damages. 
% Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.
%
% The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, 
% to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.
%
% Developed by the IDAC Signals Team at Case Western Reserve University 
% with support from the National Institute of Neurological Disorders and Stroke (NINDS) 
%     under Grant NIH/NINDS U01-NS090405 and NIH/NINDS U01-NS090408.
%              Wanchat Theeranaew
%--------------------------------------------------------------------------
function varargout = ChSelection(varargin)

% CHSELECTION M-file for ChSelection.fig
%      CHSELECTION, by itself, creates a new CHSELECTION or raises the existing
%      singleton*.
%
%      H = CHSELECTION returns the handle to a new CHSELECTION or the handle to
%      the existing singleton*.
%
%      CHSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHSELECTION.M with the given input arguments.
%
%      CHSELECTION('Property','Value',...) creates a new CHSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChSelection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChSelection

% Last Modified by GUIDE v2.5 05-Feb-2015 11:21:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @ChSelection_OutputFcn, ...
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


% --- Executes just before ChSelection is made visible.
function ChSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChSelection (see VARARGIN)

% Choose default command line output for ChSelection

FlagSelectedCh=0;
FlagChMap=0;
if any(strcmp(evalin('base', 'who'), 'SelectedCh'))
    FlagSelectedCh = 1;
end
if any(strcmp(evalin('base', 'who'), 'ChMap'))
    handles.ChMap = evalin('base', 'ChMap');
    FlagChMap = 1;
end

Temp = 5;
FileName = 'Montaj.txt';
Fid = fopen(FileName);
Counter  = 0 ;
Temp = fgetl(Fid);

while ~sum(Temp==(-1))
    Counter = Counter + 1;
    
    Montaj(Counter).Name = Temp;
    % Ch1
    Temp = fgetl(Fid);
    Index=find(Temp==32);
    for i=1:length(Index)
        if i==1
            Montaj(Counter).Ch1{i}=Temp([1:Index(i)-1]);
        else
            Montaj(Counter).Ch1{i}=Temp([Index(i-1)+1:Index(i)-1]);
        end
    end
    i = i + 1;
    Montaj(Counter).Ch1{i}=Temp([Index(i-1)+1:end]);  
    
    
    % Ch2
    Temp = fgetl(Fid);
    Index=find(Temp==32);
    for i=1:length(Index)
        if i==1
            Montaj(Counter).Ch2{i}=Temp([1:Index(i)-1]);
        else
            Montaj(Counter).Ch2{i}=Temp([Index(i-1)+1:Index(i)-1]);
        end
    end
    i = i + 1;
    Montaj(Counter).Ch2{i}=Temp([Index(i-1)+1:end]);
    
    Temp = fgetl(Fid);
    Temp = fgetl(Fid);
end
fclose('all');

handles.Montaj = Montaj;
Temp = [];

for i=1:length(Montaj)
    Temp{i}=Montaj(i).Name;
end

set(handles.EditMontaj,'string',Temp,'value',1);

handles.output = hObject;


if FlagSelectedCh && FlagChMap
    UpdateList(handles)
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChSelection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

uiwait(hObject)

varargout{1} = handles.output;

function SelectedList_Callback(hObject, eventdata, handles)


function SelectedList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Add_Callback(hObject, eventdata, handles)
SelectedCh=evalin('base','SelectedCh');

if get(handles.PopMenuChType,'value')==1
    % ref mode    
    Temp = 1:numel(handles.ChMap);
    Temp(SelectedCh((SelectedCh(:,2)==0),1)) = [];
    
    if ~isempty(Temp)
        SelectedCh=[SelectedCh;[Temp(get(handles.MainList1,'Value')) 0]];
    end

else
    % diff mode
    DiffCh1 =get(handles.MainList1,'value');
    Temp = 1:numel(handles.ChMap);
    Temp([SelectedCh(SelectedCh(:,1)==DiffCh1 & SelectedCh(:,2)~=0 ,2);DiffCh1])=[];
    
    SelectedCh=[SelectedCh;[get(handles.MainList1,'Value') Temp(get(handles.MainList2,'Value'))]];
    
end

assignin('base','SelectedCh',SelectedCh)

UpdateList(handles)


function UpdateList(handles)

SelectedCh=evalin('base','SelectedCh');
if (size(SelectedCh,2) == 1)
   SelectedCh = [SelectedCh, SelectedCh*0];
end

if get(handles.SelectedList,'value')>size(SelectedCh,1)
    set(handles.SelectedList,'value',size(SelectedCh,1))
end

SelectedChMap=[];
for i=1:size(SelectedCh,1)
    if (size(SelectedCh,2) == 1) || (SelectedCh(i,2)==0)
        SelectedChMap{i,1} = handles.ChMap{SelectedCh(i,1)};
    else
        SelectedChMap{i,1} = [handles.ChMap{SelectedCh(i,1)} '-' handles.ChMap{SelectedCh(i,2)}];
    end
end
set(handles.SelectedList,'String',SelectedChMap);

if get(handles.MainList1,'value')==0
    set(handles.MainList1,'value',1)
end


if get(handles.MainList2,'value')==0
    set(handles.MainList2,'value',1)
end

if get(handles.SelectedList,'value')==0
    set(handles.SelectedList,'value',1)
end



if get(handles.PopMenuChType,'value')==1
    % ref mode
    Temp= 1:numel(handles.ChMap);
    Temp(SelectedCh((SelectedCh(:,2)==0),1))=[];

    if get(handles.MainList1, 'value') > length(Temp)
        set(handles.MainList1, 'value', length(Temp))
    end

    set(handles.MainList1,'String',handles.ChMap(Temp));
else
    % diff mode
    
    set(handles.MainList1,'String',handles.ChMap);
    
    DiffCh1 =get(handles.MainList1,'value');
    
    Temp = 1:numel(handles.ChMap);
    Temp([SelectedCh(SelectedCh(:, 1)==DiffCh1 & SelectedCh(:,2)~=0 ,2); DiffCh1])=[];

    if get(handles.MainList2,'value')>length(Temp)
        set(handles.MainList2,'value',length(Temp))
    end
    
    set(handles.MainList2,'String',handles.ChMap(Temp));
end


function Remove_Callback(hObject, eventdata, handles)
    SelectedCh=evalin('base','SelectedCh');
    if ~isempty(SelectedCh)
        SelectedCh(get(handles.SelectedList,'value'),:)=[];
    end
    assignin('base', 'SelectedCh',SelectedCh)
    UpdateList(handles)

function PopMenuChType_Callback(hObject, eventdata, handles)
if get(hObject,'value')==1
    set(handles.MainList2, 'Visible', 'off');
else
    set(handles.MainList2, 'Visible', 'on');
end
    
UpdateList(handles)


% --- Executes on selection change in MainList1.
function MainList1_Callback(hObject, eventdata, handles)
UpdateList(handles)

function ButtonLoad_Callback(hObject, eventdata, handles)

[FileName,FilePath] = uigetfile('.mat');

load([FilePath FileName]);
assignin('base','SelectedCh', SelectedCh)
% SuppAnalysisV33d
UpdateList(handles)
figure(handles.figure1)

function ButtonSave_Callback(hObject, eventdata, handles)

SelectedCh = evalin('base','SelectedCh');

[FileName,FilePath,FilterIndex] = uiputfile('*.mat');

if FilterIndex
    save([FilePath FileName],'SelectedCh')
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)

delete(hObject);

function EditMontaj_Callback(hObject, eventdata, handles)
Sel = get(hObject,'value');
handles.Montaj(Sel);
ChMap = handles.ChMap;

for i=1:length(ChMap)
    Index=find(ChMap{i}>64 & ChMap{i}<91);
    if ~isempty(Index)
        ChMap{i}(Index)=ChMap{i}(Index)+32;
    end
end

SelectedCh=[];
% diff ch;
DesiredCh1=handles.Montaj(Sel).Ch1;
DesiredCh2=handles.Montaj(Sel).Ch2;

for j=1:length(DesiredCh1)
   TempI=[];
   TempJ=[];   
   for i=1:length(ChMap)
      if strcmp(ChMap{i},DesiredCh1{j}) 
         TempI=i;
      end
      if strcmp(ChMap{i},DesiredCh2{j})
         TempJ=i;
      end
   end
   
   if ~isempty(TempI) && ~isempty(TempJ)
      SelectedCh = [SelectedCh;[TempI TempJ]];
   end
end
assignin('base', 'SelectedCh', SelectedCh)
UpdateList(handles)



