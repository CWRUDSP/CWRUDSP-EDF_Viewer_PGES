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
%--------------------------------------------------------------------------
function edf_info = EDF_FileInfo(filename_edf)
    % edf_info = EDF_FileInfo(FileName, read_annotations)
    %--------------------------------------------------------------------------
    % Input
    % FileName : '*.EDF' file name
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    % Version 0.611v
    %  - Can read data for both EDF and EDF+
    %  - For EDF, annotation MUST store in separate text file with Farhad's
    %    format.
    %        - Annotation file MUST has the same name as EDF file but has txt
    %          as a file extension.
    %        - For each line in annotation file, there is one event in the
    %          following format "HH:MM:SS.FFF [Annotation text]".
    %
    %  - All text information are stored in cell array format.
    %  - Time storage of annotation is in seconds (as cell array)
    %  - %todo: Fix Annotation reader
    %--------------------------------------------------------------------------

    if nargin < 2
        read_annotations = false;
    end

    % base edf file load.
    %%%%%%%%%%%%%%%%%%%%%%
    edf_info = EDF_FileInfo_without_annotations(filename_edf);  

    % read farhad key file
    %%%%%%%%%%%%%%%%%%%%%%
    [edf_info.folder, edf_info.name_base, ext]=fileparts(filename_edf);
    edf_info.filename = [edf_info.name_base, ext];
    edf_info.name = [edf_info.name_base, ext];
    edf_info.filepath_data = filename_edf;
    edf_info.filepath_base = fullfile(edf_info.folder, edf_info.name_base);
    edf_info.key_filepath = [edf_info.filepath_base, '_key.txt'];

    [patient_info, success, warning_msg] = PatientKeyInfo.fromFile(edf_info.key_filepath, edf_info.filepath_data);
    edf_info.patient_name = patient_info.patient_name;

    if ~success
        edf_info.warnings = cellflatten(edf_info.warnings, warning_msg);
    end

    annotations_file = AnnotationsFile.empty();
    filename_txt = replext(filename_edf, '.txt');
    filename_json = replext(filename_edf, '.json');
    success=true;
    if exist(filename_json,'file') == 2 % json first if exists
        [annotations_file, success, exception] = AnnotationsFile.fromJSONFile(filename_json);
        edf_info.warnings = cellflatten(edf_info.warnings, exception.message);
    end

    if exist(filename_txt, 'file')==2 || ~success
        [annotations_file, success, exception] = AnnotationsFile.fromTXTFile(filename_txt);
        edf_info.warnings = cellflatten(edf_info.warnings, ['No *.json file: ' exception.message]);
    end

    if ~success
        annotations_file = AnnotationsFile.empty();
        edf_info.warnings = cellflatten(edf_info.warnings, ['No *.txt file: ' exception.message]);
    end

    edf_info.annotations = annotations_file;

    edf_info.ChInfo = EDFChannelInfo(edf_info.ChInfo);
end


