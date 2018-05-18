function [cells,new_count] = flattencells(cells)
    % [cells,new_count] = flattencells(cells)
    %
    % Flattens cell tree
    %
    %
    warning('deprecated')
    [cells,new_count] = cellflatten(cells);
end
