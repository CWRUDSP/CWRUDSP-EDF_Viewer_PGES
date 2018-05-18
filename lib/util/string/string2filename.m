function string = string2filename(string)
    if iscell(string)
        string = cellfun(@(s) {string2filename(s)}, string);
        return
    end

    cells = strsplit(string,'>=');
    string = strjoin(cells,'_gte_');

    cells = strsplit(string,'<=');
    string = strjoin(cells,'_lte_');

    cells = strsplit(string,'/');
    string = strjoin(cells,'_fslsh_');

    cells = strsplit(string,'\');
    string = strjoin(cells,'_bslsh_');

    cells = strsplit(string,'?');
    string = strjoin(cells,'_x_');

    cells = strsplit(string,'*');
    string = strjoin(cells,'_ast_');

    cells = strsplit(string,'>');
    string = strjoin(cells,'_gt_');

    cells = strsplit(string,'<');
    string = strjoin(cells,'_lt_');

    cells = strsplit(string,'"');
    string = strjoin(cells,'``');

    cells = strsplit(string,'|');
    string = strjoin(cells,';');

    is_alpha = 'a' <= lower(string) & lower(string) <= 'z';
    is_numer = '0' <= lower(string) & lower(string) <= '9';
    is_ok    = string == ',';
    is_ok    = is_ok | string == ' ';
    is_ok    = is_ok | string == '.';
    is_ok    = is_ok | string == ';';
    is_ok    = is_ok | string == '[';
    is_ok    = is_ok | string == ']';
    is_ok    = is_ok | string == '(';
    is_ok    = is_ok | string == ')';
    is_ok    = is_ok | string == '!';
    is_ok    = is_ok | string == '@';
    is_ok    = is_ok | string == '#';
    is_ok    = is_ok | string == '$';
    is_ok    = is_ok | string == '%';
    is_ok    = is_ok | string == '^';
    is_ok    = is_ok | string == '+';
    is_ok    = is_ok | string == '-';

    string(~is_alpha & ~is_numer & ~is_ok) = '_';

    cells = strsplit(string,'_');
    rid = cellfun(@(c) numel(c) == 0, cells);
    cells(rid) = [];
    string = strjoin(cells,'_');
end
