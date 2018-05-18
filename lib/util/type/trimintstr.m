function s = trimintstr(s)
    if isnumeric(s)
        s = int2str(s);
    elseif ischar(s)

    else
        error('trimintstr(s): `s` must be numeric or string.')
    end
end

function string_is_int_parseable()

end
