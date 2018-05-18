function cell_findings = cellfindstr(cells, substr)
    cell_pos = cell(size(cells));

    for i = 1:numel(cells)
        sub_cell_findings = {[]};
        if iscell(cells{i})
            sub_cell_findings{i} = cellfindstr(cells{i}, substr);
        else
            sub_cell_findings{i} = cellfindstr(cells{i}, substr);
        end
    end
end
