function str = strbetweeni(str,a,b)
    a = lower(a);
    b = lower(b);

    bef = strfind(str,a);
    aft = strfind(str,b);

    if any(bef)
        if ~any(aft)
            str_found = {str(bef(end)+1:end)};
        else
            str_found = {};
            i = 0;
            while i < numel(bef)
                i = i + 1;
                for i = 1:numel(bef)
                    for j = 1:numel(aft)
                        if bef(i) >= aft(j)
                            continue;
                        elseif bef(i) < aft(j) && i == numel(bef)
                            str_found = str(bef(i)+1:aft(j)-1);
                        else % bef(i) < aft(j) && i < numel(bef)
                            while bef(i+1) < aft(j) && i < numel(bef)
x                               i = i+1;
                                str_found = str(bef(i)+1:aft(j)-1);
                            end
                        end
                    end
                end
            end
        end
    elseif any(aft)
        str_found = {str(1:aft(1)-1)};
    end
end
