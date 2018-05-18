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
classdef AbstractDataGetter < DFStruct

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %   PROTECTED - ABSTRACT
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access = 'protected', Abstract)
        buff    = cast_buffer_to_units(self, channel_id, buff)
        boolean = channel_buffer_is_loaded(self, ch_id, beg_index, end_index)
        load_channel_buffer(self, channel_id, begin_index);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %   PUBLIC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties(GetAccess='public', SetAccess='protected')
        fid;
        channel_buffers;
        channel_buffers_end_time;
        channel_buffers_beg_time;
        channel_buffers_end_index;
        channel_buffers_beg_index;
    end
    % file_path_basename;
    % patient_id; %edf thing
    % mrn;
    % ext;
    % mrn_success;
    % data_file_path;
    % StartDate;
    % ChMap;
    % NumberOfDataRecords;
    % DurationOfEachRecord;
    % NumberOfSignals;
    % ChInfo;
    % AllSamplesInEachDataRecord;
    % samples_type;%'int16' or 'uint16'
    % samples_count;
    % warnings;
    % name;
    % folder;
    % name_base;
    % filename;
    % file_path_basename;
    % StartTime;

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %   PUBLIC - ABSTRACT
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Access = 'public', Static, Abstract)
        str         = to_string_static(file_info)
        metadata    = load_metadata(file_path_name);
    end


    methods(Abstract)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   GETTERS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        self = delete(self)
        channel_md                              = get_channel_metadata(self, channel_id);
        channel_time                            = get_channel_time(self, channel_id, beg_index, end_index);
        channel_buffer                          = get_channel_buffer(self, channel_i, beg_index, end_index);
        [beg_index, end_index]                  = get_indeces_by_time( self, beg_time, end_time, channel_id);
        [ch_signal, ch_time, ch_name, ch_units] = get_channel_signal(self, channel_id, beg_index, end_index);
        [ch_signal, ch_time, ch_name, ch_units] = get_channel_signal_by_time(self, channel_id, beg_time, end_time);
    end
end

