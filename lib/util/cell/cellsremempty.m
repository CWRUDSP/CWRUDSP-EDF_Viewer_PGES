function cells = cellsremempty(cells)
    cells = cellpick(@(c) ~isempty(c), cells);
end
