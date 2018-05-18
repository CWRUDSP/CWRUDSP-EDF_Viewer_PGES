
classdef EDFChannelInfo < handle
    properties
        single_channels;
    end

    properties(Constant)
        DC_DIG_PER_MILLIVOLT = double(hex2dec('555'))/500; %2.730
        DC_MILLIVOLT_PER_DIG = 500/double(hex2dec('555'));
    end
    % #1  -- 8  ascii : version of this data format (0)
    % #2  -- 80 ascii : local patient identification
    % #3  -- 80 ascii : local recording identification
    % #4  -- 8  ascii : startdate of recording (dd.mm.yy)
    % #5  -- 8  ascii : starttime of recording (hh.mm.ss)
    % #6  -- 8  ascii : number of bytes in header record
    % #7  -- 44 bytes -- header format (edf, as opposed to edf+c or edf+d)
    % #8  -- 8  bytes -- number of data records
    % #9  -- 8  bytes -- duration of a data record, in seconds.
    % #10 -- 4  bytes -- number of signals

    % NumberOfSampleInEachRecord;
    % PhysicalMinimum;
    % PhysicalMaximum;
    % PhysicalOffset;
    % DigitalMinimum;
    % DigitalMaximum;
    % SamplingRate;
    % ChMap;
    % PhysicalDimension;
    % Reserved;
    % Prefiltering;
    % TransducerType;

    methods
        function self = EDFChannelInfo(edf_channel_info)
            if nargin == 0, return, end;

            fields = fieldnames(edf_channel_info);

            fields_idx = strcmpi('DC_DIG_PER_MILLIVOLT',fields) |...
                         strcmpi('DC_MILLIVOLT_PER_DIG',fields);

            fields = fields(~fields_idx);

            fields_diff = stringsetdiff(fields, fieldnames(edf_channel_info));

            msg = sprintf('NK Channel difference: %s', strjoin(fields_diff, ', '));
            assert(numel(fields_diff)==0, msg);

            for i=1:numel(fields)
                f = fields{i};
                self.(f) = edf_channel_info.(f);

                if strcmpi(f,'single_channels')
                    assert(iscell(self.(f)), 'Single channels array must be cell.')
                    for i=1:numel(self.single_channels)
                        if ~isa(self.single_channels{i},'EDFSingleChannelInfo')
                            self.single_channels{i} = EDFSingleChannelInfo(self.single_channels{i});
                        end
                    end
                end
            end
        end
        function setSingleChannelInfo(self, channel_i, single_channel_info)
            self.single_channels{channel_i} = single_channel_info;
        end

        % function single_channel_info = singleChannel(self, channel_i)

        %     single_channel_info.NumberOfSampleInEachRecord  = self.NumberOfSampleInEachRecord(channel_i);
        %     single_channel_info.PhysicalMinimum             = self.PhysicalMinimum(channel_i);
        %     single_channel_info.PhysicalMaximum             = self.PhysicalMaximum(channel_i);
        %     single_channel_info.PhysicalOffset              = self.PhysicalOffset(channel_i);
        %     single_channel_info.DigitalMinimum              = self.DigitalMinimum(channel_i);
        %     single_channel_info.DigitalMaximum              = self.DigitalMaximum(channel_i);
        %     single_channel_info.SamplingRate                = self.SamplingRate(channel_i);

        %     single_channel_info.name                        = self.ChMap{channel_i};
        %     single_channel_info.Reserved                    = self.Reserved{channel_i};
        %     single_channel_info.Prefiltering                = self.Prefiltering{channel_i};
        %     single_channel_info.TransducerType              = self.TransducerType{channel_i};
        %     single_channel_info.PhysicalDimension           = self.PhysicalDimension{channel_i};

        %     single_channel_info = EDFSingleChannelInfo(single_channel_info);
        % end
        function c = channels_count(self)
            c =  numel(self.single_channels);
        end
        function ch_map = ChMap(self)
            ch_map = cellfun(@(sc) {sc.name} ,self.single_channels);
        end
        function [sref,a,b] = subsref(self,s)
            a=[];
            b=[];
            switch s(1).type
                case '.'
                    try
                        [sref,a,b] = builtin('subsref',self,s);
                        return
                    catch
                    end

                    try
                        [sref,a] = builtin('subsref',self,s);
                        return
                    catch
                    end

                    try
                        sref = builtin('subsref',self,s);
                    catch

                        % for i=1:numel(s)
                        %     typpe = s(i).type
                        %     subbs = s(i).subs
                        % end

                        if numel(s) == 1
                            sref = cellfun(@(sc) {builtin('subsref', sc, s)}, self.single_channels);
                            sref = [sref{:}];
                        else
                            s([2 1]) = s([1 2]);
                            if strcmp(s(1).type, '{}')
                                sref = cellfun(@(i) {builtin('subsref', self.single_channels{i}, s(2:end))}, s(1).subs);
                                if numel(sref) <= 1 || isnumeric(sref{1})
                                    sref = [sref{:}];
                                else
                                    sref=[];
                                end
                            else
                                sref = cellfun(@(i) {builtin('subsref', self.single_channels{i}, s(2:end))}, s(1).subs);
                                sref = [sref{:}];
                            end
                        end
                    end

                    return
                case '()'
                    sref = builtin('subsref',self.single_channels, s);
                    return
                case '{}'
                    sref = builtin('subsref',self.single_channels, s);
                    return
                otherwise
                  error('EDFChannelInfo:subsref',...
                     'Not a supported subscripted reference');
            end
        end

        %
        %   Note that for the displayChannelNames function below, we cannot return more than display_chmap
        %       because of limitations caused by implemented subsref. Thus, chmap_indeces and chmap_ui_indeces
        %       == 1:self.channels_count
        %
        function [display_chmap, channel_ui_indeces, channel_indeces] = displayChannelNames(self) %change. get rid of this.
            display_chmap = self.ChMap;
            channel_indeces = 1:self.channels_count;
            channel_ui_indeces = 1:self.channels_count;
        end
        function [segments_ui, segments_ui_indeces, segments_indeces] = getDisplaySegments(self)
            segments_indeces = 1;
            segments_ui_indeces = 1;
            segments_ui = {'1'};
        end
    end
end
