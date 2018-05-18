function are_empy=areempty(cells)
    s=size(cells);
    cells=reshape(cells,1,[]);
    are_empy=reshape(cellfun(@(c) isempty(c), cells), s);
end