function [success, exception, output] = trycatch(f, output_init, varargin)
    success=true;
    exception=struct;
    output=output_init;
    try
        output = f(varargin{:});
    catch exception
        success=false;
    end
end
