function b = startswith(str, beginning)
    if isempty(beginning) && ischar(beginning)
        b = true;
        return
    end

    index = strfind(str, beginning);
    b = any(index);

    if ~b, return, end;

    b = index(1) == 1;
end
