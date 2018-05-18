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
classdef AnnotationsFile < Annotations
    % properties
    %     unknown_warnings;
    %     unknown_random_id_str;
    % end
    
    properties
        filepath_txt;
        filepath_json;
        id_is_random;
        src_filepath; %This annotations file is for converted edf files. so this is the source eeg file for whatever format (e.g. NK)
        src_segment;
    end
    
    methods(Static)
        function [annotations_file, success, me] = fromTXTFile(filepath_txt)
            %'[annotations_file, warnings] = fromTXTFile(filepath_txt)'

            success=true;
            me = MException('fromTXTFile:NoError','');

            af_struct = AnnotationsFile.empty();

            af_struct.filepath_txt  = filepath_txt;
            af_struct.filepath_json = replext(filepath_txt, '.json');

            annotations_file = AnnotationsFile(af_struct);
            filetext_keyfile = '';

            try
                filetext_keyfile = fileread(filepath_txt);
            catch me
                success = false;
                warning_string = 'Annotation file is not available.';
                me = addCause(MException('fromTXTFile:Loading', warning_string), me);
                warning(warning_string);
            end

            lines = cellcast(strsplit(filetext_keyfile,'\n'));
            empty = cellfun(@isempty, lines);
            lines(empty) = [];

            Time = cell(numel(lines),1);
            Text = cell(numel(lines),1);

            if success
                try
                    empty = cellfun(@(l) numel(strtrim(l))==0, lines);
                    lines = lines(~empty);

                    for i=1:numel(lines)

                        pos = min(numel(Annotations.TIMESTAMP_FORMAT), numel(lines{i}));
                        Time{i} = char(deblank(lines{i}(1:pos)));

                        pos = pos + 1;
                        Text{i} = char(deblank(lines{i}(pos:end)));
                    end
                catch me
                    success = false;
                    warning_string = 'Annotation file is not available: Time and Text error';
                    me = addCause(me, MException('fromTXTFile:Loading', warning_string));
                    warning(warning_string);
                end
            end
            Text = strtrim(Text);

            warning_str = [];
            if ~success
                mes = structify(me);
                warning_str = mes.m;
            end


            af_struct.id_is_random  = false;
            af_struct.src_filepath = '';
            af_struct.warnings      = cellcast(warning_str);
            af_struct.filepath_txt  = filepath_txt;
            af_struct.filepath_json = replext(filepath_txt, '.json');
            af_struct.src_segment = [];

            annotations_file = AnnotationsFile(af_struct);
            annotations_file.add(Time, Text); % uses a sort and unique system.
        end        
        function [ann, success, me] = fromJSONFile(filepath_json)
            ann = struct;
            success = true;
            me = MException('fromJSONFile:NoError','No Error');

            txt='{}';
            try
                txt = fileread(filepath_json);
            catch me
                success = false;
            end

            try
                ann = loadjson(txt);
            catch me2
                ann=struct;
                me = addCause(me, me2);
            end

            if ~isfield(ann, 'Text')
                ann.Text = {};
            end

            if ~isfield(ann, 'Time')
                ann.Time = [];
            end

            if ~isfield(ann, 'src_filepath')
                ann.src_filepath = [];
            end

            if ~isfield(ann,'src_segment')
                ann.src_segment = [];
            end
            
            if ischar(ann.Time) %will line annotations as char not {char}
                ann.Time={ann.Time};
            end
    
            if ischar(ann.Text) %will line annotations as char not {char}
                ann.Text={ann.Text};
            end

            if numel(ann.Time) > 0 && iscellstr(ann.Time)
                ann.Time = cellfun(@(ts) AnnotationsFile.STAMP_TO_SECONDS(ts), ann.Time); %cell to array
            end

            ann.src_filepath = removeext(filepath_json);
            ann.filepath_json = filepath_json;
            ann.filepath_txt = replext(filepath_json,'.txt');
            ann = AnnotationsFile(ann);
        end
        function ann = empty()
            % fields = properties(Annotations);
            ann = Annotations.empty().toStruct();
            ann.filepath_txt = '';
            ann.filepath_json = '';
            ann.src_filepath = '';
            ann.src_segment = [];
            ann.warnings = cellcast(ann.warnings);
            [~, ic] = unique(ann.warnings);

            ann.warnings = ann.warnings(ic);
            ann.filepath_base = cd;

            ann = AnnotationsFile(ann);
        end
    end

    methods
        function self = AnnotationsFile(af)%, filepath_base)
            self = self@Annotations();

            if nargin==0, return, end;

            if ~isfield(af, 'warnings')
                af.warnings={};
            end

            ann = Annotations(af).toStruct();
            fields_ann = fieldnames(ann);

            for i = 1:numel(fields_ann)
                f = fields_ann{i};
                self.(f) = ann.(f);
                if strcmpi(f,'Text')
                    self.(f)=cellcast(self.(f));
                end
            end

            %             fields_af = fieldnames(AnnotationsFile());
            %             rid = cellfun(@(field_ann) any(strcmp(field_af, field_ann)), fields_af);
            %             fields_af(rid)=[];

            if isfield(af, 'filepath_base')
                self.filepath_txt  = [af.filepath_base, '.txt'];
                self.filepath_json  = [af.filepath_base, '.json'];
            else
                self.filepath_txt = af.filepath_txt;
                self.filepath_json = af.filepath_json;
            end

            if isfield(af,'src_filepath')
                self.src_filepath = af.src_filepath;
            else
                self.src_filepath = '';
            end


            if isfield(af,'src_segment')
                self.src_segment = af.src_segment;
            else
                self.src_segment = '';
            end            
        end
        function exst = hasTXTAnnotationsFile(self)
            exst = exist(self.filepath_txt,'file')==2;
        end
        function exst = hasJSONAnnotationsFile(self)
            exst = exist(self.filepath_json,'file')==2;
        end
        function txt=toTXT(self)
            txt=strjoin(self.toLines(),'');
        end
        function setFolder(self, folder)
            self.filepath_txt = joinpath(folder, path2name(self.filepath_txt));
            self.filepath_json = joinpath(folder, path2name(self.filepath_json));
        end
        function setFilenameBase(self, filename_base)
            self.filepath_txt  = joinpath(fileparts(self.filepath_txt), [ filename_base, '.txt']);
            self.filepath_json = joinpath(fileparts(self.filepath_json), [ filename_base, '.json']);
        end
        function json_str=toJSON(self)
            strct = self.toStruct();
            strct.Time = self.toStamps(); % array 2 cell.
            json_str = savejson('', strct);            
        end
        function saveTXTFile(self)
            fid = fopen(self.filepath_txt,'w');
            fwrite(fid, self.toTXT());
            fclose(fid);
        end
        function saveJSONFile(self)
            fid = fopen(self.filepath_json,'w');
            fwrite(fid, self.toJSON());
            fclose(fid);
        end
        function [SUCCESS,MESSAGE,MESSAGEID] = movefile(self, new_folder)
            % self = movefile(self, new_folder) - move key_file from
            %    self.key_filepath to joinpath(new_folder,name);

            assert(exist(new_folder,'dir')==7)

            SUCCESS = [false false];
            MESSAGE = {'',''};
            MESSAGEID=[-1, -1];            
            fields = {'filepath_json', 'filepath_txt'};            
            for i=1:2
                old_filepath = self.(fields{i});
                old_folder = remname(old_filepath);
                name = path2name(old_filepath);

                new_filepath = joinpath(new_folder, name);

                if exist(old_filepath,'file')==2
                    [SUCCESS(i), MESSAGE{i}, MESSAGEID(i)] = movefile(old_filepath, new_filepath);
                end


                self.(fields{i}) = new_filepath;
            end
        end
        
        function s = toStruct(self)
            s = toStruct@Annotations(self);
            s = rmfield(s, {'filepath_json', 'filepath_txt','id_is_random'});
            % s.id_is_random = ''; %Legacy - used to generate random number if no opic id/patient name field.
        end
    end
end
