function obj = structify(obj)
    %   obj = structify(obj);
    %
    %   creates a struct from obj such that
    %   all members are also structs..
    %   all the way down to base types.

    if isaclass(obj)
        if isa(obj,'MException')
            warning off MATLAB:structOnObject
            obj = struct(obj);
            warning on MATLAB:structOnObject
            try
                obj.message = sprintf(obj.message, obj.arguments{:});
            catch me
            end
            obj = rmfield(obj, {'type','hasBeenCaught','defaultstack','arguments','cause'});
        end

        if ~isstruct(obj)
            warning off MATLAB:structOnObject
            obj = struct(obj);
            warning on MATLAB:structOnObject
        end
    end

    if isscalar(obj) && ~iscell(obj)
        if isstruct(obj) %refactor: use structfun?
            fields = fieldnames(obj);
            for i = 1:numel(fields)
                f = fields{i};
                obj.(f) = structify(obj.(f));
            end
        end
    else
        if iscell(obj)
            obj = cellfun(@(o) {structify(o)}, obj);
        elseif ~ischar(obj)
            obj = arrayfun(@(o) structify(o), obj);
        end
    end
end
