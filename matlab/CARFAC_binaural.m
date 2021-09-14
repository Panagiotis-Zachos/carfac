% Copyright 2012 The CARFAC Authors. All Rights Reserved.
% Author: Richard F. Lyon
%
% This file is part of an implementation of Lyon's cochlear model:
% "Cascade of Asymmetric Resonators with Fast-Acting Compression"
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

% Test/demo hacking for carfac matlab stuff, two-channel (binaural) case

clearvars

agc_plot_fig_num = 0;

[file_signal,fsOld] = audioread('../test_data/binaural_test.wav');
file_signal = file_signal(9000+(1:15000));  % trim for a faster test

itd_offset = 22;  % about 1 ms
test_signal = [file_signal((itd_offset+1):end), ...
               file_signal(1:(end-itd_offset))] / 10;

fs = 16000;
test_signal = resample(test_signal,fs,fsOld);
n_ears = 2;


CF_CAR_params = struct( ...
    'velocity_scale', 0.1, ...  % for the velocity nonlinearity
    'v_offset', 0.04, ...  % offset gives a quadratic part
    'min_zeta', 0.10, ... % minimum damping factor in mid-freq channels
    'max_zeta', 0.35, ... % maximum damping factor in mid-freq channels
    'first_pole_theta', 1*pi, ...% Default:0.85*pi, ...
    'zero_ratio', sqrt(2), ... % how far zero is above pole
    'high_f_damping_compression', 0.5, ... % 0 to 1 to compress zeta
    'ERB_per_step', 0.5, ... % assume G&M's ERB formula
    'min_pole_Hz', 500, ... % Default: 30
    'ERB_break_freq', 165.3, ...  % Greenwood map's break freq.
    'ERB_Q', 1000/(24.7*4.37));  % Glasberg and Moore's high-cf ratio
CF_struct = CARFAC_Design(n_ears,fs,CF_CAR_params);  % default design

% Run stereo test:

CF_struct = CARFAC_Init(CF_struct);
  
[CF_struct, nap_decim, nap] = CARFAC_Run(CF_struct, test_signal, agc_plot_fig_num);

% Display results for 2 ears:
% for ear = 1:n_ears
%   smooth_nap = nap_decim(:, :, ear);
%   figure(ear + n_ears)  % Makes figures 3 and 4
%   image(63 * ((abs(smooth_nap))' .^ 0.5))
% 
%   colormap(1 - gray);
% end

% Show resulting data, even though M-Lint complains:
% CF_struct
% CF_struct.CAR_params
% CF_struct.AGC_params
% min_max = [min(nap(:)), max(nap(:))]
% min_max_decim = [min(nap_decim(:)), max(nap_decim(:))]

