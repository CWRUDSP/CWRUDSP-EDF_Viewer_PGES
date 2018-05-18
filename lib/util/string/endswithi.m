function does = endswithi(strs, str_end)
    if iscell(str_end)
        does = false(1,numel(strs));
        for n=1:numel(str_end)
            does=does|endswithi(strs, str_end{n});            
        end        
        return
    end
    
    case_sensitive = false;
    does = endswith_base(strs, str_end, case_sensitive);
end
