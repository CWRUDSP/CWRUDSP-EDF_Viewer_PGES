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
classdef EDF_File < DataFile
    % todo: not sure which we need -  % they are different enough that I can't lazily delete one of them.
    %   parse_edf_plus_tals_block_string
    %   parse_edf_plus_block_tal


    properties
        HeaderSizeInByte;               % HeaderBytes
        PatientIdentification;          % patient id
        LocalRecordingIdentification;   % patient id
        Version;
        Reserved;
        Prefiltering;
        TransducerType;
        patient_name;         % should be for NK as well.
        dataGetter;
    end

%     properties(Access='private')
%         dataGetter;
%     end

    properties(Constant)
        DIG_MIN = double(intmin('int16'));
        DIG_MAX = double(intmax('int16'));
    end

    % key_file_exist;     %should be for NK as well.
    % TotalTime
    % NumCh
    % total_duration
    % samples_count
    % samples_type
    % SegmentStartTime
    % AllSamplesInEachDataRecord
    % ChInfo
    % NumberOfSignals
    % DurationOfEachRecord
    % NumberOfDataRecords
    % ChMap
    % SamplingRate
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %   PROTECTED -- OVerride
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   PUBLIC - OVERRIDE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access = 'public', Static)
        function are = areInstanceFields(fields)
            are = strcmpi(fields,'DIG_MIN') |...
                  strcmpi(fields,'DIG_MAX');
        end
        function str = to_string_static(file_info)
            warning off all;
            str = savejson(struct(file_info));
            warning on all;
        end
        function edf = fromFile(edf_file_path)
            edf_metadata = EDF_FileInfo(edf_file_path);
            edf = EDF_File(edf_metadata);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   PUBLIC - NEW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function self = EDF_File(edf_metadata)

            super = DataFile();
            super_fields = properties(super);
            super_values = cellfun(@(f) {edf_metadata.(f)}, super_fields);

            super_md = cell2struct(super_values, super_fields);

            self = self@DataFile(super_md);

            fields = properties(self);
            fields = fields(~strcmp(fields,'DIG_MIN'));
            fields = fields(~strcmp(fields,'DIG_MAX'));
            fields = fields(~strcmpi(fields,'dataGetter'));


            fdiff = stringsetdiff(fields, fieldnames(edf_metadata));
            assert(numel(fdiff)==0, 'field diff: %s', strjoin(fdiff,', '));

            self.dataGetter = EDFDataGetter(self);

            for i=1:numel(fields)
                f = fields{i};
                if ~isfield(super, f)
                    self.(f) = edf_metadata.(f);
                end
            end
        end

        function sc = segments_count(self)
            sc = 1;
        end

        function movefile(self, new_folder)
            assert(exist(new_folder,'dir')==7)

            fclose('all')

            filepath_data_old = self.filepath_data;

            self.folder = new_folder;
            self.filepath_data = joinpath(new_folder, self.name);
            self.filepath_base = joinpath(new_folder, self.name_base);

            if exist(filepath_data_old,'file')==2
                self.dataGetter.close()
                [SUCCESS,MESSAGE,MESSAGEID] = movefile(filepath_data_old, self.filepath_data)
                self.dataGetter.open(self.filepath_data);
            end

            self.annotations.movefile(new_folder);
            self.getPatientInfo.movefile(new_folder);
        end

        function [mrn, success] = getMRNfromPatientID(self)
            mrn=-1;
            success=true;
            try
                strs = strsplit(self.PatientIdentification,':');
                str = strtrim(strs{2});
                mrn= str2num(str);
                if isempty(mrn)
                    success=false;
                end
            catch
                success=false;
            end
        end
        function b = is_edf_plus(self)
            b = strcmpi(self.Reserved,'edf+');
        end
        function b = is_edf_plus_discontigous(self)
            b = strcmpi(self.Reserved,'edf+d');
        end
        function b = is_edf_plus_contigous(self)
            b = strcmpi(self.Reserved,'edf+c');
        end
        function b = is_edf_original(self)
            b = ~self.is_edf_plus_contigous() && ~self.is_edf_plus_discontigous();
        end

        function b = is_nk(self)
            b = false;
        end
        function b = is_edf(self)
            b = true;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   GETTERS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [ch_signal, ch_time, success, modified, exception] = getChannelSignalByTime(self, channel_i, beg_time, end_time)
            success = true;
            modified = false;
            exception = MException('EDF_File:getChannelSignalByTime:NoError','');
            [beg_index, end_index] = self.dataGetter.getIndecesByTime(channel_i, beg_time, end_time);
            [ch_signal, ch_time] = self.getChannelSignal(channel_i, beg_index, end_index);
        end
        function [ch_signal, ch_time, success, modified, exception] = getChannelSignal(self, channel_i, beg_index, end_index)

            success = true;
            modified = false;
            exception = MException('EDF_File:getChannelSignalByTime:NoError','');

            self.dataGetter.loadChannelBuffer(channel_i, beg_index, end_index);
            ch_signal = self.dataGetter.castBufferToUnits(channel_i, self.dataGetter.getChannelBuffer(channel_i, beg_index, end_index));
            ch_time = getChannelTime(self, channel_i, beg_index, end_index);
        end
        function channel_time = getChannelTimeByTime(self, channel_id, beg_time, end_time)
            [beg_index, end_index] = self.dataGetter.getIndecesByTime(channel_i, beg_time, end_time);
            channel_time = self.dataGetter.getChannelTime(channel_id, beg_index, end_index);
        end

        function channel_time = getChannelTime(self, channel_id, beg_index, end_index)
            channel_time = self.dataGetter.getChannelTime(channel_id, beg_index, end_index);
        end

        function patient_info = getPatientInfo(self)
            patient_info = struct('mrn',        self.getMRNfromPatientID(),...
                                  'filename',   self.filename,...
                                  'patient_name', self.patient_name,...
                                  'key_filepath', self.key_filepath);
            patient_info = PatientKeyInfo(patient_info);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%
        % Getters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setChInfo(self, ch_info)
            assert(isa(ch_info, 'EDFChannelInfo'))
            assert(ch_info.channels_count==self.ChInfo.channels_count);

            self.ChInfo = ch_info;
        end
        function c = channels_count(self)
            c = self.ChInfo.channels_count;
        end

        function pid_str = patient_id_str(self)
            cells = strtrim(strsplit(self.PatientIdentification, ':'));
            if numel(cells)==1
                pid_str = '';
            else
                pid_str = cells{end};
            end
        end

        function cn = center_name(self)
            cells = strtrim(strsplit(self.PatientIdentification, '--'));
            cn = cells{1};
        end

        function display_channel_names = getDisplayChannelNames(self, segment_i)
            if nargin == 2
                assert(segment_i==1, 'segment_i must be 1 for class EDF_File');
            end
            display_channel_names = self.ChInfo.displayChannelNames();
        end
        function channel_names = getChannelNames(self, segment_i)
            if nargin == 2
                assert(segment_i==1, ' Must have segment_i==1 for class EDF_File');
            end
            channel_names = self.ChInfo.ChMap;
        end
        function header_lines = getHeaderDisplayString(self, school_name)
            header_string = self.getHeaderString(school_name);
            padding = 256 * (self.channels_count + 1) - numel(header_string);
            header_string = [header_string, repmat(char(0),[1, padding])];

            header_lines = {};
            header_lines{1}  = sprintf('                   EDF Version: `%s`', header_string(1:8));
            header_lines{2}  = sprintf('  Local Patient Identification: `%s`', header_string(9:88));
            header_lines{3}  = sprintf('Local Recording Identification: `%s`', header_string(89:168));
            header_lines{4}  = sprintf('          Recording Start Date: `%s`', header_string(169:176));
            header_lines{5}  = sprintf('          Recording Start Time: `%s`', header_string(177:184));
            header_lines{6}  = sprintf('  Recording Header Bytes Count: `%s`', header_string(185:192));
            header_lines{7}  = sprintf('                    EDF Format: `%s`', header_string(193:236));
            header_lines{8}  = sprintf('            Data Records Count: `%s`', header_string(237:244));
            header_lines{9}  = sprintf(' Duration of Data Record (sec): `%s`', header_string(245:252));
            header_lines{10} = sprintf('             Number of Signals: `%s`', header_string(253:256));

            header_lines{11} = '';
            header_lines{12} = '------------------------------';

            channel_lines = cell(self.channels_count+2, 10);
            channel_aspects = {'label','trans type','unit','phys min','phys max', 'dig min','dig max','prefilter','samples/rec','reserved'};
            bytes = [16, 80, 8, 8, 8, 8, 8, 80, 8, 32];
            pos = 257;
            for ca = 1:10
                channel_column = arrayfun(@(l) {header_string(l:(l + bytes(ca) - 1))}, pos + bytes(ca) * (0:self.channels_count-1));
                channel_lines(:,ca) = create_column_of_cells(channel_column, channel_aspects{ca});
                pos = pos + self.channels_count * bytes(ca);

                % header_lines{end+1};
            end

            for row = 1:(self.channels_count+2)
                header_lines{end+1} = strjoin(channel_lines(row,:),', ');
            end
            header_lines = strjoin(header_lines, '\n\t');

            % % Labels -- 16
            % % Transducer Types -- 80
            % pos = pos + 16 * channels_count;
            % transducer_types = arrayfun(@(l) {header_string(l:l+79)}, pos + 80 * (0:channels_count-1));
            % transducer_types = create_column_of_cells(transducer_types, 'tr.duc. type');

            % % Physical dimension -- 8 bytes
            % pos = pos + 80 * channels_count;
            % physical_dims = arrayfun(@(l) {header_string(l:l+79)}, pos + 8 * (0:channels_count-1));
            % physical_dims = create_column_of_cells(physical_dims, 'unit');

            % % Physical minimum -- 8 bytes
            % pos = pos + 8 * channels_count;
            % physical_mins = arrayfun(@(l) {header_string(l:l+79)}, pos + 8 * (0:channels_count-1));
            % physical_mins = create_column_of_cells(physical_mins, 'phys min');

            % % Physical maximum -- 8 bytes
            % pos = pos + 8 * channels_count;
            % physical_maxes = arrayfun(@(l) {header_string(l:l+79)}, pos + 8 * (0:channels_count-1));
            % physical_maxes = create_column_of_cells(physical_maxes, 'phys max');

            % % Digital minimum -- 8 bytes
            % pos = pos + 8 * channels_count;
            % digital_mins = arrayfun(@(l) {header_string(l:l+79)}, pos + 8 * (0:channels_count-1));
            % digital_mins = create_column_of_cells(digital_mins, 'dig min');

            % % Digital maximums -- 8 bytes
            % pos = pos + 8 * channels_count;
            % digital_maxes = arrayfun(@(l) {header_string(l:l+79)}, pos + 8 * (0:channels_count-1));
            % digital_maxes = create_column_of_cells(digital_maxes, 'dig max');

            % % Prefilterings -- 80 bytes
            % pos = pos + 8 * channels_count;
            % prefilterings = arrayfun(@(l) {header_string(l:l+79)}, pos + 80 * (0:channels_count-1));
            % prefilterings = create_column_of_cells(prefilterings, 'prefiltering');

            % % number of samples per record -- 8 bytes
            % pos = pos + 80 * channels_count;
            % samples_per_record = arrayfun(@(l) {header_string(l:l+79)}, pos + 8 * (0:channels_count-1));
            % samples_per_record = create_column_of_cells(samples_per_record, 'smps/rcrd');

            % % number of samples per record -- 32 bytes
            % pos = pos + 8 * channels_count;
            % channel_reserved = arrayfun(@(l) {header_string(l:l+79)}, pos + 32 * (0:channels_count-1));
            % channel_reserved = create_column_of_cells(channel_reserved, 'reserved');

        end
        function header = getHeaderString(self, school_name)
            % #1  -- 8  ascii : version of this data format (0)
            % #2  -- 80 ascii : local patient identification
            % #3  -- 80 ascii : local recording identification
            % #4  -- 8  ascii : startdate of recording (dd.mm.yy)
            % #5  -- 8  ascii : starttime of recording (hh.mm.ss)
            % #6  -- 8  ascii : number of bytes in header record
            % #7  -- 44 bytes -- header format (edf, as opposed to edf+c or edf+d)
            % #8  -- 8  bytes -- number of data records
            % #9  -- 8  bytes -- duration of a data record, in seconds.
            % #10 -- 4  bytes -- number of signals

            %Get Physiological Information from NK File.

            % #1 -- 8  ascii : version of this data format (0)
            header = repmat(' ', 1, 256*(1 + self.channels_count));
            header(1) = '0';

            % #2 -- 80 ascii : local patient identification
            [mrn, success] = self.getMRNfromPatientID();
            patient_id_str = '';
            if success
                patient_id_str = [strtrim(school_name), ' -- Patient ID : ', num2str(mrn)];
            else
                patient_id_str = self.PatientIdentification;
            end
            header(9:8+numel(patient_id_str)) = patient_id_str;

            % #3 -- 80 ascii : local recording identification
            header(89:88+numel(self.LocalRecordingIdentification)) = self.LocalRecordingIdentification;

            % #4 -- 8  ascii : startdate of recording (dd.mm.yy)
            start_date_str = self.StartDate;
            start_date_str([3,6]) = '..';
            header(169:168+numel(start_date_str)) = start_date_str;

            % #5 -- 8  ascii : starttime of recording (hh.mm.ss)
            start_time_str = self.StartTime;
            start_time_str([3, 6]) = '..';
            header(177:176+numel(start_time_str)) = start_time_str;

            % #6 -- 8  ascii : number of bytes in header record
            header_bytes_count_str = num2str(self.HeaderSizeInByte);
            header(185:184+numel(header_bytes_count_str)) = header_bytes_count_str;

            % #7 -- 44 bytes -- header format (edf, as opposed to edf+c or edf+d)
            header(193:192+numel('EDF')) = 'EDF';

            % #8  -- 8  bytes -- number of data records time_block
            data_record_count_str = num2str(self.NumberOfDataRecords);
            header(237:236+numel(data_record_count_str)) = data_record_count_str;

            % #9  -- 8  bytes -- number of data records time_block
            data_record_duration_str = num2str(self.DurationOfEachRecord);
            header(245:244+numel(data_record_duration_str)) = data_record_duration_str;

            % #10  -- 4  bytes -- duration of a data record, in seconds.
            channels_count_str = num2str(self.channels_count);
            header(253:252+numel(channels_count_str)) = channels_count_str;

            % ns * 16 ascii : channel names
            for i=1:self.channels_count
                a = 257+(i-1)*16;
                b = a-1+ numel(self.ChInfo.ChMap{i});
                header(a:b) = self.ChInfo.ChMap{i};
            end

            % ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
            for i=1:self.channels_count
                a = 257+self.channels_count * 16 + 80*(i-1);
                b = a-1+ numel(self.ChInfo.TransducerType{i});
                % td = self.ChInfo.TransducerType
                % cls = class(td)
                % td = self.ChInfo.TransducerType{i}
                % cls = class(td)
                header(a:b) = self.ChInfo.TransducerType{i};
            end

            % ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
            for i=1:self.channels_count
                a = 257+self.channels_count * 96 + 8*(i-1);
                b = a - 1+ numel(self.ChInfo.PhysicalDimension{i});
                header(a:b) = self.ChInfo.PhysicalDimension{i};
            end

            % ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
            for i=1:self.channels_count
                a = 257+self.channels_count * 104 + 8*(i-1);
                b = a-1+ numel(num2str(self.ChInfo.PhysicalMinimum{i}));
                header(a:b) = num2str(self.ChInfo.PhysicalMinimum{i});
            end

            % ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
            for i=1:self.channels_count
                a = 257+self.channels_count * 112 + 8*(i-1);
                b = a-1+ numel(num2str(self.ChInfo.PhysicalMaximum{i}));
                header(a:b) = num2str(self.ChInfo.PhysicalMaximum{i});
            end

            % ns * 8 ascii : ns * digital minimum (e.g. -2048)
            for i=1:self.channels_count
                a = 257+self.channels_count * 120 + 8*(i-1);
                b = a-1+ numel(num2str(self.ChInfo.DigitalMinimum{i}));
                header(a:b) = num2str(self.ChInfo.DigitalMinimum{i});
            end

            % ns * 8 ascii : ns * digital maximum (e.g. 2047)
            for i=1:self.channels_count
                a = 257+self.channels_count * 128 + 8*(i-1);
                b = a-1+ numel(num2str(self.ChInfo.DigitalMaximum{i}));
                header(a:b) = num2str(self.ChInfo.DigitalMaximum{i});
            end

            % ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
            for i=1:self.channels_count
                a = 257+self.channels_count * 136 + 80*(i-1);
                b = a-1+ numel(self.ChInfo.Prefiltering{i});
                header(a:b) = self.ChInfo.Prefiltering{i};
            end
            % ns * 8 ascii : ns * nr of samples in each data record
            for i=1:self.channels_count
                a = 257+self.channels_count * 216 + 8*(i-1);
                b = a-1+ numel(num2str(self.ChInfo.NumberOfSampleInEachRecord(i)));
                header(a:b) = num2str(self.ChInfo.NumberOfSampleInEachRecord(i));
            end

            % ns * 32 ascii : ns * reserved
            for i=1:self.channels_count
                a = 257+self.channels_count * 224 + (i-1) * 32;
                b = a - 1 + numel(self.ChInfo.Reserved{i});
                header(a:b) = self.ChInfo.Reserved{i};
            end
        end
    end
