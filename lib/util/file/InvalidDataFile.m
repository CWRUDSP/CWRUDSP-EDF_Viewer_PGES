classdef InvalidDataFile < SimpleDataFile
    properties(GetAccess='public', SetAccess='protected')
        exception;
    end

    methods(Static)
        function idf = empty()
            idf = SimpleDataFile.empty().toStruct();
            idf.exception = MException('InvalidDataFile:empty', 'Uninitialized. No file to reference');
            idf = InvalidDataFile(idf);
        end
        function idf = fromSimpleDataFile(sdf, exception)
            s=sdf.toStruct();
            s.exception=exception;
            idf = InvalidDataFile(s);
        end
        function idf = fromfile(fp, exception)
            s = SimpleDataFile.fromfile(fp).tostruct();
            s.exception=exception;
            idf = InvalidDataFile(s);
        end
    end

    methods
        function b = exists(self)
            b = exist(self.filepath,'file')==2;
        end
        function b = invalid(self)
            b = ~noerror(self.exception);
        end
        function self = InvalidDataFile(idf)

            fdf_super = rmfield(idf,'exception');
            self@SimpleDataFile(fdf_super);

            msg= sprintf('idf is of class `%s`, not struct', class(idf));
            assert(isstruct(idf), msg)

            fields=fieldnames(idf);

            for i = 1:numel(fields)
                f = fields{i};
                self.(f) = idf.(f);
            end
        end
        function [fileobj, success, me] = asFile(self, struct2obj)
            fileobj = self;
            success = true;
            me = MException('SimpleDataFile:NoError','')
            try
                fileobj = struct2obj(self.filepath);
            catch me
                success = false;
                fileobj = self;
            end
        end
    end
end
