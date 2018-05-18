function [extensions, names, valid_arg] = findFileExtensionsi(folder, filename_base)
    % [extensions, valid] = findFileExtensions(varargin)
    %
    %               think about it like
    %
    %
    % [extensions, valid] = findFileExtensions(folder, filename_base)
    %
    %                       --or--
    %
    % [extensions, valid] = findFileExtensions(filepathbase)
    %
    %
    %
    if nargin < 2
        filename_base='';
    end

    is_dir.folder = exist(folder,'dir')==7;
    is_dir.filepath_base = exist(filename_base,'dir')==7;

    valid_arg = true;

    if ~is_dir.folder
        valid_arg = false;
        extensions = {''};
    else % if is_dir.filepath_base which implies is_dir.folder
        [extensions, names] = localFindFiles(folder, filename_base, @startswithi);
    end
end

function [exts, names] = localFindFiles(folder,filename_base_beginning, startswith_func)
    dirs = dir(folder);
    exts = {};
    names= {};
    for i=1:numel(dirs)
        if dirs(i).isdir, continue, end;
        [~, name, ext] = fileparts(joinpath(folder, dirs(i).name));
        if startswith_func(name, filename_base_beginning)
            exts = cellflatten(exts, ext);
            names = cellflatten(names, sprintf('%s.%s',name, ext));
        end
    end
end