function edf_info = EDF_FileInfo_without_annotations(filename)

    [~,~,ext] = fileparts(filename);

    fid=fopen(filename,'r');
    %--------------------------------------------------------------------------
    % Start with reading global information
    %--------------------------------------------------------------------------
    % Version: 8 ascii : version of this data format (0)
    edf_info.Version = 0;
    try
        edf_info.Version = deblank(fread(fid,[1 8],'*char'));
    catch
    end
    % 80 ascii : local patient identification (mind item 3 of the additional EDF+ specs)
    edf_info.PatientIdentification = deblank(fread(fid,[1 80],'*char'));

    % 80 ascii : local recording identification (mind item 4 of the additional EDF+ specs)
    edf_info.LocalRecordingIdentification = deblank(fread(fid,[1 80],'*char'));

    % 8 ascii : startdate of recording (dd.mm.yy) (mind item 2 of the additional EDF+ specs)
    edf_info.StartDate = fread(fid,[1 8],'*char');
    edf_info.StartDate([3 6]) = '//';
    % fprintf('start date: %s\n',edf_info.StartDate)

    % 8 ascii : starttime of recording (hh.mm.ss)
    edf_info.StartTime = fread(fid,[1 8],'*char');
    edf_info.StartTime([3 6]) = '::';
    % fprintf('start time: %s\n',edf_info.StartTime)

    % 8 ascii : number of bytes in header record
    edf_info.HeaderSizeInByte = str2num(deblank(fread(fid,[1 8],'*char')));

    % 44 ascii : reserved
    edf_info.Reserved = deblank(fread(fid,[1 44],'*char'));

    % 8 ascii : number of data records (-1 if unknown, obey item 10 of the additional EDF+ specs)
    edf_info.NumberOfDataRecords = str2num(fread(fid,[1 8],'*char'));

    % 8 ascii : duration of a data record, in seconds
    edf_info.DurationOfEachRecord = str2num(fread(fid,[1 8],'*char'));

    % 4 ascii : number of signals (ns) in data record
    edf_info.NumberOfSignals = str2num(fread(fid,[1 4],'*char'));

    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------

    %--------------------------------------------------------------------------
    % Record Information of Individual Signal Into FileInfo
    % ***Use Farhad's method to read channel data (No loop)
    %--------------------------------------------------------------------------
    ns = edf_info.NumberOfSignals;

    % ns * 16 ascii : ns * label (e.g. EEG Fpz-Cz or Body temp) (mind item 9 of the additional EDF+ specs)
    channel_names = fread(fid, [16 ns], '*char')';
    channel_names = arrayfun(@(channel_i) {deblank(channel_names(channel_i, :))}, 1:ns);

    % ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
    transducer_type = fread(fid,[80 ns],'*char')';
    transducer_type = arrayfun(@(channel_i) {deblank(transducer_type(channel_i, :))}, 1:ns);

    % ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
    physical_dimension = fread(fid,[8 ns],'*char')';
    physical_dimension = arrayfun(@(channel_i) {deblank(physical_dimension(channel_i, :))}, 1:ns);

    % ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
    physical_minimum = str2num(fread(fid,[8 ns],'*char')');

    % ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
    physical_maximum = str2num(fread(fid,[8 ns],'*char')');

    % ns * 8 ascii : ns * digital minimum (e.g. -2048);
    digital_minimum = str2num(fread(fid,[8 ns],'*char')');

    % ns * 8 ascii : ns * digital maximum (e.g. 2047)
    digital_maximum = str2num(fread(fid,[8 ns],'*char')');

    % ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
    prefiltering = fread(fid, [80 ns],'*char')';
    prefiltering = arrayfun(@(channel_i) {deblank(prefiltering(channel_i, :))}, 1:ns);

    % ns * 8 ascii : ns * nr of samples in each data record
    samples_count__per__record = str2num(fread(fid,[8 ns],'*char')');

    % ns * 32 ascii : ns * reserved
    reserved = fread(fid,[32 ns],'*char')';
    reserved = arrayfun(@(channel_i) {deblank(reserved(channel_i, :))}, 1:ns);

    fclose(fid);

    % Store ChInfo and as cell array
    edf_info.ChInfo.single_channels = {};
    for i = 1:edf_info.NumberOfSignals

        next_channel_info.name              = channel_names{i};
        next_channel_info.TransducerType    = transducer_type{i};
        next_channel_info.PhysicalDimension = physical_dimension{i};

        next_channel_info.PhysicalMinimum = physical_minimum(i);
        next_channel_info.PhysicalMaximum = physical_maximum(i);
        next_channel_info.DigitalMinimum = digital_minimum(i);
        next_channel_info.DigitalMaximum = digital_maximum(i);

        next_channel_info.Prefiltering = prefiltering{i};
        next_channel_info.NumberOfSampleInEachRecord = samples_count__per__record(i);
        next_channel_info.Reserved = reserved{i};

        %useful extras but not part of the spec.
        next_channel_info.PhysicalOffset = 0;
        next_channel_info.SamplingRate = samples_count__per__record(i) / edf_info.DurationOfEachRecord;

        edf_info.ChInfo.single_channels = [ edf_info.ChInfo.single_channels, {next_channel_info} ];
    end

    edf_info.ext = '.edf';
    edf_info.warnings = {};
    edf_info.samples_type = 'int16';
    edf_info.ChMap         = channel_names;
    edf_info.samples_count = sum(samples_count__per__record) * edf_info.NumberOfDataRecords;

    edf_info.AllSamplesInEachDataRecord = sum(samples_count__per__record);

    edf_info.Prefiltering = prefiltering;
    edf_info.TransducerType=transducer_type;
end
