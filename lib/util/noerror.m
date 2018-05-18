function no_error = noerror(me)

    if isa(me, 'MException')
        me = structify(me);
    elseif iscell(me)
        no_error = cellfun(@(me_single) noerror(me_single), me);
        return
    elseif isnumeric(me)
        if me==0
            no_error=true;
            return
        end
    end

    strs = strsplit(me.identifier, ':');
    error_type = strs{2};

    no_error = strcmp('NoError', error_type);
end
