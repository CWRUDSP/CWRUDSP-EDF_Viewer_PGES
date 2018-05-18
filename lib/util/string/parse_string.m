classdef parse_string

    methods(Static)
       function int_type_str = get_default_int_type_str()
            if any(strfind(computer('arch'), '64'))
                int_type_str = 'int64';
            else
                int_type_str = 'int32';
            end
       end

       function [int_value, int_str] = int_any(int_str, int_type_str, intfunc)

            if numel(int_str)
                int_str = int_str(('0' <= int_str & int_str <= '9') | int_str == '.' | int_str == '-');
            end

            if isempty(int_str)
                int_str = num2str(intfunc(int_type_str));
            end

            int_dec_pos = strfind(int_str,'.');
            int_is_dec = any(int_dec_pos);

            if int_is_dec
                int_str = int_str(int_dec_pos(1):end);
            end

            int_value = str2num(int_str);
        end
        function [int_value, float_str] = float_any(float_str, float_type_str, floatfunc)

            if numel(float_str)
                float_str = float_str(('0' <= float_str & float_str <= '9') | float_str == '.' | float_str == '-');
            end

            if isempty(float_str)
                float_str = num2str(floatfunc(float_type_str));
            end

            int_value = str2num(float_str);
        end

        function [int_value, int_max_str] = int_max(int_max_str,int_type_str);

            if nargin < 2
                int_type_str = parse_string.get_default_int_type_str();
            end
            [int_value, int_max_str] = parse_string.int_any(int_max_str, int_type_str, @intmax);
        end

        function [int_value, int_min_str] = int_min(int_min_str,int_type_str);

            if nargin < 2
                int_type_str = parse_string.get_default_int_type_str();
            end
            [int_value, int_min_str] = parse_string.int_any(int_min_str, int_type_str, @intmin)
        end


        function [float_value, float_max_str] = float_max(float_max_str, float_type_str)

            if nargin < 2
                float_type_str = 'single'; %float32 or float64 automatically.
            end
            [float_value, float_max_str] = parse_string.float_any(float_max_str, float_type_str, @realmax);
        end

        function [float_value, float_min_str] = float_min(float_min_str, float_type_str)

            if nargin < 2
                float_type_str = 'single'; %float32 or float64 automatically.
            end

            [float_value, float_min_str] = parse_string.float_any(float_min_str, float_type_str, @realmin);
        end
    end
end
