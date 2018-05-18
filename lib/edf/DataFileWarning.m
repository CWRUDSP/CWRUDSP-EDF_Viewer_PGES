%--------------------------------------------------------------------------
% @license
% Copyright 2018 IDAC Signals Team, Case Western Reserve University 
%
% Lincensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public 
% you may not use this file except in compliance with the License.
%
% Unless otherwise separately undertaken by the Licensor, to the extent possible, 
% the Licensor offers the Licensed Material as-is and as-available, and makes no representations 
% or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. 
% This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, 
% non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, 
% whether or not known or discoverable. 
% Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.
%
% To the extent possible, in no event will the Licensor be liable to You on any legal theory 
% (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, 
% consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of 
% this Public License or use of the Licensed Material, even if the Licensor has been advised of 
% the possibility of such losses, costs, expenses, or damages. 
% Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.
%
% The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, 
% to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.
%
% Developed by the IDAC Signals Team at Case Western Reserve University 
% with support from the National Institute of Neurological Disorders and Stroke (NINDS) 
%     under Grant NIH/NINDS U01-NS090405 and NIH/NINDS U01-NS090408.
%              James McDonald
%--------------------------------------------------------------------------
classdef DataFileWarning < handle
    properties(Constant)
        NK_MISSING_EEG_FILE = 0; %Nihon Kohden (NK)
        NK_MISSING_LAY_FILE = 1; %Nihon Kohden (NK)
        NK_MISSING_11D_FILE = 2; %Nihon Kohden (NK)
        NK_MISSING_21E_FILE = 3; %Nihon Kohden (NK)
        NK_MISSING_LOG_FILE = 4; %Nihon Kohden (NK)
        NK_MISSING_PNT_FILE = 5; %Nihon Kohden (NK)
        NK_MISSING_FILE_MESSAGE = @nk_missing_file_msg;          %Nihon Kohden (NK)
        NK_BROKEN_EEG_FILE = 6; %Nihon Kohden (NK)
        NK_BROKEN_LAY_FILE = 7; %Nihon Kohden (NK)
        NK_BROKEN_11D_FILE = 8; %Nihon Kohden (NK)
        NK_BROKEN_21E_FILE = 9; %Nihon Kohden (NK)
        NK_BROKEN_LOG_FILE = 10; %Nihon Kohden (NK)
        NK_BROKEN_PNT_FILE = 11; %Nihon Kohden (NK)
        NK_BROKEN_FILE_MESSAGE = @nk_broken_file_msg;            %Nihon Kohden (NK)
        NK_CHANNEL_NOT_AC_DC = 12;
        NK_CHANNEL_NOT_AC_DC_MESSAGE = @nk_channel_not_dc_or_ac_msg; %Nihon Kohden (NK)
        NK_DC_CHANNEL_DISABLED = 13;
        NK_DC_CHANNEL_DISABLED_MESSAGE = @nk_dc_channel_disabled; %Nihon Kohden (NK)
    end

    properties
        code;
        msg;
    end

    methods
        function self = DataFileWarning(code, msg)
            warning(msg);
            msg.msg=msg;
            self.code=code;
        end
    end
end





function msg = nk_missing_file_msg(varargin)
    msg = sprintf('file `%s`: Error loading .%s file.', varargin{:});
end

function msg = nk_broken_file_msg(varargin)
    msg = sprintf('file `%s`: Error parsing .%s file.', varargin{:});
end

function msg = nk_channel_not_dc_or_ac_msg(varargin)
    msg = sprintf('file `%s`: Channel %i, %s is apparently neither AC or DC: ', varargin{:});
end

function msg = nk_dc_channel_disabled(varargin)
    msg = sprintf('Recording may be garbage; channel is recorded but `disabled`: %i, %s', varargin{:});
end



