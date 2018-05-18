function setalt(obj, varargin)

    for i=1:2:numel(varargin)
        arg = varargin{i+1};
        setting = varargin{i};

        if strcmpi(setting, 'value')
            if isnumeric(arg)
                strs = get(obj, 'String');
                assert(1 <= arg)
                assert(arg <= numel(strs), sprintf('numel(strs) == %i, but index == %i',numel(strs), arg));
            end
        elseif strcmpi(setting, 'String')
            if iscell(arg)
                index = get(obj, 'Value');
                if index > 0
                    assert(1 <= index, sprintf('index == %i', index))
                    assert(index <= numel(arg), sprintf('numel(strings) == %i, but index == %i',numel(arg), index));
                end
            end
        end
    end

    set(obj, varargin{:})
end
