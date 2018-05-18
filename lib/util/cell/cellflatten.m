function [cell_res, new_count] = cellflatten(varargin)
    % [cells,new_count] = flattencells(cells)
    %
    % Flattens cell tree
    %
    %
    %   %
    %
    %   %refactor: horrible bug -- cellflatten('') gives {} should be {''}. Wow.
    %
    cell_res = per_element(varargin);

    new_count = numel(cell_res);
end

function cells_res = per_element(cells)
    if iscell(cells)
        cells_res = {};
        for i = 1:numel(cells)
            cell_res = cellcast(per_element(cells{i}));
            cells_res = {cells_res{:}, cell_res{:}};      % ok<CCAT>
        end
    else
        cells_res=cells;
    end
end
