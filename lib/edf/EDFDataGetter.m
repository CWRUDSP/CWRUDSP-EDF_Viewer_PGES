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
classdef EDFDataGetter < handle
    properties(GetAccess='public',SetAccess='protected')
        fid;
        edfs;
        channel_buffers;
        channel_buffers_end_time;
        channel_buffers_beg_time;
        channel_buffers_end_index;
        channel_buffers_beg_index;
    end

    methods
        function self = EDFDataGetter(edf_file)

            assert(isa(edf_file, 'EDF_File'), sprintf('class(edf_file) == %s', class(edf_file)))

            self.fid = fopen(edf_file.filepath_data, 'r');
            self.edfs = edf_file;

            self.channel_buffers           = cell(1, self.channels_count);
            self.channel_buffers_end_time  = cell(1, self.channels_count);
            self.channel_buffers_beg_time  = cell(1, self.channels_count);
            self.channel_buffers_end_index = cell(1, self.channels_count);
            self.channel_buffers_beg_index = cell(1, self.channels_count);
        end
        function c = channels_count(self)
            c = self.edfs.ChInfo.channels_count;
        end
        function [success, me] = close(self)
            success = true;
            try
                fclose(self.fid);
            catch me
            end
        end
        function open(self)
            self.fid = fopen(self.edfs.filepath_data,'r');
        end
        function b = channelBufferIsLoaded(self, channel_i, beg_index, end_index)
            b = false;
            if numel(self.channel_buffers) >= channel_i
                if any(self.channel_buffers{channel_i})
                    % beg_index
                    % end_index
                    self.channel_buffers_beg_index{channel_i};
                    self.channel_buffers_end_index{channel_i};

                    if self.channel_buffers_beg_index{channel_i} <= beg_index && beg_index <= self.channel_buffers_end_index{channel_i}
                        if self.channel_buffers_beg_index{channel_i} <= end_index && end_index <= self.channel_buffers_end_index{channel_i}
                            b = true;
                        end
                    end
                end
            end
        end

        function [channel_buffer, success, modified, exception] = getChannelBuffer(self, channel_i, beg_index, end_index)

            success = true;
            modified = false;
            channel_buffer = [];
            exception = MException('getChannelBuffer:NoError','');

            loaded = self.channelBufferIsLoaded(channel_i, beg_index, end_index);
            if ~loaded
                [success, modified, me] = self.loadChannelBuffer(channel_i, beg_index, end_index);
                if ~success
                    exception = me;
                end
            end

            buff_beg_index = self.channel_buffers_beg_index{channel_i};
            % buff_end_index = self.channel_buffers_end_index{channel_i};

            buff_read_beg_index = 1 + beg_index - buff_beg_index;
            buff_read_end_index = 1 + end_index - buff_beg_index;

            buff_read_end_index = min(buff_read_end_index, numel(self.channel_buffers{channel_i}));

            channel_buffer = self.channel_buffers{channel_i}(buff_read_beg_index:buff_read_end_index);
        end

        function [beg_index, end_index] = getIndecesByTime(self, channel_i, beg_time, end_time)
            sampling_rates = self.edfs.ChInfo.SamplingRate;
            sampling_rate = sampling_rates(channel_i);

            beg_index = 1 + ceil(beg_time * sampling_rate);
            end_index = 1 + floor(end_time * sampling_rate);
        end

        function buff = castBufferToUnits(self, channel_i, buff)
            edf_channel = self.edfs.ChInfo.single_channels{channel_i};
            physical_range = double(edf_channel.PhysicalMaximum) - double(edf_channel.PhysicalMinimum);
            digital_range = double(edf_channel.DigitalMaximum) - double(edf_channel.DigitalMinimum);
            coeff = physical_range / digital_range;

            % below more efficient than: phys_min + coeff * (double(buffer) - dig_min)
            phys_const = double(edf_channel.PhysicalMinimum) - ...
                         coeff * double(edf_channel.DigitalMinimum);
            buff = phys_const + coeff * double(buff);
            % + self.ChInfo.PhysicalOffset(channel_id);
        end

        function [success, modified, exception] = loadChannelBuffer(self, channel_i, beg_index, end_index)
            success = true;
            modified = false;
            exception = MException('loadChannelBuffer:NoError','');

            %seek channel buffer
            % channel_id

            % channel_sampling_rate = self.edfs.ChInfo.single_channels{channel_i}.SamplingRate;
            all_channel_record_samples_count = self.edfs.ChInfo.NumberOfSampleInEachRecord;
            channel_record_samples_count = all_channel_record_samples_count(channel_i);
            block_samples_count = sum(all_channel_record_samples_count);

            header_bytes_count = self.edfs.HeaderSizeInByte;
            block_bytes_count = 2 * block_samples_count;
            block_before_channel_bytes_count = 2 * sum(all_channel_record_samples_count(1:channel_i-1));

            block_beg_index = 1 + floor((beg_index-1) / channel_record_samples_count);
            block_end_index = 1 + ceil((end_index-1) / channel_record_samples_count);

            block_beg_index = max(block_beg_index, 1);
            block_end_index = min(block_end_index, self.edfs.NumberOfDataRecords);

            bof_pos_bytes = header_bytes_count + (block_beg_index - 1) * block_bytes_count + block_before_channel_bytes_count;
            
            fseek(self.fid, bof_pos_bytes, 'bof');
            %load channel buffer
            buffer_samples_size = [1, (block_end_index - block_beg_index + 1) * channel_record_samples_count ];
            buffer_bytes_skip = block_bytes_count - 2 * channel_record_samples_count;
            self.channel_buffers{channel_i} = fread(self.fid,...
                                                    buffer_samples_size,...
                                                    sprintf('%i*int16=>int16',channel_record_samples_count),...
                                                    buffer_bytes_skip);

            channel_buffers_samples_loaded = numel(self.channel_buffers{channel_i});
            % channel_record_blocks_loaded = channel_buffers_samples_loaded/channel_record_samples_count;

            if channel_buffers_samples_loaded < 1 + end_index - beg_index
                modified = true;
            end

            new_channel_buffers_beg_index = 1 + (block_beg_index - 1) * channel_record_samples_count; %1st sample in 1st loaded block

            % Note: 2016.02.16 - instead of storing the indeces for the requested buffer,
            % we save the one that can actually be loaded, and so getChannelTime automatically
            % fixes it's indeces loads the corrected buffer

            % new_channel_buffers_end_index = block_end_index * channel_record_samples_count; %last sample in last loaded block
            new_channel_buffers_end_index = new_channel_buffers_beg_index + channel_buffers_samples_loaded - 1;

            self.setBufferIndeces(channel_i, new_channel_buffers_beg_index, new_channel_buffers_end_index);

            %Note: remember that when it reads, it will read extra stuff from the entire block
            %      containing the begin, end index actually requested. we have to throw away the
            %      stuff outside of these indeces when actually reading our from
            %      self.channel_buffers{channel_id}
        end

        function channel_time = getChannelTime(self, channel_i, beg_i, end_i)
            %   channel_time = getChannelTime(self, channel_id, beg_index, end_index)
            %
            %   This can extrapolate time axis past the loaded sample buffer's indeces.
            %
            buff_beg_time = self.channel_buffers_beg_time{channel_i};
            buff_end_time = self.channel_buffers_end_time{channel_i};
            buff_beg_i = self.channel_buffers_beg_index{channel_i};
            buff_end_i = self.channel_buffers_end_index{channel_i};

            buff_samples_count = 1 + buff_end_i - buff_beg_i;
            buff_time_duration = buff_end_time - buff_beg_time;

            coeff = buff_time_duration/(buff_samples_count-1);

            beg_time = buff_beg_time + coeff * (beg_i - buff_beg_i);
            end_time = buff_beg_time + coeff * (end_i - buff_beg_i);

            channel_time = linspace(beg_time, end_time, 1 + end_i - beg_i);
        end

        function displayState(self)

            fprintf('\tEDFDataGetterChannels:\t\n')
            for channel_i=1:self.channels_count

                buff_ind_str = sprintf('%s:%s',...
                                        my_num2str(self.channel_buffers_beg_index{channel_i}),...
                                        my_num2str(self.channel_buffers_end_index{channel_i}));

                buff_time_str = sprintf('%s:%s',...
                                        my_num2str(self.channel_buffers_beg_time{channel_i}),...
                                        my_num2str(self.channel_buffers_end_time{channel_i}));

                size_str = num2str(size(self.channel_buffers{channel_i}));


                samples_loaded = numel(self.channel_buffers{channel_i});
                duration_loaded = 0;
                if samples_loaded > 0
                    duration_loaded = self.channel_buffers_end_time{channel_i} -  self.channel_buffers_beg_time{channel_i};
                end

                fprintf('\tchannel %i)\tloaded_indeces: %s\t(%i samples),\tloaded times: %s\t(%.2f seconds)\tbuffer_size: [\t%s] loaded\n', ...
                        channel_i, buff_ind_str, samples_loaded, buff_time_str, duration_loaded, size_str);

            end
        end
    end

    methods(Access='private')
        function setBufferIndeces(self, channel_i, new_beg_index, new_end_index)

%             if numel(self.channel_buffers_end_index) < channel_i
%                 self.channel_buffers_end_index{channel_i} = [];
%             end
%             if numel(self.channel_buffers_beg_index) < channel_i
%                 self.channel_buffers_beg_index{channel_i} = [];
%             end

            %             if ~isempty(self.channel_buffers_beg_index{channel_i})
            %                 new_beg_index = min(new_beg_index, self.channel_buffers_beg_index{channel_i});
            %             end
            %             if ~isempty(self.channel_buffers_end_index{channel_i})
            %                 new_end_index = max(new_end_index, self.channel_buffers_end_index{channel_i});
            %             end

            self.channel_buffers_beg_index{channel_i} = new_beg_index;
            self.channel_buffers_end_index{channel_i} = new_end_index;

            channel_sampling_rate = self.edfs.ChInfo{channel_i}.SamplingRate;
            self.channel_buffers_beg_time{channel_i} = (new_beg_index-1) / channel_sampling_rate;
            self.channel_buffers_end_time{channel_i} = (new_end_index-1) / channel_sampling_rate;
        end
    end
end

function str = my_num2str(num)
    str = 'N/A';

    if ~isempty(num)
        str=num2str(num);
    end
end



