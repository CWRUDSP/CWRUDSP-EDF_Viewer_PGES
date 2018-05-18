function val = evalf(str, varargin)
    str = sprintf(str, varargin{:});
    val = eval(str);
end
