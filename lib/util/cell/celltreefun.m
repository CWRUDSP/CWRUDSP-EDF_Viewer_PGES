function res = celltreefun(cells, f, varargin)
    is_cell = iscell(cells);

    if is_cell
        res = cell(size(cells));
    else
        res = [];
    end

    if is_cell
        for i = 1:numel(cells)
            res{i} = celltreefunc(cells{i}, f, varargin{:});
        end
    else
        res = f(cells, varargin{:});
    end
end
