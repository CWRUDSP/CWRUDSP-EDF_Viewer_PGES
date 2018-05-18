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
%              James McDonald
%              Bilal Zonjy
%              Wanchat Theeranaew

function varargout = Main(varargin)
% MAIN M-file for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EEGViewer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 18-May-2018 07:15:07

% Begin initialization code - DO NOT EDIT
   gui_Singleton = 1;
   gui_State = struct('gui_Name',       mfilename, ...
       'gui_Singleton',  gui_Singleton, ...
       'gui_OpeningFcn', @Main_OpeningFcn, ...
       'gui_OutputFcn',  @Main_OutputFcn, ...
       'gui_LayoutFcn',  [], ...
       'gui_Callback',   []);
   if nargin && ischar(varargin{1})
       gui_State.gui_Callback = str2func(varargin{1});
   end

   if nargout
       [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
   else
       gui_mainfcn(gui_State, varargin{:});
   end

% End initialization code

% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
   % Choose default command line output for Main
   init_path()
   assignin('base','SumID_B',[])

   assignin('base', 'CID1', [])
   if ~isprop(handles, 'FileName') && ~isfield(handles, 'FileName')

       handles.output = hObject;
       handles.WindowTime = [2 3 4 5 7 8 10 15 20 30 60 90 120 240 840];
       %Include Path so that SuppAnalysis work the same way as BioEKG
       handles.Path = [];
       handles.Paths = {};

       handles.TotalTime.Start = [];
       handles.TotalTime.End = [];

       handles.Spikes=[];

       handles.AnalysisTime =[];
       set(handles.ButtonHighPassFilter,'string',...
           {'off',...
            'to Hz',...
            '2       Sec',...
            '1       Sec',...
            '0.3     Sec',...
            '0.2     Sec',...
            '0.16    Sec',...
            '0.1     Sec',...
            '0.08    Sec',...
            '0.053   Sec' ...
            '0.04    Sec',...
            '0.032   Sec',...
            '0.016   Sec',...
            '0.008   Sec',...
            '0.0053  Sec',...
            '0.004   Sec'});

       % High pass filter type
       % 1 : Time constant second
       % 2 : frequency Hz
       handles.HighPassFilterType=1;

       handles.ExFunCallFileName='';

       Temp = evalin('base','who');
       FlagChMap = any(strcmp('ChMap', Temp));
       FlagSelectedCh = any(strcmp('SelectedCh', Temp));

       if ~FlagSelectedCh 
           assignin('base', 'SelectedCh', [1 0; 2 0; 1 2]); % Default selected ch.
       end

       if FlagSelectedCh && FlagChMap
           SelectedChMap = [];
           handles.ChMap = evalin('base', 'ChMap');
           SelectedCh = evalin('base', 'SelectedCh');
           for i=1:size(SelectedCh,1)
               if (size(SelectedCh,2) == 1) || (SelectedCh(i,2)==0)
                   SelectedChMap{i, 1} = handles.ChMap{SelectedCh(i, 1)};
               else
                   SelectedChMap{i, 1} = [handles.ChMap{SelectedCh(i, 1)} ' - ' handles.ChMap{SelectedCh(i, 2)}];
               end
           end
           handles.SelectedChMap = SelectedChMap;
       end

       handles.FileName = [];
       handles.DataOrg = [];

       %Load Classifier
       %    [ handles.classifier, handles.weights, handles.classifierChMap ] = zLoadClassifier_v2;
       handles.classifierChMap = {'PZ', 'P3', 'P4', 'O1', 'O2'};
       handles.DispClassifierChMap = []; %List of classifier channel map relative to current display channel

       handles = load_config(handles);

       import containers.Map;
       handles.suppression_results = containers.Map();
       import containers.Map;
       handles.annotations_appended = containers.Map();

   end
   guidata(hObject, handles)

   % UIWAIT makes Main wait for user response (see UIRESUME)
   % uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles)
   varargout{1} = handles.output;


