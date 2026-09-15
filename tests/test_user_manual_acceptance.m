function test_user_manual_acceptance()
%TEST_USER_MANUAL_ACCEPTANCE Verify the classroom workflow documented in the v0.2 manual.
f = main();
cleanup = onCleanup(@()close_if_valid(f)); %#ok<NASGU>
drawnow;

assert(isvalid(f), 'Main teaching window was not created.');
assert(numel(findall(f,'Type','uitab')) == 4, 'The manual requires four teaching modules.');

% Manual module 1A: 900 Hz sampled at 1000 Hz -> about 100 Hz alias.
assert(numel(findall(f,'Type','uibutton','Text','一键自检')) == 1, 'The revised build must expose a real one-click self-test.');
f0 = require_tag(f,'samplingF0');
fsField = require_tag(f,'samplingFs');
dur = require_tag(f,'samplingDuration');
info = require_tag(f,'samplingInfo');
assert(abs(dur.Value-0.02) < 1e-12, 'Manual quick-start default observation duration must be 0.02 s.');
f0.Value = 900; fsField.Value = 1000; dur.Value = 0.02;
invoke_button(f,'运行正弦采样实验');
text1 = join_text(info.Value);
assert(contains(text1,'欠采样'), '900/1000 experiment must be identified as undersampling.');
assert(contains(text1,'100.0 Hz'), '900/1000 experiment must report about 100 Hz alias/FFT result.');
assert(contains(text1,'理论与 FFT 一致'), 'Teaching result must explicitly compare theory and FFT.');

% Manual module 1A normal-sampling comparison: 900 Hz at 4000 Hz -> about 900 Hz.
fsField.Value = 4000;
invoke_button(f,'运行正弦采样实验');
text2 = join_text(info.Value);
assert(contains(text2,'正常采样'), '900/4000 experiment must be identified as normal sampling.');
assert(contains(text2,'900.0 Hz'), '900/4000 experiment must report about 900 Hz FFT peak.');

% Manual module 1B: direct decimation factor 4 turns 16 kHz into 4 kHz.
invoke_button(f,'恢复示例');
dec = require_tag(f,'speechDecimationFactor');
dec.Value = 4;
invoke_button(f,'对当前语音直接抽取');
status = require_tag(f,'statusLabel');
assert(contains(status.Text,'4000'), 'Decimation factor 4 must report a 4000 Hz new sampling rate.');

% Manual module 2: 2 s Fourier analysis updates time, FFT, and short-time spectrum.
fftSec = require_tag(f,'fftDuration');
fftSec.Value = 2;
invoke_button(f,'分析当前语音');
assert(~isempty(require_tag(f,'fftTimeAxes').Children), 'Time-domain plot was not updated.');
assert(~isempty(require_tag(f,'fftSpectrumAxes').Children), 'Single-sided spectrum was not updated.');
assert(~isempty(require_tag(f,'spectrogramAxes').Children), 'Short-time spectrum was not updated.');

% Manual module 3 default: 1000 Hz tone + 900-1100 Hz bandstop FIR.
assert(strcmp(require_tag(f,'noiseMode').Value,'单频干扰'), 'Default noise mode must match the manual.');
assert(abs(require_tag(f,'interferenceFrequency').Value-1000) < 1e-12, 'Default interference must be 1000 Hz.');
assert(strcmp(require_tag(f,'filterType').Value,'带阻'), 'Default filter must be bandstop.');
assert(abs(require_tag(f,'filterF1').Value-900) < 1e-12 && abs(require_tag(f,'filterF2').Value-1100) < 1e-12, 'Default bandstop must be 900-1100 Hz.');
invoke_button(f,'加噪并处理');
assert(contains(status.Text,'滤波处理完成'), 'Default filtering workflow did not complete.');
metricAx = require_tag(f,'filterMetricAxes');
barObj = findall(metricAx,'Type','bar');
assert(~isempty(barObj), 'Filtering workflow did not create before/after interference metric.');
vals = barObj(1).YData;
assert(numel(vals)>=2 && vals(2) < vals(1), '1000 Hz interference should be reduced after filtering.');

% Manual module 4: every documented traditional preset must run.
voiceDD = require_tag(f,'voiceEffect');
for v = {'升调','降调','机器人','明亮'}
    voiceDD.Value = v{1};
    invoke_button(f,'应用传统 DSP 变声');
    assert(contains(status.Text,'传统 DSP 变声完成'), ['Voice preset failed: ' v{1}]);
end

% Revised one-click self-test must actually execute, not merely show commands.
invoke_button(f,'一键自检');
assert(contains(status.Text,'自检通过'), 'One-click self-test did not report success.');
close_alerts_except(f);
end

function h = require_tag(f,tagValue)
h = findall(f,'Tag',tagValue);
assert(numel(h)==1,'Could not uniquely find UI component Tag=%s',tagValue);
end

function invoke_button(f,textValue)
b=findall(f,'Type','uibutton','Text',textValue);
assert(numel(b)==1,'Could not uniquely find button: %s',textValue);
feval(b.ButtonPushedFcn,b,[]); drawnow;
end

function s = join_text(v)
if ischar(v), s=v; elseif isstring(v), s=join(v,newline); else, s=string(v); s=join(s,newline); end
s=char(s);
end

function close_alerts_except(mainFig)
figs=findall(groot,'Type','figure');
for k=1:numel(figs)
    if ~isequal(figs(k),mainFig) && isvalid(figs(k)), close(figs(k)); end
end
drawnow;
end

function close_if_valid(f)
if ~isempty(f) && isvalid(f), close(f); drawnow; end
end
