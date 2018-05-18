function has = hasext(name, ext)
    ext_cells = strsplit(ext,'.');
    ext = strtrim(ext_cells{end});

    name_ext_cells = strsplit(name,'.');
    name_ext = strtrim(name_ext_cells{end});

    has = strcmpi(name_ext, ext) & numel(name_ext_cells) > 1;
end
