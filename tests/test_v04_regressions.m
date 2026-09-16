function test_v04_regressions()
%TEST_V04_REGRESSIONS Regression tests from real classroom-use feedback.

% The time-domain apparent alias must agree with the ACTUAL samples, not
% merely use the absolute alias-frequency magnitude with the wrong phase.
d=sine_sampling_demo(800,1000,0.02);
xAtSamples=interp1(d.tRef,d.xApparent,d.tSample,'linear');
assert(max(abs(xAtSamples-d.xSample)) < 2e-3, ...
    'Apparent alias curve must pass through the actual sample points.');

f = main();
cleanup = onCleanup(@()close_if_valid(f)); %#ok<NASGU>
drawnow;

% Playback-original must resolve the CURRENT audio at click time, not capture
% the startup demo signal in an anonymous closure.
playOriginal = require_tag(f,'playOriginalButton');
cbText = func2str(playOriginal.ButtonPushedFcn);
assert(~startsWith(strtrim(cbText),'@('), ...
    'Playback-original still uses an anonymous value-capturing callback.');
assert(contains(cbText,'onPlayOriginal'), ...
    'Playback-original must use a nested callback that reads current audio.');

% Sampling: sample count is derived from fs and duration, and the display
% must include a polyline joining the ACTUAL discrete sample values.
f0 = require_tag(f,'samplingF0');
fsField = require_tag(f,'samplingFs');
dur = require_tag(f,'samplingDuration');
f0.Value = 800; fsField.Value = 1000; dur.Value = 0.02;
invoke_button(f,'运行正弦采样实验');
countLabel = require_tag(f,'sampleCountLabel');
assert(contains(countLabel.Text,'21'), '1000 Hz over 0.02 s should show 21 samples including both endpoints.');
ax = require_tag(f,'samplingTimeAxes');
joined = findall(ax,'Type','line','Tag','samplePolyline');
assert(numel(joined)==1, 'Sampling plot must contain a line connecting the actual sample points.');
assert(numel(joined.XData)==21, 'Sample polyline must use the actual discrete sample count.');

% Terminology: make direct decimation understandable to a first-time user.
assert(numel(findall(f,'Type','uilabel','Text','实验 B：语音降采样（每隔 M 点保留 1 点）'))==1, ...
    'Decimation experiment needs plain-language naming.');
assert(numel(findall(f,'Type','uibutton','Text','执行语音降采样'))==1, ...
    'Decimation action needs plain-language naming.');

% Filtering is a two-stage workflow: add noise first, then filter it.
assert(numel(findall(f,'Type','uibutton','Text','步骤 1：生成含噪语音'))==1, ...
    'Noise generation must be a separate stage.');
assert(numel(findall(f,'Type','uibutton','Text','步骤 2：应用滤波器'))==1, ...
    'Filtering must be a separate stage.');

noiseMode = require_tag(f,'noiseMode');
tone = require_tag(f,'interferenceFrequency');
f1 = require_tag(f,'filterF1');
f2 = require_tag(f,'filterF2');
noiseMode.Value='单频干扰'; tone.Value=2000; f1.Value=900; f2.Value=1100;
invoke_button(f,'步骤 1：生成含噪语音');
assert(abs(f1.Value-1900)<1e-12 && abs(f2.Value-2100)<1e-12, ...
    'Bandstop limits should automatically follow a single-tone interference frequency.');
status = require_tag(f,'statusLabel');
assert(contains(status.Text,'含噪语音已生成'), 'Noise stage did not complete.');

invoke_button(f,'步骤 2：应用滤波器');
assert(contains(status.Text,'滤波完成'), 'Filter stage did not complete.');
metric = require_tag(f,'filterMetricLabel');
assert(isnumeric(metric.UserData) && isscalar(metric.UserData) && metric.UserData > 10, ...
    'A 2000 Hz bandstop teaching example should attenuate the target tone by more than 10 dB.');
end

function h = require_tag(f,tagValue)
h=findall(f,'Tag',tagValue);
assert(numel(h)==1,'Could not uniquely find UI component Tag=%s',tagValue);
end

function invoke_button(f,textValue)
b=findall(f,'Type','uibutton','Text',textValue);
assert(numel(b)==1,'Could not uniquely find button: %s',textValue);
feval(b.ButtonPushedFcn,b,[]); drawnow;
end

function close_if_valid(f)
if ~isempty(f) && isvalid(f), close(f); drawnow; end
end
