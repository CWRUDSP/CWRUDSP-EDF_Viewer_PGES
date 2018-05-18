function sep = separator()
    if ispc
        sep = '\';
    else
        sep = '/';
    end
end