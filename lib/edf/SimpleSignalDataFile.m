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
classdef SimpleSignalDataFile < SimpleDataFile
    properties
        is_nk;
        is_edf;
        is_eeg;
        samples_type;
        filepath_data;
    end

    methods(Static)
        function ssdf = empty()
            ssdf = SimpleDataFile.empty().toStruct();

            ssdf.is_nk = false;
            ssdf.is_edf = false;
            ssdf.is_eeg = false;
            ssdf.samples_type = '';
            ssdf.filepath_data = [];

            ssdf = SimpleSignalDataFile(ssdf);
        end
        function ssdf = fromfile(fp)
            ssdf = SimpleDataFile.fromfile(fp);
            ssdf = ssdf.toStruct();

            ssdf.filepath_data = fp;
            ssdf.is_edf = endswithi(fp, '.edf');
            ssdf.is_eeg = endswithi(fp, '.eeg');
            ssdf.is_nk  = endswithi(fp, '.eeg');

            if ~ssdf.is_edf && ~ssdf.is_nk
                error(sprintf('fp %s must be an eeg or edf file', fp));
            end

            if ssdf.is_edf
                ssdf.samples_type = 'int16';
            else
                ssdf.samples_type = 'uint16';
            end

            ssdf = SimpleSignalDataFile(ssdf);
        end
    end
    methods
        function self = SimpleSignalDataFile(ssdf)
            self = self@SimpleDataFile();

            if nargin == 0, return, end;

            sdf_class = SimpleDataFile(ssdf);
            sdf_files = properties(sdf_class);

            for i=1:numel(sdf_files)
                f = sdf_files{i};
                self.(f) = sdf_class.(f);
            end

            ssdf_fields = properties(SimpleSignalDataFile());
            rid = cellfun(@(f) any(strcmp(f, sdf_files)), ssdf_fields);
            ssdf_fields(rid)=[];

            for i=1:numel(ssdf_fields)
                f = ssdf_fields{i};
                self.(f) = ssdf.(f);
            end
        end
        function [file, success, me] = asFile(self)
            success=true;
            me = MException('SimpleSignalDataFile:noError','');
            file = FaultySignalDataFile.fromSimpleDataFile(self, me);
            try
                if self.is_edf
                    file = EDF_File.fromFile(self.filepath);

                    if 0 == file.channels_count
                        throw(MException('EDF_FIle.fromFile:Loading','Channels count == 0'))
                    end
                else
                    file = NK_File.fromFile(self.filepath);
                end
            catch me
                success=false;
                self.is_faulty=true;
                file = FaultySignalDataFile.fromSimpleDataFile(self, me);
            end
        end
        function s = toStruct(self)
            warning off matlab:structOnObject;
            s = struct(self);
            warning on matlab:structOnObject;
        end
    end
end

% methods
%
%       end
%         function [file, success, me] = asFile(self)
%             success=true;
%             me = MException('SimpleDataFile:noError','');
%             file = FaultySignalDataFile.fromSimpleSignalDataFile(self, me);
%             try
%                 if self.is_edf
%                     file = EDF_File.fromFile(self.filepath);
%
%                     if 0 == file.channels_count
%                         throw(MException('EDF_FIle.fromFile:Loading','Channels count == 0'))
%                     end
%                 else
%                     file = NK_File.fromFile(self.filepath);
%                 end
%             catch me
%                 success=false;
%                 self.is_faulty=true;
%                 file = FaultySignalDataFile.fromSimpleDataFile(self, me);
%             end
%         end
%         function s=toStruct(self)
%             warning off matlab:structOnObject;
%             s = struct(self);
%             warning on matlab:structOnObject;
%         end
%     end
% end
