function does = endswith_base(strs, str_end, case_sensitive)
    %does = endswith_base(strs, str_end, case_sensitive)
    
    if nargin < 3
        case_sensitive=false;
    end
    
    strs = cellflatten(cellcast(strs));
    if case_sensitive
        does = cellfun(@(str) single_endswith(str, str_end, @strcmp), strs);
    else
        does = cellfun(@(str) single_endswith(str, str_end, @strcmpi), strs);
    end
end

function does = single_endswith(str, str_end, strcmpfun)
    does=false;
    start_pos = 1+numel(str)-numel(str_end);
    if start_pos > 0
        does = strcmpfun(str(start_pos:end), str_end);
    end
end
