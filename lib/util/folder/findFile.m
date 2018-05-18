function [files_list, folders_list] = findFile(main_folder, sub_path, exts, recursive)
    %    [files_list, folders_list] = findFile(main_folder, sub_path, exts, recursive)
    %
    if nargin < 4
        recursive = true;
    end
    if nargin < 3
        exts = {''};
    end
    exts = cellcast(exts);

    if nargin < 2
        sub_path = '';
    end

    if nargin < 1
        main_folder = pwd;
    end

    warning off verbose;
    warning('deprecated: findFile')
    warning on verbose;
    [files_list, folders_list] = findFiles(main_folder, sub_path, exts, recursive);
end