end

function text = cellString2Text(cellString)
   len = length(cellString);
   text = '';

   for i = 1:len
      text = [text ', ' cellString{i}];
   end

   if ~isempty(text)
      text = text(3:end);
   end
end


function Annotation = read_edf_plus_annotations(edf_info, FileName, AnnChID)

    if AnnChID == -1
        warning_string = sprintf('%s file %s does not contain annotation.',edf_type, FileName);
        edf_info.warnings = {edf_info.warnings{:}, warning_string};
        warning(warning_string);
        Annotation = [];
        return
    end

    % open file
    fid = fopen(FileName,'r');

    %refactor: this should be refactored.

    % prepare to seek to first annotation string.
    bytes_per_sample = 2;
    header_bytes_count = edf_info.HeaderSizeInByte;
    block_annotation_samples_count = edf_info.ChInfo.NumberOfSampleInEachRecord(AnnChID);
    block_bytes_before_annotation_count = bytes_per_sample * sum(edf_info.ChInfo.NumberOfSampleInEachRecord(1:AnnChID-1));

    % go to first annotation
    bytes_beg = 1 + header_bytes_count + block_bytes_before_annotation_count;
    fseek(fid, bytes_beg, 'bof');

    % prepare to read all annotations data
    blocks_count = edf_info.NumberOfDataRecords;
    block_samples_count = sum(edf_info.ChInfo.NumberOfSampleInEachRecord);
    skip_bytes = bytes_per_sample * (block_samples_count - block_annotation_samples_count);

    % empty_annotation = char(['20', zeros(1,2*block_annotation_samples_count - 2)]);
    blocks_count = edf_info.NumberOfDataRecords;
    block_bytes_shape = [blocks_count-1, bytes_per_sample * block_annotation_samples_count];
    precision = [ num2str(bytes_per_sample * edf_info.ChInfo.NumberOfSampleInEachRecord(AnnChID)), '*char=>char'];
    skip_bytes = (block_samples_count - block_annotation_samples_count) * bytes_per_sample;

    % read annotation blocks
    [block_bytes, bytes_read_count] = fread(fid, [ 1, prod(block_bytes_shape)] , precision, skip_bytes);

    %reshape block annotations
    block_bytes = reshape(block_bytes, 2*block_annotation_samples_count, []).';

    % block times ( which the edf+ file must have),
    % as quickly as possible. not if we have to re-read a block if there
    % is more than just the block's time-start information.
    tal_start_chars = '-+';
    blocks.time_starts = cell(blocks_count-1,1);
    blocks.has_tal = repmat(false,blocks_count-1,1);
    for i = 1:blocks_count-1
        %parse block time.
        %Modified by Wanchat 2015/06/29(using strfind instead of while loop)
        j = strfind(block_bytes(i,:),char([20 20]));
        if isempty(j)
            j = 2*block_annotation_samples_count;
        end

        blocks.time_starts{i} = block_bytes(i,1:j-1);
        blocks.time_starts_numerical(i) = str2num(blocks.time_starts{i}); %Add by Wanchat for EDF+D 2015/06/29
        blocks.has_tal(i) = any(block_bytes(i,j+2) == tal_start_chars);
        if mod(i,1000) ==0, fprintf('blocks.time_start{%i}: %s\n', i-1, blocks.time_starts{i}), end;
    end

    blocks.tals = {};
    blocks.tals_count = 0;
    blocks.tals_indeces = {};
    for i = 1:blocks_count-1
        if blocks.has_tal(i)
            %add another tal
            blocks.tals_count = blocks.tals_count + 1;

            %store index
            blocks.tals_indeces{blocks.tals_count} = i;
            ann_str = block_bytes(i,numel(blocks.time_starts{i})+3:end);
            blocks.tals{blocks.tals_count} = parse_edf_plus_block_tal(ann_str,false);
        end
    end


    annotation.Time=[];
    annotation.Duration=[];
    annotation.Text=[];
    ann_index = 1;
    onset_time_mod = 24*3600;
    for i=1:blocks.tals_count
        block_index = blocks.tals_indeces{i};

        %    todo: make sure time incorporates file and date-time rollover
        %    xparse onset time
        start_date = edf_info.StartTime;
        [~, ~, ~, H, MN, S] = datevec(edf_info.StartTime);

        file_onset_time = H*3600 + MN*60 + S;
        block_plus_minus_str = blocks.time_starts{i};
        block_plus_minus_char = block_plus_minus_str(1);
        block_plus_minus_str = block_plus_minus_str(2:end);
        block_onset_time = sum([1,-1] .* (block_plus_minus_char == '+-') * str2double(block_plus_minus_str));

        for j = 1:numel(blocks.tals{i})
            annotation_onset_char = blocks.tals{i}{j}.onset(1);

            annotation_onset_str = '';
            if strcmpi(annotation_onset_char,'+')
                annotation_onset_str = blocks.tals{i}{j}.onset(2:end);
            elseif strcmpi(annotation_onset_char,'-')
                annotation_onset_str = blocks.tals{i}{j}.onset;
            else
                warning_string = sprintf('Time annotation markers not `+` or `-` in block tal: %i',j);
                edf_info.warnings = {edf_info.warnings{:}, warning_string};
                warning(warning_string);
            end

            annotation_onset_time=str2double(annotation_onset_str);
            file_onset_time = annotation_onset_time + block_onset_time;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %TODO: REVIEW: Does this need time file start added also?
            %file_onset_time = file_onset_time + file_onset_time;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            file_onset_time = mod(file_onset_time, onset_time_mod);
            annotation.Time{ann_index} = file_onset_time;
            annotation.Duration{ann_index} = str2double(blocks.tals{i}{j}.duration);
            %blocks.tals{i}{j}.annotations
            annotation.Text{ann_index} = cellString2Text(blocks.tals{i}{j}.annotations);
            ann_index = ann_index+1;
        end
    end

    % close file
    fclose(fid);
    edf_info.Annotation = annotation;
