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
classdef PatientKeyInfo < handle
    properties(GetAccess='public',SetAccess='private')
        mrn;
        filename;
        patient_name;
        key_filepath;
        mrn_warning;
        pn_warning;
    end
    methods(Static)
        function [patient_info, success, msg] = fromFile(key_filepath, data_filename)

            % Farhad's EDF Annotation format
            % CANNOT use with other annotation formats
            msg        = '';
            success    = true;
            patient_info_struct.filename     = data_filename;
            patient_info_struct.key_filepath = key_filepath;
            patient_info_struct.mrn          = '';
            patient_info_struct.patient_name = '';
            patient_info_struct.mrn_warning  = '';
            patient_info_struct.pn_warning   = '';

            patient_info = PatientKeyInfo(patient_info_struct);

            filetext_keyfile = '';
            try
                filetext_keyfile = fileread(key_filepath);
            catch
                msg = sprintf('Key file %s not found.', key_filepath);
                success=false;
                return
            end
            try
                lines = strsplit(filetext_keyfile,'\n');

                cells = strsplit(lines{1}, ':');
                patient_info.filename = cells{2};

                cells = strsplit(lines{2}, ':');
                patient_info.patient_name = cells{2};

                cells = strsplit(lines{3}, ':');
                patient_info.mrn = cells{2};

            catch
            end

            patient_info= PatientKeyInfo(patient_info);
        end
    end

    methods
        function self = PatientKeyInfo(patient_key_info)
            if nargin == 0, return, end;

            fields = fieldnames(self);


            fdiff = stringsetdiff(fields, fieldnames(patient_key_info));
            assert(numel(fdiff)==0, 'fieldDifference: %s', strjoin(fdiff,', '))

            for i=1:numel(fields)
                f = fields{i};
                self.(f) = patient_key_info.(f);
            end
        end

        function key_lines = toLines(self) %refactor ? move to NK_File?
            key_lines = {'File name      : ', self.filename,     '\r\n',...
                         'Patient Name   : ', self.patient_name, '\r\n',...
                         'MRN            : ', self.mrn,          '\r\n'};
        end
        function b = keyFileExists(self)
            b = exist(self.key_filepath, 'file')==2;
        end

        function edf_patient_id_str = getEDFPatientIdentificationString(self, hospital_name)
%             edf_patient_id_str = [hospital_name, ' -- Patient ID : 0'];
            if isnumeric(self.mrn)
                edf_patient_id_str = [hospital_name, ' -- Patient ID : ', num2str(self.mrn)];                            
            else
                edf_patient_id_str = [hospital_name, ' -- Patient ID : ', self.mrn];                
            end
        end

        function movefile(self, new_folder)
            assert(exist(new_folder,'dir')==7)

            old_filepath = self.key_filepath;
            old_folder = remname(old_filepath);
            name = path2name(old_filepath);

            new_filepath = joinpath(new_folder, name);

            if exist(old_filepath,'file')==2
                [SUCCESS, MESSAGE, MESSAGEID] = movefile(old_filepath, new_filepath);
            end

            self.key_filepath = new_filepath;

        end
    end
end
%
% function fromString(annotation_file_path)
%     % Farhad's EDF annotation format
%     % ***CANNOT use with other annotation formats***
%     msg='';
%     success=true;
%     mrn = '';
%     filename = '';
%     patient_id = '';
%
%     filename_key =[removeext(filename_edf), '_key.txt'];
%     filetext_keyfile = '';
%     try
%         filetext_keyfile = fileread(filename_key);
%     catch me
%         msg = sprintf('Key file %s not found.', filename_key);
%         success=false;
%         return
%     end
%
%     lines = strsplit(filetext_keyfile,'\n');
%     cells = strsplit(lines{1},':');
%     filename = cells{2};
%
%     cells = strsplit(lines{2},':');
%     patient_id = cells{2};
%
%     cells = strsplit(lines{3},':');
%     mrn = cells{2};
%
%
%     % file_path_edf_key = [new_base_name, '_key.txt'];
%     slash_pos = strfind(file_path_edf_key, separator());
%     file_name_eeg = file_path_edf_key(slash_pos(end)+1:end);
%
%     fid.eeg = fopen(file_path_edf_key,'r');
%     fid.key = fopen(key_filename,'w');
%
%     file_name_str = ['File name      : ', file_name, carriage_return];
%     fwrite(fid.key_file, file_name_str, 'char');
%
%     fseek(file_path_eeg, 79, 'bof');
%     patint_name = char(fread(fid.eeg_file,[1 32],'uint8'));
%     patient_name_str = ['Patient Name   : ', patient_name, carriage_return];
%     fwrite(fid.key_file, patient_name_str, 'char');
%
%     fseek(file_path_eeg, 48, 'bof');
%     patient_mrn_str = char(fread(fid.eeg_file,[1 16],'uint8'));
%     patient_mrn_str = ['MRN            : ', patient_mrn_str];
%     fwrite(fid.key_file, patient_name_str, 'char');
%
%     fclose(fid.eeg);
%     fclose(fid.edf);
% end

