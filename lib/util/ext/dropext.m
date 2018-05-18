function fn_base= dropext(file_name_with_ext)
    cells=strsplit(file_name_with_ext,'.');
	n=max(numel(cells)-1,1);
    fn_base=strjoin(cells(1:n),'.');
end
