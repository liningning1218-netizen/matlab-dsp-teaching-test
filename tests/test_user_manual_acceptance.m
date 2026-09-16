function test_user_manual_acceptance()
%TEST_USER_MANUAL_ACCEPTANCE Verify the documented classroom workflow.
f = main(); cleanup=onCleanup(@()close_if_valid(f)); %#ok<NASGU>
drawnow;
assert(isvalid(f)); assert(numel(findall(f,'Type','uitab'))==4); assert(numel(findall(f,'Type','uibutton','Text','一键自检'))==1);
f0=require_tag(f,'samplingF0'); fsField=require_tag(f,'samplingFs'); dur=require_tag(f,'samplingDuration'); info=require_tag(f,'samplingInfo');
assert(abs(dur.Value-0.02)<1e-12); f0.Value=900; fsField.Value=1000; dur.Value=0.02; invoke_button(f,'运行正弦采样实验'); text1=join_text(info.Value);
assert(contains(text1,'欠采样')); assert(contains(text1,'100.0 Hz')); assert(contains(text1,'理论与 FFT 一致'));
fsField.Value=4000; invoke_button(f,'运行正弦采样实验'); text2=join_text(info.Value); assert(contains(text2,'正常采样')); assert(contains(text2,'900.0 Hz'));
invoke_button(f,'恢复示例'); dec=require_tag(f,'speechDecimationFactor'); dec.Value=4; invoke_button(f,'执行语音降采样'); status=require_tag(f,'statusLabel'); assert(contains(status.Text,'4000'));
fftSec=require_tag(f,'fftDuration'); fftSec.Value=2; invoke_button(f,'分析当前语音'); assert(~isempty(require_tag(f,'fftTimeAxes').Children)); assert(~isempty(require_tag(f,'fftSpectrumAxes').Children)); assert(~isempty(require_tag(f,'spectrogramAxes').Children));
assert(strcmp(require_tag(f,'noiseMode').Value,'单频干扰')); assert(abs(require_tag(f,'interferenceFrequency').Value-1000)<1e-12); assert(strcmp(require_tag(f,'filterType').Value,'带阻'));
invoke_button(f,'步骤 1：生成含噪语音'); assert(contains(status.Text,'含噪语音已生成')); low=require_tag(f,'filterF1').Value; high=require_tag(f,'filterF2').Value; assert(low<1000 && high>1000,'Auto bandstop must bracket the teaching tone.');
invoke_button(f,'步骤 2：应用滤波器'); assert(contains(status.Text,'滤波完成')); metric=require_tag(f,'filterMetricLabel'); assert(isnumeric(metric.UserData)&&metric.UserData>10,'Default teaching tone should be clearly attenuated.');
voiceDD=require_tag(f,'voiceEffect'); for v={'升调','降调','机器人','明亮'}, voiceDD.Value=v{1}; invoke_button(f,'应用传统 DSP 变声'); assert(contains(status.Text,'传统 DSP 变声完成')); end
invoke_button(f,'一键自检'); assert(contains(status.Text,'自检通过')); close_alerts_except(f);
end
function h=require_tag(f,tagValue), h=findall(f,'Tag',tagValue); assert(numel(h)==1,'Could not uniquely find UI component Tag=%s',tagValue); end
function invoke_button(f,textValue), b=findall(f,'Type','uibutton','Text',textValue); assert(numel(b)==1,'Could not uniquely find button: %s',textValue); feval(b.ButtonPushedFcn,b,[]); drawnow; end
function s=join_text(v), if ischar(v),s=v;elseif isstring(v),s=join(v,newline);else,s=string(v);s=join(s,newline);end;s=char(s);end
function close_alerts_except(mainFig), figs=findall(groot,'Type','figure');for k=1:numel(figs),if ~isequal(figs(k),mainFig)&&isvalid(figs(k)),close(figs(k));end,end;drawnow;end
function close_if_valid(f),if ~isempty(f)&&isvalid(f),close(f);drawnow;end;end
