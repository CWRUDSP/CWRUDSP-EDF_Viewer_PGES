function b = startswithi(str, beginning)
    
    if iscell(str)
        b = false(size(str));
        for n=1:numel(str)
           b(n)=startswithi(str{n},beginning);
        end
        return        
    end

    if iscell(beginning)
        b = cellfun(@(beg) startswithi(str, beg), beginning);
        return
    end



    if isempty(beginning) && ischar(beginning)
        b = true;
        return
    end

    index = strfindi(str, beginning);
    b = any(index);

    if ~b, return, end;

    b = index(1) == 1;
end
