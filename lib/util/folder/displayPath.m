function dp = displayPath(p, maxFolders)
    [folder, localFolder] = fileparts(p);
    dp = joinpath('~',localFolder,'');
end
