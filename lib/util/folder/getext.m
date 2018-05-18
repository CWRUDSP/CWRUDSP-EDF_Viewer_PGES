function ext = getext(file_path)
    dot_pos = strfind(file_path,'.');
    if any(dot_pos)
        ext = file_path(dot_pos(1):end);
    else
        ext = '';
    end       
end
