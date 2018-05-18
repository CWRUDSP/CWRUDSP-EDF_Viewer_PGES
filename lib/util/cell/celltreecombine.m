function [combined_cells, equal_structure] = celltreecombine(cellsA,cellsB,combine, varargin)
    combined_cells = cell(size(cellsA));

    sizeA = size(cellsA);
    sizeB = size(cellsB);

    iscellA = iscell(cellsA);
    iscellB = iscell(cellsB);

    isscalarA = isscalar(cellsA);
    isscalarB = isscalar(cellsB);

    equal_structure = iscellA ~= iscellB;
    equal_structure = equal_structure && (isscalarA ~= isscalarB);

    if equal_structure
        equal_structure = false;
        if numel(sizeA) == numel(sizeB)
            if all(shape(sizeA) == shape(sizeB))
                equal_structure = true;
            end
        end
    end

    if equal_structure
        if isscalarA
            if ~iscellA
                combined_cells = f(cells, varargin{:});
            else
                [combined_cells{1}, equal_structure] = celltreecombine(cellsA{1}, cellsB{1}, varargin{:});
            end
        else
            for i = 1:numel(cells)
                if iscellA
                    [ combined_cells{i}, equal] = celltreecombine(cellsA{i}, cellsB{i}, varargin{:});
                else
                    [ combined_cells(i), equal] = celltreecombine(cellsA(i), cellsB{i}, varargin{:});
                end
                equal_structure = equal_structure && equal;
            end
        end
    end
end
