function subfolder = getSubfolder(pth, cells_keep_count)
    cells=strsplit(pth,separator());
    last_cell_i=min(cells_keep_count,numel(cells));
    cells = cells(1:last_cell_i);
    if numel(cells)>0
        subfolder = joinpath(cells{:});
    else
        subfolder = '';
    end
end