end


function [tals] = parse_edf_plus_block_tal(ann_str,disp)
    %
    %   [tals,start_wrt_file] = parse_edf_plus_annotation_block(ann_str,disp)
    %
    %   ann_str: string of chars from EDF+D or EDF+C block or segment of data
    %
    %   disp: boolean to display operations and test (open this file to see tests)
    %
    %   returns [tals,start_wrt_file] -------
    %
    %   start_wrt_file is a string of the recorded time advanced or delayed (+/-)
    %   from the start/recording time of the entire EDF+ file
    %
    %   tals: a cell array, each element containing
    %       tals{i}.onset: (string)  onset time of the file (beginning with +/-)
    %       tals{i}.duration: (string) duration of file (must be positive, no + or -)
    %       tals{}.dannotations: cell array of strings, each being an annotation
    %
    %
    %   REFACTOR:

    if nargin < 2
        disp = false;
    end

    % if nargin == 0
    %     t = char(20);
    %     t1 = char(21);
    %     z = char(0);
    %     ann_str = ['-7.1231345',t1, '12234',t,'Hello=-=-=-=-+++_=-= there',t,'Muahahahahsdaklsdjlakjsd',t,'asdalkjsdlkajsldkjasd',t,z];
    % end

    % See: http://www.edfplus.info/specs/edfplus.html
    % implementation is a finite state machine to recognize these patterns
    ann_str_len = numel(ann_str);
    ann.type = {};
    ann.text = {};

    matches = []; %#ok<NASGU>
    last_m0 = true;
    last_m20 = false;
    last_m21 = false;
    last_m_plus_min = false;

    tals = {};
    ann_index = 0;
    char_index = 1;
    ann_str_len = numel(ann_str);
    while true
        if ~last_m20 && ~last_m21
            matches = [0 20 21 uint8('+'), uint8('-')];
        else
            matches = [0 20 21];
        end
        if char_index > 1
            while char_index < ann_str_len && ~any(ann_str(char_index) == matches)
                char_index = char_index + 1;
            end
        end

        if char_index > ann_str_len
            break
        end

        % state variables
        m0 = ann_str(char_index) == 0;
        m20 = ann_str(char_index) == 20;
        m21 = ann_str(char_index) == 21;
        m_plus_min = (ann_str(char_index) == uint8('+')) || (ann_str(char_index) == uint8('-'));
        if char_index == ann_str_len
            break
        end
        next_m_plus_min = (ann_str(char_index+1) == uint8('+')) || (ann_str(char_index+1) == uint8('-'));

        found_annotation = m20 && last_m20;

        found_duration = m20 && last_m21;

        found_onset = (m20 || m21) && last_m_plus_min && ~last_m20 && ~last_m21;

        found_tals_beg = m_plus_min && last_m0;
        found_talss_end = m0 && ~next_m_plus_min;

        starting_first_annotation = ann_str(char_index) == 20 && last_m20 && m_plus_min;
        if found_tals_beg
            if disp, char_index, end;
            if ann_index > 1
                fprintf('    ...onset = %s', tals{ann_index}.onset);
                fprintf('    ...duration = %s', tals{ann_index}.duration);
                fprintf('    ...annotations{:} = %s', tals{ann_index}.annotations{:});
            end
            if disp, fprintf('Next TAL Discovered! Next Character: %s\n\n',ann_str(char_index)); end
            ann_index = ann_index+1;
            tals{ann_index}.onset = '';
            tals{ann_index}.duration = '';
            tals{ann_index}.annotations = {};
        else
            str = strtrim(ann_str(last_matched_index:char_index-1));
            if numel(strtrim(str)) > 0
                if disp, str_totals = ann_str(1:char_index-1), end;
                if found_talss_end
                    if disp, fprintf('No More TAL"s; Next Character: %s\n\n',ann_str(char_index)), end;
                    break;
                elseif found_duration
                    str = str(2:end);
                    tals{ann_index}.duration  = str;
                    if disp, fprintf('Duration: %s\n',str); end
                    ann.type = {ann.type{:},'Duration'};
                elseif found_onset
                    tals{ann_index}.onset = str;
                    if disp, fprintf('Onset: %s\n',str); end
                    ann.type = {ann.type{:},'Onset'};
                elseif found_annotation
                    str = str(2:end);
                    if isfield(tals{ann_index},'annotations')
                        tals{ann_index}.annotations = {tals{ann_index}.annotations{:},str};
                    else
                        tals{ann_index}.annotations = {str};
                    end
                    if disp, fprintf('Annotation: %s\n',str); end
                    ann.type = {ann.type{:},'Annotation'};
                end
                ann.text = {ann.text{:},str};
                if disp, pause; end
            end
        end

        last_m0 = m0;
        last_m20 = m20;
        last_m21 = m21;
        last_m_plus_min = m_plus_min;
        last_matched_index = char_index;

        char_index = char_index + 1;
    end
    if disp
        fprintf('start_wrt_file:\n')
        fprintf(tals2string(tals))
    end
end

function str = tals2sring(tals)
    str = '';
    for i = 1:numel(tals)
        str = [str, sprintf('tals{%i}...\n',i)];
        str = [str, sprintf('      ...onset = %s\n', tals{i}.onset)];
        str = [str, sprintf('      ...duration = %s\n', tals{i}.duration)];
        for j = 1:numel(tals{i}.annotations)
            str = [str, sprintf('      ...annotations{%i} = %s\n', i, tals{i}.annotations{j}) ];
        end
    end
end


function cells = equal_len_cells(cells)
    cells = strtrim(cells);
    lens = cellfun(@(c) length(c), cells);
    lens_max = max(lens);
    cells = arrayfun(@(i) {[cells{i}, repmat(' ',[1, lens_max-lens(i)])]}, 1:numel(cells));
end

function cells = create_column_of_cells(cells, column_name)
    cells = {column_name, cells{:}};
    cells = equal_len_cells(cells);
    len = numel(column_name);
    cells = [cells(1), {repmat('-', [1, numel(cells{1})])}, cells(2:end)];
end
