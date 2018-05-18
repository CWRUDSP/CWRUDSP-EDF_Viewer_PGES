function array = cellcast(varargin)
    array = [];
    if numel(varargin) == 1
        array = varargin{:};
    end

    if isempty(array)
        array = {};
    elseif iscell(array) && length(array)==1
        if isempty(array{1})
            array = {};
        end
    end

    if ischar(array)
        array = {array};
    elseif ~iscell(array)
        array = arrayfun(@(x) {x}, array);
    end
end