function UpdatePlots(handles)
   sr = 200;
   axes(handles.axes1)
   texts = {};
   for n = 1:numel(handles.Comments.Time)
       t = handles.Comments.Time(n)/86400;
       texts{n} = [datestr(t,'HH:MM:SS'), ' - ', handles.Comments.Text{n}];
   end

   set(handles.ListBoxComments, 'string', texts, 'value',1);

   SelectedCh=evalin('base', 'SelectedCh');

   axes(handles.axes1)
   set(gca,'layer','top')

   Time = 0:(size(handles.Data,1)-1);
   Time = Time/sr + get(handles.SliderTime, 'value');

   cla

   ComTime = handles.FileInfo.annotations.Time;
   ComTime = ComTime(:)';

   Temp  = get(handles.PopupSensitivity,'value');
   Temp1 = get(handles.PopupSensitivity,'string');
   Temp = Temp1{Temp};
   Temp = str2num(Temp(1:end-2));
   Sen = Temp;

   handles.RecuV = Temp; % Save uV setting

   line([ComTime;ComTime],[ComTime*0-length(handles.SelectedChMap)*Sen+Sen/2;ComTime*0+Sen/2],...
       'color',[255 0 0]/255,'LineWidth',2)
   hold on

   Temp = Sen;
   % Kevin
   handles.RecuV = Temp; % Save uV setting
   assignin('base','RecuV',handles.RecuV);

   for i=1:length(handles.SelectedChMap)
       plot(Time,handles.Data(:,i)-(i-1)*Temp,'color',[0 0 0],'LineWidth',0.01);
       hold on
   end

   Temp1 = [0 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]+get(handles.SliderTime,'value');
   Temp2 = (-1-length(handles.SelectedChMap))*Temp + Temp/2;

   xlim(Temp1);
   ylim([(-length(handles.SelectedChMap))*Temp 0]+Temp/2);

   %Full montage
   set(gca,'yTick',[-Temp*(length(handles.SelectedChMap)-1):Temp:0]);
   set(gca,'yTickLabel',handles.SelectedChMap([length(handles.SelectedChMap):-1:1]));   

   if get(handles.ButtonGridLines, 'value')
       grid on;
   end
   set(gca,'FontWeight', 'bold')
   hold off
   ylabel('')

   SetAbsTime(handles);

   % Select the comments that is closest to the middle of plot
   Temp = get(handles.SliderTime,'value') + handles.WindowTime(get(handles.PopMenuWindowTime,'value'))/2;
    
   [Min Index] = min(abs(handles.FileInfo.annotations.Time-Temp));

   set(handles.ListBoxComments,'value',Index);

   zoom off;
   pan off;

   Temp = get(handles.axes1,'xlim');

   Start = (Temp(2)-Temp(1))*37/40+Temp(1);
   hold on;
   plot([Start Start],[0 -Sen/4]-Sen/8-(size(SelectedCh,1)-1)*Sen,'color','k','linewidth',4)

   Start = Start+(Temp(2)-Temp(1))/200;
   y = -Sen/4-(size(SelectedCh,1)-1)*Sen;
   text(Start, y, [num2str(Sen/4), ' uV'], 'FontWeight','bold');

function signals = FileReadReferential(handles, a, b, indices)
  
   signals = [];
   sr_ideal = 200;
   t_ideal = linspace(a, b + 1/sr_ideal, sr_ideal * (b - a) + 1);
   for channel_i = indices
      success = false;
      try
         [signal, t] = handles.FileInfo.getChannelSignalByTime(channel_i, a, b);      
         success = true;
         signal_200hz = signal.';
      catch 
      end
      
      % Refresh internal file handle if doesn't work
      if ~success
            handles.FileInfo.dataGetter.close()
            handles.FileInfo.dataGetter.open()          
            [signal, t] = handles.FileInfo.getChannelSignalByTime(channel_i, a, b);      
            success = true;
            signal_200hz = signal.';
      end
      
      
      
      
      
      % Refresh FID
      sr = handles.FileInfo.ChInfo.single_channels{channel_i}.SamplingRate;
      
      if sr < 200
          signal_200hz = interp1(t, signal, t_ideal).';
      elseif sr_ideal > 200
          errordlg('Tool not designed to work on data above 200 Hz')
          
          % Upsample
          % offset = mean(signal);
          % slope_per_sample = mean(diff(signal));          
          % signal_fft = fft(detrend(signal));
      end
      
      if ~numel(signals)
          signals = signal_200hz;
      else
          signals = cat(2, signals, signal_200hz);          
      end
   end
   
   
function handles = FileRead(handles)
   FileName = handles.FileName;
   Temp = [0, handles.TotalTime];
   DataStart = get(handles.SliderTime, 'value');
   DataLength = handles.WindowTime(get(handles.PopMenuWindowTime, 'value'));
   SettlingTime = 3;

   if DataStart<SettlingTime
       DataLength = DataStart + DataLength ;
       DataStart  = 0;
   else
       DataStart  = DataStart-SettlingTime;
       DataLength = DataLength + SettlingTime;
   end

   signals = FileReadReferential(handles, DataStart, DataStart + DataLength, ...
       1:handles.FileInfo.NumberOfSignals);
   SelectedCh = evalin('base', 'SelectedCh');

   handles.DataOrg = zeros(size(signals,1), size(SelectedCh,1));

   % construct the selected referential and differential channels
   for i=1:size(SelectedCh,1)
       if (size(SelectedCh,2) == 1) || (SelectedCh(i,2)==0)
           % referential
           handles.DataOrg(:,i)=signals(:,SelectedCh(i,1));
       else
           % differential
           handles.DataOrg(:,i) = signals(:,SelectedCh(i,1)) - signals(:, SelectedCh(i,2));
       end
   end
   handles = Filtering(handles);

