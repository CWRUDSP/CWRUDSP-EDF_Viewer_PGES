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
classdef DataFile < handle

    properties(GetAccess='public', SetAccess='protected')
        ext;

        ChMap;
        ChInfo;

        StartTime;
        StartDate;
        annotations;

        NumberOfDataRecords;
        DurationOfEachRecord;

        NumberOfSignals;

        AllSamplesInEachDataRecord;

        samples_type;           %'int16' or 'uint16'
        samples_count;

        warnings;

        folder;
        name;
        name_base;
        filename;
        filepath_data;
        filepath_base;

        key_filepath;
    end
    % name
    % folder
    % ext
    % name_base
    % file_path_basename


    methods
        function self = DataFile(df_metadata)
            if nargin == 0, return, end;

            fields = properties(DataFile());
            for i=1:numel(fields)
                f = fields{i};
                self.(f) = df_metadata.(f);
            end

        end

        function str = to_string(self)
            str = DataFile.to_string_static(self);
        end
        function b = is_nk(~)
            b = false;
        end
        function b = is_edf(~)
            b = true;
        end
        function str = filepath(self)
            str = joinpath(self.folder, self.name);
        end
        function str = displayChannelNames(self)
            str = self.ChMap;
        end
    end
end
