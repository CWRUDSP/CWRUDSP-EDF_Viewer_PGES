function cells=indexcellstr(cells,index)
    s=size(cells);
    if nargin > 2
        for n=1:numel(cells)
            if n==index
                cells{n}=sprintf('%i)* %s', n, cells{n});
            else
                cells{n}=sprintf('%i)  %s', n, cells{n});
            end
        end
    else
        cells=cellcast(arrayfun(@(n) {sprintf('%i)  %s',n,cells{n})}, 1:numel(cells)));        
    end
    cells=reshape(cells,s);
end