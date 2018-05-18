function cells = repcell(item,syze)
    if isempty(syze)
        error('syze must have at least one element.')
    elseif numel(syze) == 1
        syze = syze*[1,1];
    end

    count = prod(syze);

    cells = cell(1,count);
    for i =1:count
        cells{i} = item;
    end
    cells = reshape(cells,syze);
end
