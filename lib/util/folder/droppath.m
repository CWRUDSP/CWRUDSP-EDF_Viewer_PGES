function filename = droppath(filepath)
	[pth,name,ext] = fileparts(filepath);

    filename = [name,ext];
end