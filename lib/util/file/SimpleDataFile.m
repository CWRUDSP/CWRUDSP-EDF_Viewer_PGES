classdef SimpleDataFile < handle
    properties
        filename;
        filename_base;

        filepath;
        filepath_base;

        folder;

        is_faulty;
    end

    methods(Static)
        function sdf = empty()

            sdf.folder=[];

            sdf.filename = [];
            sdf.filename_base = [];

            sdf.filepath = [];
            sdf.filepath_base = [];

            sdf.is_faulty = false;

            sdf = SimpleDataFile(sdf);
        end
        function sdf = fromfile(fp)
            sdf.folder = fileparts(fp);
            sdf.filename = path2name(fp);

            [~, sdf.name_base] = fileparts(fp);

            sdf.filepath = fp;
            sdf.filepath_base = joinpath(sdf.folder, sdf.name_base);
            sdf.is_faulty = false;

            sdf = SimpleDataFile(sdf);
        end
    end
    methods
        function self = SimpleDataFile(sdf)
            if nargin == 0,
                self.is_faulty = true;
                return
            end

            fields = fieldnames(SimpleDataFile());

            for i=1:numel(fields)
                f=fields{i};
                if strcmp(f, 'filename') && ~isfield(sdf, 'filename')
                    self.filename = self.name;
                elseif strcmp(f, 'filename_base') && ~isfield(sdf, 'filename_base')
                    self.filename_base = sdf.name_base;
                elseif strcmp(f, 'is_faulty') && ~isfield(sdf, 'is_faulty')
                    self.is_faulty = false;
                else
                    self.(f) = sdf.(f);
                end
            end
        end
        function n = name(self)
            n = self.filename;
        end
        function nb = name_base(self)
            nb = self.filename_base;
        end
        function [fileobj, success, me] = tofileobject(self, struct2object)
            success = true;
            me = MException('SimpleDataFile:NoError','');
            fileobj = InvalidDataFile.fromSimpleDataFile(self, me);
            try
                fileobj = struct2object(self.filepath);
            catch me
                success = false;
            end
        end
        function s=toStruct(self)
            warning off matlab:structOnObject;
            s = struct(self);
            warning on matlab:structOnObject;
        end
    end
end
