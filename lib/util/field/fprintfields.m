function fprintfields(struct)
    handle.top = struct;
	display(get_struct_value(handle,'',3));
end

function value_str = get_struct_value(struct,struct_padding,struct_size)
	fields = {};
    
	try 
		fields = fieldnames(struct);
	catch
		fields = {};
	end

	value_str = '';
	if nargin == 1
		struct_padding = '..';
	end
	if numel(fields) > 0
		for i = 1:numel(fields)
            indent = repmat(' ',1,struct_size);
            field_size = numel(fields{i});
            field_padding = [ struct_padding(1:end-field_size+1), indent, '.'];
            struct_value = get_struct_value( struct.(fields{i}), field_padding, field_size);
            if struct_value(1) == ':'
    			value_str = [value_str,sprintf(['\n%s%s',struct_value], struct_padding,fields{i})];
            else
    			value_str = [value_str,sprintf(['\n%s%s.',struct_value], struct_padding,fields{i})];
            end
		end
    else
        try
            %TODO:
            value_str = ':';
            size_struct = size(struct);
            if size_struct(1) > 1            
                for i = 1:size(struct,1)
                    value_str = [value_str,num2str(struct(i,:)),'\n'];
                end
            else
                value_str = [value_str, num2str(struct{:}), '\n'];
            end
        catch
            size_struct = size(struct);
            if iscell(struct)
                struct = reshape(struct{:},size_struct(1),size_struct(2));
            end
           value_str = num2str(struct); 
        end
                
    end
end