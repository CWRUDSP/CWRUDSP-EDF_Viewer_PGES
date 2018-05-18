function zipped_cells = cellzip(varargin)

    arg_count = numel(varargin);
    arg_len = min(gfun(@(arg) numel(arg), varargin));

    zipped_cells = cell(1, arg_len);
    % refactor: optimize this loop
    % initialize
    zipped_cells = repcell(cell(1, arg_count), [1, arg_len]);

    for i = 1:arg_count
        if iscell(varargin{i})
            for j = 1:arg_len
                zipped_cells{j}{i} = varargin{i}{j};
            end
        else
            for j = 1:arg_len
                zipped_cells{j}{i} = varargin{i}(j);
            end
        end
    end
end

function [res, is_cell] = gfun(f, group, varargin)
    if nargin <3
        varargin = {};
    end

    is_cell = iscell(group);
    if is_cell
        res = cellfun(@(elem) f(elem, varargin{:}), group);
    else
        res = arrayfun(@(elem) f(elem, varargin{:}), group);
    end
end