function PopMenuWindowTime_Callback(hObject, eventdata, handles)
   Temp2 = [0 cumsum(handles.TotalTime)];
   Temp2 = Temp2(handles.SelSegment);
   while (handles.TotalTime(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end

   TempMax=handles.TotalTime(handles.SelSegment) - handles.WindowTime(get(handles.PopMenuWindowTime,'value'));

   Temp = [0 cumsum(handles.TotalTime)];
   set(handles.SliderTime, 'Min', Temp(handles.SelSegment));

   if get(handles.SliderTime,'value') > (TempMax+Temp(handles.SelSegment))
       set(handles.SliderTime,'value', TempMax+Temp(handles.SelSegment))
   end
   set(handles.SliderTime,'Max', TempMax+Temp(handles.SelSegment));
   set(handles.SliderTime, 'SliderStep', [1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax)


   handles=FileRead(handles);
   guidata(hObject,handles);

   UpdatePlots(handles)

function SliderTime_Callback(hObject, eventdata, handles)
   Temp=round(get(hObject,'value'));
   set(hObject,'value',Temp);
   handles=FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles)
   uipanel1_CreateFcn

function uipanel1_CreateFcn(hObject, eventdata, handles)
    

function PopupSensitivity_Callback(hObject, eventdata, handles)
   UpdatePlots(handles);


function handles = Filtering(handles)
   sr = 200;
   % get the original data
   handles.Data = handles.DataOrg;
   for i=1:size(handles.DataOrg,2)
       handles.Data(:,i) = filter(handles.TotalFilterB, handles.TotalFilterA, handles.Data(:,i));
   end

   % remove the begining of data to obtain the desired location
   Temp =[0 cumsum(handles.TotalTime)];
   DataStart = get(handles.SliderTime,'value')-Temp(handles.SelSegment);

   SettlingTime = 3;

   if DataStart < SettlingTime
       handles.Data(1:fix(DataStart * sr),:)=[];
   else
       handles.Data(1:fix(SettlingTime * sr),:)=[];
   end

function ButtonGridLines_Callback(hObject, eventdata, handles)
   axes(handles.axes1)
   if get(hObject,'value')
       grid on
   else
       grid off
   end

function ListBoxFileNames_Callback(hObject, eventdata, handles)
   %set(hObject,'BackGroundColor',[70 208 61]/255);
   Sel = get(handles.ListBoxFileNames,'value');
   FileName = [handles.Path, handles.FileList{Sel}];
   
   edf = EDF_File.fromFile(FileName);
   info = {['Patient ID: ', edf.PatientIdentification],...
           ['Local Recording: ', edf.LocalRecordingIdentification],...
           ['Start Date: ', edf.StartDate],...
           ['Start Time: ', edf.StartTime]};    
   set(handles.ListBoxPatientInfo, 'string', info);
   handles.FileName = FileName;
   handles.FileInfo = edf;
   handles.ChMap = edf.ChMap;
   handles.SelSegment = 1;
   handles.Comments = struct;
   handles.Comments.Time = edf.annotations.Time;
   handles.Comments.Text = edf.annotations.Text;
   handles.Comments.Added = [];
   handles.TotalTime = edf.NumberOfDataRecords * edf.DurationOfEachRecord;
   % if there is multiple segment

   handles.ScalingFactor = [];
   if any(strcmp(handles.annotations_appended.keys, handles.FileName))
      handles.Comments = handles.annotations_appended(handles.FileName);
      set(handles.PushButtonRun, 'enable', 'off');
      set(handles.PushButtonExportComments, 'enable', 'on');
   else
      set(handles.PushButtonRun, 'enable', 'on');       
      set(handles.PushButtonExportComments, 'enable', 'off');
   end

   assignin('base', 'ChMap', edf.ChMap);
   guidata(hObject, handles)

   while (handles.TotalTime(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end

   % set slider window time parameters
   TempMax=handles.TotalTime(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value'));
   set(handles.SliderTime,'Min',0);
   set(handles.SliderTime,'value',0);
   set(handles.SliderTime,'Max',TempMax);

   set(handles.SliderTime,'SliderStep', [1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax)

   Temp = evalin('base','who');
   FlagChMap = any(strcmp('ChMap', Temp));
   FlagSelectedCh = any(strcmp('SelectedCh', Temp));

   %%%  Edit Pre set channels
   if ~FlagSelectedCh
       assignin('base', 'SelectedCh', [1 0; 2 0; 1 2]);
   else % Check
       SelectedCh = evalin('base', 'SelectedCh');
       Temp = max(max(SelectedCh));

       if(Temp > length(handles.ChMap)) % Old selected channel exceed current number of channels
          assignin('base', 'SelectedCh', [1 0; 2 0; 1 2]);
       end
   end

   if FlagSelectedCh && FlagChMap
       SelectedChMap = [];
       ChMap = evalin('base','ChMap');
       SelectedCh = evalin('base', 'SelectedCh');
       for i=1:size(SelectedCh,1)
           if (size(SelectedCh,2) == 1) || (SelectedCh(i,2)==0)
               SelectedChMap{i,1} = ChMap{SelectedCh(i,1)};
           else
               SelectedChMap{i,1} = [ChMap{SelectedCh(i,1)} '-' ChMap{SelectedCh(i,2)}];
           end
       end
       handles.SelectedChMap = SelectedChMap;
   end

   handles = FilterDesign(handles);
   handles = FileRead(handles);

   guidata(hObject,handles);
   UpdatePlots(handles)


% --- Executes on selection change in ButtonHighPassFilter.
function ButtonHighPassFilter_Callback(hObject, eventdata, handles)
   switch get(hObject,'value')
       case 2
           if handles.HighPassFilterType==1
               set(hObject,'string', ...
                {'  off',...
                 '  to Sec',...
                 '  0.1 Hz',...
                 '  0.2 Hz',...
                 '  0.3 Hz',...
                 '  0.5 Hz',...
                 '  0.8 Hz',...
                 '  1    Hz',...
                 '  1.6  Hz',...
                 '  2    Hz',...
                 '  4    Hz',...
                 '  5    Hz',...
                 ' 10    Hz',...
                 ' 20    Hz',...
                 ' 30    Hz',...
                 ' 40    Hz'});
               handles.HighPassFilterType = 2;

           else
               set(hObject,'string',...
                {'off',...
                 'to Hz',...
                 '2       Sec',...
                 '1       Sec',...
                 '0.3     Sec',...
                 '0.2     Sec',...
                 '0.16    Sec',...
                 '0.1     Sec',...
                 '0.08    Sec',...
                 '0.053   Sec',...
                 '0.04    Sec',...
                 '0.032   Sec',...
                 '0.016   Sec',...
                 '0.008   Sec',...
                 '0.0053  Sec',...
                 '0.004   Sec'});
               handles.HighPassFilterType = 1;
           end
   end

   handles = FilterDesign(handles);
   handles=Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject,handles);


function PopupLowPassFilter_Callback(hObject, eventdata, handles)
   handles = FilterDesign(handles);
   handles=Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject,handles);


function PopupNotchFilter_Callback(hObject, eventdata, handles)
   handles = FilterDesign(handles);
   handles=Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject,handles);


function ListBoxComments_Callback(hObject, eventdata, handles)
  Index = get(hObject, 'value');

  tmax = handles.TotalTime;
  window_half = handles.WindowTime(get(handles.PopMenuWindowTime,'value'))/2;
  tbeg = handles.FileInfo.annotations.Time(Index);
  tbeg = max(0, tbeg - window_half);
  tbeg = min(tbeg, tmax);

  % set slider window time parameters
  set(handles.SliderTime,'value', tbeg);
  set(handles.SliderTime,'SliderStep', [1, 2 * window_half]/tmax)

  handles = FileRead(handles);
  guidata(hObject,handles);
  UpdatePlots(handles)


function  SetAbsTime(handles)
   Temp = get(gca,'xTick');

   Label=[];

   if max(Temp>3600)
       for i=1:length(Temp)
           Label{i}=datestr([2007 5 25 fix(Temp(i)/3600) fix(Temp(i)/60)-60*fix(Temp(i)/3600)...
               mod(Temp(i),60)],'HH:MM:SS');
       end

   else
       for i=1:length(Temp)
           Label{i}=datestr([2007 5 25 fix(Temp(i)/3600) fix(Temp(i)/60)-60*fix(Temp(i)/3600)...
               mod(Temp(i),60)],'MM:SS');
       end

   end

   set(gca,'xTickLabel',Label);



function handles = FilterDesign(handles)
   rs = 200; 
   FileName=handles.FileName;
   FileName([-2:0]+end) = 'EEG';
   
   %Filter selection
   if get(handles.checkboxCFilter,'value') == 1

      LFcutoff = get(handles.EditLFCutOff,'string');
      HFcutoff = get(handles.EditHFCutOff,'string');
      LFcutoff = str2num(LFcutoff);
      HFcutoff = str2num(HFcutoff);

      Temp = get(handles.popupmenuFilterType,'value');
      switch Temp
         case 1
            [TotalFilterB, TotalFilterA] =  butter(6, 2*[LFcutoff HFcutoff]/Fs);
         case 2
            [TotalFilterB, TotalFilterA] = cheby1(3, 3, 2*[LFcutoff HFcutoff]/Fs);
         case 3
            [TotalFilterB, TotalFilterA] = cheby2(4, 40, 2*[LFcutoff HFcutoff]/Fs);
         case 4
            [TotalFilterB, TotalFilterA] = ellip(2, 3, 40, 2*[LFcutoff HFcutoff]/Fs);
      end
   else
      % The filtering is beging done in just one step
      % whenever each of the notch, high pass or low pass is used the calculated
      % filter paramters is convolved with the TotalFilterA and TotalFilterB
      TotalFilterA=1;
      TotalFilterB=1;

      % notch filter
      sr = handles.FileInfo.ChInfo.single_channels{1}.SamplingRate;
      switch get(handles.PopupNotchFilter,'value')
         case 2 % 60Hz Notch Filter`
            wo = 60/(sr/2);  
            bw = wo/35;
            [B,A] = iirnotch(wo,bw); % design the notch filter for the given sampling rate

            TotalFilterA = conv(TotalFilterA,A);
            TotalFilterB = conv(TotalFilterB,B);

         case 3 % 50Hz Notch Filter
            wo = 50/(sr/2);  
            bw = wo/35; % design the notch filter for the given sampling rate
            [B,A] = iirnotch(wo,bw);

            TotalFilterA = conv(TotalFilterA,A);
            TotalFilterB = conv(TotalFilterB,B);
      end

      % low passs filtering
      if get(handles.PopupLowPassFilter,'value')>1
         Temp=get(handles.PopupLowPassFilter,'value');
         Temp1=get(handles.PopupLowPassFilter,'string');
         Temp = cell2mat(Temp1(Temp));
         Temp = str2num(Temp(1:end-2));
         [B,A] = butter(2,Temp/sr*2,'low');
         TotalFilterA = conv(TotalFilterA,A);
         TotalFilterB = conv(TotalFilterB,B);
      end

      % High pass filtering
      if get(handles.ButtonHighPassFilter,'value')>2

          Temp=get(handles.ButtonHighPassFilter,'value');
          Temp1=get(handles.ButtonHighPassFilter,'string');
          Temp = cell2mat(Temp1(Temp));
          Temp = str2num(Temp(1:end-3));

          % High pass filter type
          % 1 : Time constant second
          % 2 : frequency Hz

          % design the filter according to filter type
          if handles.HighPassFilterType~=2
              Temp=1/(2*pi*Temp);
          end
          [B,A] = butter(1,Temp/sr*2,'high');

          TotalFilterA = conv(TotalFilterA,A);
          TotalFilterB = conv(TotalFilterB,B);
      end
   end

   handles.TotalFilterA=TotalFilterA;
   handles.TotalFilterB=TotalFilterB;


% --- Executes on button press in PushButtonSelectCh. 
function PushButtonSelectCh_Callback(hObject, eventdata, handles)
   assignin('base', 'ChMap', handles.ChMap);
   
   ChSelection;

   SelectedChMap=[];
   handles.ChMap=evalin('base','ChMap');
   SelectedCh=evalin('base', 'SelectedCh');
   for i=1:size(SelectedCh,1)
       if (size(SelectedCh,2) == 1) || (SelectedCh(i,2)==0)
           SelectedChMap{i,1} = handles.ChMap{SelectedCh(i,1)};
       else
           SelectedChMap{i,1} = [handles.ChMap{SelectedCh(i,1)} '-' handles.ChMap{SelectedCh(i,2)}];
       end
   end
   handles.SelectedChMap = SelectedChMap;
    
   handles = FileRead(handles);


   %Make list for classifier and display channel map
%    handles = GetClassifierDisplayChMap(handles);

   UpdatePlots(handles);
   guidata(hObject,handles);

function p = GetExistingPath(paths)
    index = find(cellfun(@exist, paths), 1);
    if any(index)
        p = paths{index};
    else
        p = '';
    end

function spath = get_suggested_path(handles)
    spath = '';    
    paths = {handles.Path, handles.Paths{:}};
    paths(:) = cellfun(@(s) {char(s)}, paths);
    if numel(paths)
        exst = cellfun(@exist, paths);
        indices = find(exst > 0, 1);
        if ~isempty(indices)
            spath = paths{indices(1)};
        end
    end
    
function path = run_uigetdir(handles)
    
    spath = get_suggested_path(handles);
    if isempty(spath)
        path = uigetdir;
    else
        path = uigetdir(spath);
    end    

function EditMRN_Callback(hObject, eventdata, handles)

   if isempty(handles.Path)
        
       path = run_uigetdir(handles);
       if 0 == exist(path)
           return
       end
       handles.Path = [path, separator()];
       save_config(handles)
       
       Temp = dir([handles.Path, '*.EEG']);

       for i=1:length(Temp)
           handles.FileList{i}= Temp(i).name;
           handles.Mrn(i) = getMrn([handles.Path, handles.FileList{i}]);
       end
   end


   Temp = str2num(get(hObject,'string'));
   Index = find(handles.Mrn==Temp);


   Temp = [];
   for i=1:length(Index)
       Temp1 = handles.FileList{Index(i)};
       Fid = fopen([handles.Path, Temp1],'r');
       Temp1([-3:0]+end)=[];
       Temp{i}=[num2str(i) '. ' Temp1];

       fseek(Fid,64,'bof');
       Temp1 = char(fread(Fid,[1 14],'uint8'));

       Temp{i} = [Temp{i} ' ' Temp1(5:6) '/' Temp1(7:8) '/' Temp1(1:4) ' ' Temp1(9:10) ':' Temp1(11:12) ':' Temp1(13:14)];

       fclose('all');
   end

   set(handles.ListBoxFileNames,'string',Temp,'value',1);

   guidata(hObject,handles)

%sec2clk.m
function [clk] = sec2clk(sec)
   %[clk]=sec2clk(sec)
   %
   %   Input:
   %
   %   sec:    time in seconds
   %
   %   Output:
   %
   %   clk:    time format 'HH:MM:SS'
   %
   if(~isnumeric(sec) | length(sec)~=1) disp('sec input not numeric scalar');
       return; end

   Hours=floor(sec/3600);Mins=floor((sec-3600*Hours)/60);
   Secs=sec-3600*Hours-60*Mins;

   if(Hours<10) HH=['0' num2str(Hours)]; else HH=num2str(Hours); end
   if(Mins<10) MM=['0' num2str(Mins)]; else MM=num2str(Mins); end
   if(Secs<10) SS=['0' num2str(Secs)]; else SS=num2str(Secs); end

   clk=[HH ':' MM ':' SS];



% --- Executes on selection change in ListBoxSegments.
function ListBoxSegments_Callback(hObject, eventdata, handles)
   Sel=get(hObject,'value');
   handles.SelSegment = Sel;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while (handles.TotalTime(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value')))<=0
       Temp=get(handles.PopMenuWindowTime,'value');
       set(handles.PopMenuWindowTime,'value',Temp-1);
   end

   % set slider window time parameters
   TempMax=handles.TotalTime(handles.SelSegment)-handles.WindowTime(get(handles.PopMenuWindowTime,'value'));
   Temp = [0 cumsum(handles.TotalTime)];
   set(handles.SliderTime,'Min',Temp(Sel));
   set(handles.SliderTime,'value',Temp(Sel));
   set(handles.SliderTime,'Max',TempMax+Temp(Sel));

   set(handles.SliderTime,'SliderStep',[1 handles.WindowTime(get(handles.PopMenuWindowTime,'value'))]/TempMax)

   handles=FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles)

function Mrn = getMrn(FileName)
   FileName([-2:0]+end) = 'PNT';

   Fid = fopen(FileName,'r');

   if Fid < 0
       Mrn = 0;
   else

       fseek(Fid,128+18,'bof');
       StartPatInfoBl=fread(Fid,1,'uint32');
       fseek(Fid,StartPatInfoBl+17,'bof');
       NumData = fread(Fid,1,'uint8');
       Temp = fread(Fid,[4 NumData],'uint8');
       Temp = Temp(1:2,:);
       fseek(Fid,Temp(1),'cof');

       TempMrn=str2num(char(fread(Fid,[1 Temp(2)],'uint8')));

       if isempty(TempMrn)
           Mrn = 0;
       else
           Mrn = TempMrn;
       end
       fclose(Fid);
   end   

   
function PushButtonRun_Callback(hObject, eventdata, handles)
    %    words_beg = {'eeg onset',...
    %                 'clinical onset',...
    %                 'eeg onset[v]'};
   if isempty(handles.DataOrg) % todo: meant to be Referential ? 
       return
   end
   
   words_end = {'eeg seizure end', 'eeg seizure end[v]'};
   sz_end_indices = [];
   
   supp_exists = {};
   eeg_seizures_end = {}; 
   
   %Search for clinical annotation for EEG Seizure End
   Text = handles.FileInfo.annotations.Text;
   sz_end_indices = [];
   for c = 1:length(Text)
      line = lower(Text{c});
      line(line==0) = [];
      if any(strcmp(line, words_end))
         sz_end_indices(end+1) = c; % EEG Seizure End
      end
   end
   if isempty(sz_end_indices)
      msgbox('Auto Detection could not be run. No seizures Found.', '', 'modal');
      return
   end
   
  % Windows of direct interest.
  Time = handles.FileInfo.annotations.Time;
  beg_windows = Time(sz_end_indices);
  end_windows = [beg_windows(2:end) + 180; beg_windows(end) + 180];  
  end_windows(end_windows - beg_windows > 180) = beg_windows + 180;

  end_segments = cumsum(handles.TotalTime);

  preds = {};
  p_begs = {};
  p_ends = {};
  p_durs = {};
  added_times = [];
  added_texts = {};
  times = {};

  mov_mean = 5;
  window_results = {};
  for n = 1:numel(beg_windows)
      
     % Get appropriate segment     
     beg_window = max(0, beg_windows(n));
     beg_padded_ideal = beg_window - mov_mean + 1;
     beg_padded = max(0, beg_padded_ideal);

     end_window = min(end_windows(n), handles.TotalTime);
     end_padded_ideal = end_window + mov_mean - 1;
     end_padded = min(end_padded_ideal, handles.TotalTime);
     
     % Read segment.
     sr = 200;
     data_referential = FileReadForDetection(handles, beg_padded, end_padded);
     
     % Determine number of samples ideally.
     num_samples = size(data_referential, 1);
     dur_window_ideal = end_padded_ideal - beg_padded_ideal;
     num_samples_ideal = round(dur_window_ideal * sr);

     % Determine ratio of different padding.
     end_pad_remainder = max(end_padded_ideal - end_padded, 0) + .5/sr;
     beg_pad_remainder = max(beg_padded - beg_padded_ideal, 0) + .5/sr;
     pad_ratio = beg_pad_remainder/(beg_pad_remainder + end_pad_remainder);
     
     % Determine beg/end number of samples padding.
     num_pad = num_samples_ideal - num_samples;
     num_beg_pad = round(pad_ratio * num_pad);
     num_end_pad = num_pad - num_beg_pad;
     
     num_channels = size(data_referential, 2);
     if num_beg_pad > 0
         % perform linear_ramp interpolation up to data_referential(1, :);
         beg_pad = data_referential(1, :) .* (0:num_beg_pad-1).' .* ones(1, num_channels) / num_beg_pad;
         data_referential = [beg_pad; data_referential];
     end
   
     if num_end_pad > 0
         % perform linear_ramp interpolation from data_referential(1, :);
         end_pad = data_referential(end, :) .* (num_end_pad-1:-1:0).' .* ones(1, num_channels) / num_end_pad;
         data_referential = [data_referential; end_pad];
     end
     
     handles.data_referential = data_referential;
     [times{end+1}, preds{end+1}, p_begs{end+1}, p_ends{end+1}, p_durs{end+1}] = SuppressionClassifier(handles, sr, mov_mean, beg_padded);
     times{n} = times{n}(mov_mean:end - mov_mean + 1);
     preds{n} = preds{n}(mov_mean:end - mov_mean + 1);
   
     diff_preds = diff(preds{n});
       
      % Determine Suppression Beginning, first point when diff_preds == 1
       idx_supp_beg = find(diff_preds == 1, 1);
       if isempty(idx_supp_beg) && preds{n}(1) == 1
           idx_supp_beg = 0;
       end
  
       has_supp = ~isempty(idx_supp_beg);
       supp_beg = nan;
       if has_supp
           added_texts{end+1} = 'PGES Begin[Auto]';
           supp_beg = beg_window + idx_supp_beg;
           added_times(end+1) = supp_beg;
       else
           added_texts{end+1} = 'No PGES[Auto]';
           added_times(end+1) = beg_window + 1;
       end
           
      % Determine Suppression Ending
       idx_supp_end = find(diff_preds == -1, 1);
       if isempty(idx_supp_end)
           idx_supp_end = numel(preds);
       end

       if ~isempty(idx_supp_end) && has_supp
           added_texts{end+1} = 'PGES End[Auto]';
           supp_end = beg_window + idx_supp_end;
           added_times(end+1) = supp_end;
       elseif preds{n}(end) == 1 && has_supp
           added_texts{end+1} = 'PGES Cont?[Auto]';
           supp_end = beg_window + numel(preds);
           added_times(end+1) = supp_end;
       else
           supp_end = nan;
       end

       window_results{end+1} = {beg_windows(n), has_supp, supp_beg, supp_end, times{n}, p_begs{n}, p_ends{n}, p_durs{n}};
  end
  if ~any(strcmp(handles.suppression_results.keys, handles.FileName))
      handles.suppression_results(handles.FileName) = window_results;
      times = [[handles.FileInfo.annotations.Time], added_times];
      added_mask = 1:numel(times) > numel(handles.FileInfo.annotations.Time);
      texts = {handles.FileInfo.annotations.Text{:}, added_texts{:}};
      [handles.Comments.Time, indices] = sort(times);
      handles.Comments.Text = texts(indices);
      handles.Comments.Added = added_mask(indices);
      handles.FileInfo.annotations.add(added_times, added_texts);
      handles.annotations_appended(handles.FileName) = handles.Comments;
      msgbox(['Auto Detection is completed for ', num2str(numel(sz_end_indices)), ' seizures.'], '', 'modal');

      set(handles.PushButtonRun,'enable','off');
      set(handles.PushButtonExportComments,'enable','on');
      set(handles.exportAllResults, 'enable', 'on');
      set(handles.exportAllResults, 'String', ['Export All Results (', num2str(handles.suppression_results.length), ' Files).']);
   end


   handles = FileRead(handles);
   guidata(hObject,handles);
   UpdatePlots(handles);


function signals_ref = FileReadForDetection(handles, time_beg, time_end)

   file_chmap = lower(cellfun(@(s) {char(s)}, handles.ChMap)).';

   ind_found = [] ;
   mask_found = false(numel(file_chmap), 1);
   for n = 1:numel(handles.classifierChMap)
      mask = strcmp(lower(handles.classifierChMap{n}), file_chmap);
      ind_found = [ind_found, find(mask & ~mask_found)];
      mask_found = mask_found | mask;
   end
   signals_ref = FileReadReferential(handles, time_beg, time_end, ind_found);
   
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
    Sel = get(handles.PopupSensitivity, 'value');
    Temp = get(handles.PopupSensitivity, 'String');
    Temp = length(Temp);
    if(eventdata.VerticalScrollCount == -1) %Up
       Sel = max(1,Sel-1);
    elseif(eventdata.VerticalScrollCount == 1) %Down
       Sel = min(Temp,Sel+1);
    end
    set(handles.PopupSensitivity, 'value', Sel);

    UpdatePlots(handles);

    
function handles = load_config(handles)
    s.paths = {};
    if exist('.config','file') == 2
        s = load('.config', 'paths', '-mat');
    end
    if numel(s.paths)    
        handles.Paths = s.paths(2:end);
        handles.Path = s.paths{1};        
    else        
        handles.Path = '';
    end
    
function save_config(handles)
    paths = {handles.Path, handles.Paths{:}};
    [~, indices] = unique(paths);
    paths = paths(sort(indices));
    save('.config', 'paths', '-mat')
    
% --- Executes on button press in ButtonSelectDir.
function ButtonSelectDir_Callback(hObject, eventdata, handles)
    
    folder= run_uigetdir(handles);
    
    if folder == 0
        return
    end
    if exist(folder, 'dir') ~= 7
       return
    end
    handles.Path = [folder, separator()];
    save_config(handles)
    
    dirs = dir([handles.Path, '*.edf']);

    FileName = [];
    handles.FileList = {dirs.name};
    
    files = [];
    for i=1:length(handles.FileList)
       fp = [handles.Path, handles.FileList{i}];
       edf = EDF_FileInfo(fp);
       files{i} = [edf.LocalRecordingIdentification, ' ', edf.StartDate, ' ', edf.StartTime];
    end

    set(handles.ListBoxFileNames,'string',files,'value',1);

    guidata(hObject,handles)



function checkboxCFilter_Callback(hObject, eventdata, handles)
   handles = FilterDesign(handles);
   handles = Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject,handles);

function popupmenuFilterType_Callback(hObject, eventdata, handles)
   handles = FilterDesign(handles);
   handles = Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject,handles);

function EditLFCutOff_Callback(hObject, eventdata, handles)
   handles = FilterDesign(handles);
   handles = Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject,handles);

function EditHFCutOff_Callback(hObject, eventdata, handles)
   handles = FilterDesign(handles);
   handles = Filtering(handles);
   UpdatePlots(handles)
   guidata(hObject, handles);

function exportAllResults_Callback(hObject, eventdata, handles)
    
    % Get all results from handles.suppression_results and save in csv file
    
    % Construct filename for results file.
    filepath_as_filename = pwd;
    filepath_as_filename(filepath_as_filename==':') = [];
    filepath_as_filename(filepath_as_filename==separator) = '.';
    filepath_as_filename = [filepath_as_filename ' ' datestr(now,'mm-dd-yyyy HH-MM-SS')];
    filepath_as_filename = [pwd, separator(), filepath_as_filename, '.csv'];
    [fn, fp] = uiputfile('*.csv', 'Select Results CSV Name', filepath_as_filename);
    
    if (any(fn == 0) || any(fp == 0)) && numel(fn) * numel(fp) == 1
        return 
    end
    fp = [fp separator() fn];
    
    % {beg_windows, n_segment, has_supp, supp_beg, supp_end, times, p_begs, p_ends, p_durs};    
    % Construct csv text from results.
    [~, indices] = sort(handles.suppression_results.keys);
    rows = {'Filename, Seizure End (s), Suppression Exists, Prob Suppression Exists, Begin Time (s), End Time (s), Peak Epoch Prob Beg, Peak Epoch Prob End'};
    for n = indices
        filepaths = handles.suppression_results.keys;
        [~, filename, ext] = fileparts(filepaths{n});
        row = handles.suppression_results(filepaths{n});
        for m = 1:numel(row)
            r = {};
            r{end+1} = num2str(row{m}{1}); % Beg window
            r{end+1} = num2str(single(row{m}{2})); % has segment
            
            
            % Get distribution p_beg and compute prob it exists.
            p_beg = row{m}{6};
            p_beg = p_beg(1:min(numel(p_beg), 15)); % 
            r{end+1} = num2str(min(.99, max(.01, sum(p_beg)))) ;

            % Continue
            r{end+1} = num2str(row{m}{3}); % supp beg
            r{end+1} = num2str(row{m}{4}); % supp end
            r{end+1} = num2str(max(row{m}{6})); % peak epoch prob beg
            r{end+1} = num2str(max(row{m}{7})); % peak epoch prob end
            rows{end + 1} = [filename, ext, ', ', strjoin(r, ', ')];
        end
    end
        
    rows{end+1} = '';
    rows = strjoin(rows, ',\r\n');
    % Write to file.
    fid = fopen(fp, 'w');
    fprintf(fid, rows);
    fclose(fid);
    
    rows = {'Filename, Information Type, Distribution'};
    for n = indices
        filepaths = handles.suppression_results.keys;
        [~, filename, ext] = fileparts(filepaths{n});
        row = handles.suppression_results(filepaths{n});
        for m = 1:numel(row)
            infos = {'time', 'p_beg', 'p_end', 'p_dur'};
            for c = numel(row{m})-3:numel(row{m})
                r = arrayfun(@(v) {num2str(v)}, row{m}{c});
                r = strjoin(r, ', ');
                rows{end+1} = strjoin({filename, infos{c-4}, r}, ', ');
            end
        end
    end
        
    [folder, filename, ext] = fileparts(fp);
    fp_dist = [folder, separator(), [filename, '.dist', ext]];
    
    rows{end+1} = '';
    rows = strjoin(rows, ',\r\n');
    
    % Write to file.
    fid = fopen(fp_dist, 'w');
    fprintf(fid, rows);
    fclose(fid);


function PushButtonExportComments_Callback(hObject, eventdata, handles)
   choice = questdlg({
       'Would you like to export auto detection to a data file?',...
       '***This will modify the EDF data file.***'}, ...
       'Confirmation','Yes',...
       'No','Cancel','No');

   if strcmp(choice,'Yes')

      %Add comment into data file there is no return from this point
      if any(handles.Comments.Added)

         if exist(handles.FileInfo.annotations.filepath_txt, 'file') == 2
            filepath_new = [handles.FileInfo.annotations.filepath_txt(1:end-4), '.bak'];
            if exist(filepath_new, 'file') ~= 2
               copyfile(handles.FileInfo.annotations.filepath_txt, filepath_new, 'f');
            end
         end

         handles.FileInfo.annotations.saveTXTFile();
         msgbox('Completed exporting PGES Detection to annotations.', '', 'modal');
         guidata(hObject, handles);         
      end

      try
      catch e
         errordlg({'There is unexpected error!!', 'Cannot export auto detection to data file.'}, '', 'modal');
      end
   end

function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
