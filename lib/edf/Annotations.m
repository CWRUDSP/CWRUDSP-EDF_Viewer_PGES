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
classdef Annotations < handle

    properties(Constant)
        TIMESTAMP_FORMAT = 'HH:MM:SS.FFF';
        TIMESTAMP_FORMAT_EMPTY = '00:00:00.000';

        TIMESTAMP_FORMAT_ALT = 'HH:MM:SS';  %Seen on UH-PRISM txt files.
        TIMESTAMP_FORMAT_EMPTY_ALT = '00:00:00';
    end
    properties(GetAccess='public', SetAccess='protected')
        Time;
        Text;
        warnings;
    end

    methods(Static)
        function a = empty()
            a = Annotations();
        end
        function seconds = STAMP_TO_SECONDS(ts)
            seconds=nan;
            try
                [~,~,~, H, MN, S] = datevec(ts, Annotations.TIMESTAMP_FORMAT);
                % [Y, M, D, H, MN, S] = datevec(ts);
                seconds = H*3600 + MN*60 + S;
            catch
            end
            
            if isnan(seconds)
                try
                    [~,~,~, H, MN, S] = datevec(ts, Annotations.TIMESTAMP_FORMAT_ALT);
                    % [Y, M, D, H, MN, S] = datevec(ts);
                    seconds = H*3600 + MN*60 + S;
                catch
                end
            end
        end

        function stamp = SECONDS_TO_STAMP(seconds)
            seconds_per_day = 3600*24;
            stamp = datestr(seconds/seconds_per_day, Annotations.TIMESTAMP_FORMAT);
        end

        function [stamp, comment, me] = LINE_TO_STAMP(line)
            me = MException('Annotations:NoError', '');
            FORMAT_LENGTH = numel(Annotations.TIMESTAMP_FORMAT);
            if numel(line) < FORMAT_LENGTH

                stamp = Annotations.TIMESTAMP_FORMAT_EMPTY;
                stamp(1:numel(line)) = line;
                comment = '';

                me = MException('Annotations:ParseError', 'Could not parse timestamp `%s` to `%s`', line, Annotations.TIMESTAMP_FORMAT);

                return
            end

            stamp = line(1:FORMAT_LENGTH);
            comment = line((FORMAT_LENGTH+1):end);
        end
        function [comment, stamp, me] = LINE_TO_COMMENT(line)
            [stamp, comment, me] = Annotations.LINE_TO_STAMP(line);
        end
     end

    methods
        function self = Annotations(annotations_struct)
            self.Text = {};
            self.warnings = {};
            if nargin == 0, return, end;

            fields = fieldnames(Annotations());
            rid = strcmp('TIMESTAMP_FORMAT', fields) |...
                  strcmp('TIMESTAMP_FORMAT_EMPTY', fields) | ...
                  strcmp('TIMESTAMP_FORMAT_ALT', fields) |...
                  strcmp('TIMESTAMP_FORMAT_EMPTY_ALT', fields);

            fields(rid) = [];

            for i=1:numel(fields)
                f = fields{i};
                self.(f) = annotations_struct.(f);
                if strcmp(f, 'Text')
                    self.Text = cellfun(@(s) {deblank(s)}, self.Text);
                    for n=1:numel(self.Text)
                        self.Text{n}(self.Text{n}==0)=' ';
                    end
                end
            end

            assert(numel(self.Time)==numel(self.Text));
        end
        function self = format(self, fmt)
            self.Text = cellcast(cellfun(@(s) {sprintf(fmt, s)}, self.Text));
        end
        function c = count(self)
            c = numel(self.Time);
        end
        function remove(self,index)
            self.Time(index)=[];
            self.Text(index)=[];
        end
        function removeAll(self)
            self.Time=[];
            self.Text={};
        end       
        function addWarning(self, warnings)
            warnings=cellcast(warnings);
            self.warnings = {self.warnings{:}, warnings{:}};
        end
        function add(self, times, comments)
            %refactor: figure out best place to put the carriage return in comments - necessary when writing files but not when using them here.
            comments = cellcast(comments);

            assert(numel(times) == numel(comments), 'comments and times must be equal in length')

            if iscellstr(times)
                times = cellfun(@(t) {Annotations.STAMP_TO_SECONDS(t)}, times);
            end

            if iscell(times)
                times = [times{:}]; %refactor-note: clear carriage return from here.
            end
            
            for n=1:numel(comments)
                comments{n}(comments{n}==0)=' ';
            end

            self.Text = {self.Text{:}, comments{:}}; % cells
            self.Time = [reshape(self.Time(:), 1, []), reshape(times, 1, [])];

            [~, ii] = unique(self.toLines()); %useful if adding comments from multiple files. often they repeat;
                                              % toLines() consideres both time stamp as string and the comment in unique.

            self.Time = self.Time(ii);
            self.Text = self.Text(ii);
        end
        function stamp = toStamp(self, i)
            stamp = Annotations.SECONDS_TO_STAMP(self.Time(i));
        end
        function stamps = toStamps(self)
            stamps = arrayfun(@(i) {self.toStamp(i)}, 1:self.count);
        end
        function Line = toLine(self, i)
            Line = [self.toStamp(i), char(9), self.Text{i}];
        end
        function lines = toLines(self)
            lines = arrayfun(@(i) {[self.toLine(i) char(13) char(10)]}, 1:self.count);
            lines = cellcast(lines);
        end
        function str = toStruct(self)
            warning off matlab:structOnObject;
            str = struct(self);
            str = rmfield(str, {'TIMESTAMP_FORMAT',...
                                'TIMESTAMP_FORMAT_EMPTY',...
                                'TIMESTAMP_FORMAT_ALT',...
                                'TIMESTAMP_FORMAT_EMPTY_ALT'});
            warning on matlab:structOnObject;
        end
    end
end

