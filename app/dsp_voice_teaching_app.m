function fig = dsp_voice_teaching_app(projectRoot)
%DSP_VOICE_TEACHING_APP Programmatic GUI for classroom DSP demonstrations.
if nargin < 1 || isempty(projectRoot)
    projectRoot = fileparts(fileparts(mfilename('fullpath')));
end
addpath(genpath(fullfile(projectRoot, 'modules')));
demoFile = fullfile(projectRoot, 'audio', 'demo_speech_like.wav');
if exist(demoFile, 'file')
    [x0, fs0] = audioread(demoFile);
else
    [x0, fs0] = generate_demo_audio(demoFile);
end
audio = make_audio_struct(x0, fs0, '内置教学示例（非真实语音）');
noisyAudio = []; filteredAudio = []; voiceAudio = []; player = [];
fig = uifigure('Name', '数字信号处理——语音信号教学演示平台', 'Position', [80 50 1380 850]);
rootGrid = uigridlayout(fig, [2 1]); rootGrid.RowHeight = {84, '1x'}; rootGrid.Padding = [10 10 10 10];
commonBar = uigridlayout(rootGrid, [2 7]); commonBar.Layout.Row = 1; commonBar.RowHeight = {32, 28}; commonBar.ColumnWidth = {105,105,110,95,105,100,'1x'};
uibutton(commonBar,'Text','导入音频','ButtonPushedFcn',@onImport);
uibutton(commonBar,'Text','录制 3 秒','ButtonPushedFcn',@onRecord);
uibutton(commonBar,'Text','播放原音','ButtonPushedFcn',@(~,~)playSignal(audio.x,audio.fs));
uibutton(commonBar,'Text','停止声音','ButtonPushedFcn',@onStopSound);
uibutton(commonBar,'Text','恢复示例','ButtonPushedFcn',@onResetDemo);
uibutton(commonBar,'Text','一键自检','Tag','selfTestButton','ButtonPushedFcn',@onRunSelfTest);
infoLabel=uilabel(commonBar,'Text','','FontWeight','bold','Tag','audioInfoLabel'); infoLabel.Layout.Row=1; infoLabel.Layout.Column=7;
helpLabel=uilabel(commonBar,'Text','课堂顺序：采样与混叠 → 傅里叶变换 → 加噪与滤波 → 传统变声'); helpLabel.Layout.Row=2; helpLabel.Layout.Column=[1 6];
statusLabel=uilabel(commonBar,'Text','就绪','HorizontalAlignment','right','Tag','statusLabel'); statusLabel.Layout.Row=2; statusLabel.Layout.Column=7;
tg=uitabgroup(rootGrid); tg.Layout.Row=2;
tabSampling=uitab(tg,'Title','1  信号采样与混叠'); tabFFT=uitab(tg,'Title','2  傅里叶变换'); tabFilter=uitab(tg,'Title','3  滤波与音质处理'); tabVoice=uitab(tg,'Title','4  频谱/传统变声');
sg=uigridlayout(tabSampling,[2 3]); sg.ColumnWidth={265,'1x','1x'}; sg.RowHeight={'1x','1x'};
sp=uipanel(sg,'Title','课堂实验'); sp.Layout.Row=[1 2]; sp.Layout.Column=1;
spg=uigridlayout(sp,[18 2]); spg.RowHeight=repmat({28},1,18); spg.ColumnWidth={115,'1x'};
sectionA=uilabel(spg,'Text','实验 A：正弦采样与混叠','FontWeight','bold'); sectionA.Layout.Row=1; sectionA.Layout.Column=[1 2];
lab=uilabel(spg,'Text','教学正弦频率/Hz'); lab.Layout.Row=2; lab.Layout.Column=1; sf0=uieditfield(spg,'numeric','Value',900,'Limits',[1 Inf],'Tag','samplingF0'); sf0.Layout.Row=2; sf0.Layout.Column=2;
lab=uilabel(spg,'Text','采样率/Hz'); lab.Layout.Row=3; lab.Layout.Column=1; sfs=uieditfield(spg,'numeric','Value',1000,'Limits',[1 Inf],'Tag','samplingFs'); sfs.Layout.Row=3; sfs.Layout.Column=2;
lab=uilabel(spg,'Text','观察时长/s'); lab.Layout.Row=4; lab.Layout.Column=1; sdur=uieditfield(spg,'numeric','Value',0.02,'Limits',[0.005 2],'Tag','samplingDuration'); sdur.Layout.Row=4; sdur.Layout.Column=2;
runSine=uibutton(spg,'Text','运行正弦采样实验','ButtonPushedFcn',@onSamplingDemo); runSine.Layout.Row=5; runSine.Layout.Column=[1 2];
sectionB=uilabel(spg,'Text','实验 B：真实语音直接抽取','FontWeight','bold'); sectionB.Layout.Row=6; sectionB.Layout.Column=[1 2];
lab=uilabel(spg,'Text','直接抽取因子'); lab.Layout.Row=7; lab.Layout.Column=1; sdec=uieditfield(spg,'numeric','Value',4,'RoundFractionalValues','on','Limits',[1 20],'Tag','speechDecimationFactor'); sdec.Layout.Row=7; sdec.Layout.Column=2;
runDec=uibutton(spg,'Text','对当前语音直接抽取','ButtonPushedFcn',@onSpeechDecimate); runDec.Layout.Row=8; runDec.Layout.Column=[1 2];
playDec=uibutton(spg,'Text','播放抽取后语音','ButtonPushedFcn',@onPlayProcessed); playDec.Layout.Row=9; playDec.Layout.Column=[1 2];
sInfo=uitextarea(spg,'Editable','off','Tag','samplingInfo','Value',{'实验 A 用于验证奈奎斯特采样定理。';'实验 B 故意不加抗混叠滤波，用于听辨直接降采样的影响。'}); sInfo.Layout.Row=[10 18]; sInfo.Layout.Column=[1 2];
axSample=uiaxes(sg,'Tag','samplingTimeAxes'); axSample.Layout.Row=1; axSample.Layout.Column=[2 3]; axSample.Title.String='采样点与表观混叠波形'; axSample.XLabel.String='时间 / s'; axSample.YLabel.String='幅值'; grid(axSample,'on');
axSampleSpec=uiaxes(sg,'Tag','samplingSpectrumAxes'); axSampleSpec.Layout.Row=2; axSampleSpec.Layout.Column=[2 3]; axSampleSpec.Title.String='采样序列的单边幅度谱'; axSampleSpec.XLabel.String='频率 / Hz'; axSampleSpec.YLabel.String='幅值'; grid(axSampleSpec,'on');
fg=uigridlayout(tabFFT,[2 3]); fg.ColumnWidth={220,'1x','1x'}; fg.RowHeight={'1x','1x'}; fp=uipanel(fg,'Title','分析设置'); fp.Layout.Row=[1 2]; fp.Layout.Column=1;
fpg=uigridlayout(fp,[10 2]); fpg.RowHeight=repmat({30},1,10); fpg.ColumnWidth={90,'1x'}; uilabel(fpg,'Text','分析时长/s'); fsec=uieditfield(fpg,'numeric','Value',2,'Limits',[0.05 Inf],'Tag','fftDuration');
runFFT=uibutton(fpg,'Text','分析当前语音','ButtonPushedFcn',@onFourier); runFFT.Layout.Column=[1 2]; fTip=uitextarea(fpg,'Editable','off','Value',{'上图看时间变化；右上看整体频率成分；下图看频率成分随时间变化。';'语谱图由程序自行分帧 FFT，不依赖 spectrogram 工具箱函数。'}); fTip.Layout.Row=[4 10]; fTip.Layout.Column=[1 2];
axTime=uiaxes(fg,'Tag','fftTimeAxes'); axTime.Layout.Row=1; axTime.Layout.Column=2; axTime.Title.String='时域波形'; axTime.XLabel.String='时间 / s'; grid(axTime,'on');
axFFT=uiaxes(fg,'Tag','fftSpectrumAxes'); axFFT.Layout.Row=1; axFFT.Layout.Column=3; axFFT.Title.String='单边幅度谱'; axFFT.XLabel.String='频率 / Hz'; grid(axFFT,'on');
axSpecgram=uiaxes(fg,'Tag','spectrogramAxes'); axSpecgram.Layout.Row=2; axSpecgram.Layout.Column=[2 3]; axSpecgram.Title.String='短时频谱（语谱图）'; axSpecgram.XLabel.String='时间 / s'; axSpecgram.YLabel.String='频率 / Hz';
flg=uigridlayout(tabFilter,[2 4]); flg.ColumnWidth={255,'1x','1x','1x'}; flg.RowHeight={'1x','1x'}; flp=uipanel(flg,'Title','噪声与滤波参数'); flp.Layout.Row=[1 2]; flp.Layout.Column=1;
flpg=uigridlayout(flp,[16 2]); flpg.RowHeight=repmat({28},1,16); flpg.ColumnWidth={105,'1x'};
uilabel(flpg,'Text','加噪模式'); noiseDD=uidropdown(flpg,'Items',{'混合噪声','单频干扰','白噪声','无'},'Value','单频干扰','Tag','noiseMode');
uilabel(flpg,'Text','噪声强度'); noiseAmt=uieditfield(flpg,'numeric','Value',0.35,'Limits',[0 2],'Tag','noiseAmount'); uilabel(flpg,'Text','干扰频率/Hz'); toneField=uieditfield(flpg,'numeric','Value',1000,'Limits',[1 Inf],'Tag','interferenceFrequency');
uilabel(flpg,'Text','滤波器'); filterDD=uidropdown(flpg,'Items',{'带阻','低通','高通','带通','音质优化'},'Value','带阻','Tag','filterType'); uilabel(flpg,'Text','频率1/Hz'); ff1=uieditfield(flpg,'numeric','Value',900,'Limits',[1 Inf],'Tag','filterF1'); uilabel(flpg,'Text','频率2/Hz'); ff2=uieditfield(flpg,'numeric','Value',1100,'Limits',[1 Inf],'Tag','filterF2'); uilabel(flpg,'Text','FIR 阶数'); forder=uieditfield(flpg,'numeric','Value',200,'RoundFractionalValues','on','Limits',[20 800],'Tag','filterOrder');
runFilter=uibutton(flpg,'Text','加噪并处理','ButtonPushedFcn',@onFilter); runFilter.Layout.Column=[1 2]; playNoisy=uibutton(flpg,'Text','播放含噪语音','ButtonPushedFcn',@onPlayNoisy); playNoisy.Layout.Column=[1 2]; playFiltered=uibutton(flpg,'Text','播放处理后','ButtonPushedFcn',@onPlayFiltered); playFiltered.Layout.Column=[1 2];
filterTip=uitextarea(flpg,'Editable','off','Value',{'建议课堂先用 1000 Hz 单频干扰 + 900–1100 Hz 带阻。';'这样频谱变化最清楚。音质优化是宽频段谱形调整，不等同于去噪。'}); filterTip.Layout.Row=[12 16]; filterTip.Layout.Column=[1 2];
axFilterTime=uiaxes(flg); axFilterTime.Layout.Row=1; axFilterTime.Layout.Column=[2 3]; axFilterTime.Title.String='处理前后时域对比'; axFilterTime.XLabel.String='时间 / s'; grid(axFilterTime,'on'); axResponse=uiaxes(flg); axResponse.Layout.Row=1; axResponse.Layout.Column=4; axResponse.Title.String='滤波器幅频响应'; axResponse.XLabel.String='频率 / Hz'; axResponse.YLabel.String='dB'; grid(axResponse,'on'); axBeforeSpec=uiaxes(flg); axBeforeSpec.Layout.Row=2; axBeforeSpec.Layout.Column=[2 3]; axBeforeSpec.Title.String='含噪与处理后频谱'; axBeforeSpec.XLabel.String='频率 / Hz'; grid(axBeforeSpec,'on'); axMetric=uiaxes(flg,'Tag','filterMetricAxes'); axMetric.Layout.Row=2; axMetric.Layout.Column=4; axMetric.Title.String='干扰频点处理前后'; axMetric.YLabel.String='幅值'; grid(axMetric,'on');
vg=uigridlayout(tabVoice,[2 3]); vg.ColumnWidth={255,'1x','1x'}; vg.RowHeight={'1x','1x'}; vp=uipanel(vg,'Title','变声设置'); vp.Layout.Row=[1 2]; vp.Layout.Column=1; vpg=uigridlayout(vp,[13 2]); vpg.RowHeight=repmat({30},1,13); vpg.ColumnWidth={90,'1x'};
uilabel(vpg,'Text','效果'); voiceDD=uidropdown(vpg,'Items',{'升调','降调','机器人','明亮'},'Value','升调','Tag','voiceEffect'); runVoice=uibutton(vpg,'Text','应用传统 DSP 变声','ButtonPushedFcn',@onVoice); runVoice.Layout.Column=[1 2]; playVoice=uibutton(vpg,'Text','播放变声结果','ButtonPushedFcn',@onPlayVoice); playVoice.Layout.Column=[1 2]; voiceDesc=uitextarea(vpg,'Editable','off','Value',{'第一版不把传统 DSP 变声称为“AI 声线转换”。'}); voiceDesc.Layout.Row=[5 11]; voiceDesc.Layout.Column=[1 2]; aiNote=uilabel(vpg,'Text','AI 声线克隆：高级扩展，暂不作为主体依赖','WordWrap','on'); aiNote.Layout.Row=[12 13]; aiNote.Layout.Column=[1 2];
axVoiceTime=uiaxes(vg); axVoiceTime.Layout.Row=1; axVoiceTime.Layout.Column=[2 3]; axVoiceTime.Title.String='变声前后时域'; axVoiceTime.XLabel.String='时间 / s'; grid(axVoiceTime,'on'); axVoiceBefore=uiaxes(vg); axVoiceBefore.Layout.Row=2; axVoiceBefore.Layout.Column=2; axVoiceBefore.Title.String='变声前频谱'; axVoiceBefore.XLabel.String='频率 / Hz'; grid(axVoiceBefore,'on'); axVoiceAfter=uiaxes(vg); axVoiceAfter.Layout.Row=2; axVoiceAfter.Layout.Column=3; axVoiceAfter.Title.String='变声后频谱'; axVoiceAfter.XLabel.String='频率 / Hz'; grid(axVoiceAfter,'on');
updateAudioInfo(); onSamplingDemo([],[]); onFourier([],[]);
    function onImport(~,~)
        [file,path]=uigetfile({'*.wav;*.mp3;*.m4a','音频文件 (*.wav, *.mp3, *.m4a)';'*.*','所有文件'}); if isequal(file,0), return; end
        try, [x,fs]=audioread(fullfile(path,file)); audio=make_audio_struct(x,fs,file); clearDerived(); updateAudioInfo(); onFourier([],[]); setStatus('已导入音频'); catch ME, showError(ME); end
    end
    function onRecord(~,~)
        try, setStatus('正在录音 3 秒...'); drawnow; rec=audiorecorder(16000,16,1); recordblocking(rec,3); x=getaudiodata(rec,'double'); audio=make_audio_struct(x,16000,'现场录音'); clearDerived(); updateAudioInfo(); onFourier([],[]); setStatus('录音完成'); catch ME, showError(ME); end
    end
    function onResetDemo(~,~), [x,fs]=audioread(demoFile); audio=make_audio_struct(x,fs,'内置教学示例（非真实语音）'); clearDerived(); updateAudioInfo(); onFourier([],[]); setStatus('已恢复内置示例'); end
    function onRunSelfTest(~,~)
        setStatus('正在运行核心算法自检...'); drawnow;
        try
            addpath(fullfile(projectRoot,'tests'));
            ok=run_all_tests();
            if ~ok, error('自检脚本返回失败状态。'); end
            setStatus('自检通过：核心数值算法全部通过');
            uialert(fig,{'核心数值算法自检全部通过。';'采样混叠、FFT、FIR 滤波和传统变声测试均通过。';'课堂 GUI 完整流程由随包验收脚本 test_user_manual_acceptance.m 验证。'},'自检通过','Icon','info');
        catch ME
            setStatus('自检失败');
            uialert(fig,sprintf('自检未通过：\n%s',ME.message),'自检失败','Icon','error');
        end
    end
    function onSamplingDemo(~,~)
        try
            d=sine_sampling_demo(sf0.Value,sfs.Value,sdur.Value);
            cla(axSample); hold(axSample,'on');
            plot(axSample,d.tRef,d.xRef,'LineWidth',1.0,'DisplayName','原始连续参考');
            plot(axSample,d.tRef,d.xApparent,'--','LineWidth',1.2,'DisplayName',sprintf('采样后表观 %.1f Hz',d.aliasHz));
            stem(axSample,d.tSample,d.xSample,'filled','DisplayName','离散采样点');
            hold(axSample,'off'); legend(axSample,'Location','best');
            [f,m]=one_sided_spectrum(d.xSample,d.fs); plot(axSampleSpec,f,m,'LineWidth',1.2); xlim(axSampleSpec,[0 d.fs/2]);
            if numel(m)>1, [~,ii]=max(m(2:end)); ii=ii+1; else, ii=1; end
            fftPeak=f(ii); resolution=d.fs/max(numel(d.xSample),1); consistent=abs(fftPeak-d.aliasHz)<=max(1,1.1*resolution);
            if d.isUndersampled, verdict='实验结论：欠采样，发生频谱混叠'; state='欠采样'; else, verdict='实验结论：正常采样，满足奈奎斯特条件'; state='正常采样'; end
            if consistent, check='验证结果：理论与 FFT 一致'; else, check='验证结果：理论与 FFT 存在分辨率误差'; end
            sInfo.Value={verdict; sprintf('原始正弦频率：%.1f Hz',d.f0); sprintf('采样率：%.1f Hz',d.fs); sprintf('奈奎斯特频率：%.1f Hz',d.nyquist); sprintf('理论表观频率：%.1f Hz',d.aliasHz); sprintf('FFT 检测峰值：%.1f Hz',fftPeak); check; '实验 B 的直接抽取同样故意不使用抗混叠滤波。'};
            setStatus(sprintf('采样实验完成：%s，FFT 峰值 %.1f Hz',state,fftPeak));
        catch ME, showError(ME); end
    end
    function onSpeechDecimate(~,~)
        try
            factor=max(1,round(sdec.Value)); [y,fsNew]=naive_decimate_audio(audio.x,audio.fs,factor);
            audio.processed=normalize_audio(y); audio.processedFs=fsNew; audio.processedName='直接抽取结果';
            [f0,m0]=one_sided_spectrum(audio.x,audio.fs); [f1,m1]=one_sided_spectrum(y,fsNew);
            cla(axSampleSpec); hold(axSampleSpec,'on'); plot(axSampleSpec,f0,m0,'DisplayName','原始'); plot(axSampleSpec,f1,m1,'DisplayName','直接抽取后'); hold(axSampleSpec,'off'); legend(axSampleSpec,'Location','best'); xlim(axSampleSpec,[0 min(audio.fs,fsNew)/2]);
            sInfo.Value={'实验 B：真实语音直接抽取'; sprintf('原采样率：%.1f Hz',audio.fs); sprintf('抽取因子：%d',factor); sprintf('抽取后采样率：%.1f Hz',fsNew); sprintf('新奈奎斯特频率：%.1f Hz',fsNew/2); '本实验故意不做抗混叠滤波，用于观察直接降采样造成的频谱折叠与听感变化。'; '工程应用中的正规降采样应先进行抗混叠低通滤波。'};
            setStatus(sprintf('直接抽取完成：%.0f Hz → %.0f Hz（因子 %d）',audio.fs,fsNew,factor));
        catch ME, showError(ME); end
    end
    function onPlayProcessed(~,~), if isempty(audio.processed), uialert(fig,'请先运行“对当前语音直接抽取”。','尚无结果'); return; end; playSignal(audio.processed,audio.processedFs); end
    function onFourier(~,~)
        try
            N=min(numel(audio.x),max(16,round(fsec.Value*audio.fs))); x=audio.x(1:N); t=(0:N-1)'/audio.fs;
            plot(axTime,t,x); xlim(axTime,[t(1) max(t(end),1/audio.fs)]);
            [f,m]=one_sided_spectrum(x,audio.fs); plot(axFFT,f,m); xlim(axFFT,[0 audio.fs/2]);
            if numel(m)>1, [~,ii]=max(m(2:end)); ii=ii+1; dominant=f(ii); else, dominant=0; end
            [S,ff,tt]=frame_spectrogram(x,audio.fs,30,0.75); imagesc(axSpecgram,tt,ff,20*log10(S+eps)); axis(axSpecgram,'xy'); ylim(axSpecgram,[0 min(5000,audio.fs/2)]); colorbar(axSpecgram);
            fTip.Value={sprintf('当前分析：%s，%.2f s',audio.name,N/audio.fs); sprintf('整体单边谱最强非直流频率约 %.1f Hz',dominant); '时域波形：看振幅随时间变化。'; '单边幅度谱：看整个分析时段的总体频率组成。'; '短时频谱：看不同频率何时出现，由程序自行分帧 FFT 计算。'};
            setStatus('FFT 分析完成：时域、单边谱和短时频谱已更新');
        catch ME, showError(ME); end
    end
    function onFilter(~,~)
        try, tone=min(toneField.Value,0.49*audio.fs); mode=mapNoise(noiseDD.Value); [noisyAudio,~]=add_demo_noise(audio.x,audio.fs,mode,noiseAmt.Value,tone); type=mapFilter(filterDD.Value); if strcmp(type,'enhance'), [filteredAudio,b]=enhance_speech(noisyAudio,audio.fs,0.70); else, f1v=min(ff1.Value,0.48*audio.fs); f2v=min(ff2.Value,0.49*audio.fs); if any(strcmp(type,{'bandpass','bandstop'})) && f2v<=f1v, error('第二个频率必须大于第一个频率，并且低于奈奎斯特频率。'); end; b=design_fir_filter(type,audio.fs,round(forder.Value),f1v,f2v); filteredAudio=normalize_audio(apply_fir_filter(noisyAudio,b),0.98); end; showFilterPlots(noisyAudio,filteredAudio,b,tone); setStatus('滤波处理完成，可试听前后结果'); catch ME, showError(ME); end
    end
    function showFilterPlots(xn,y,b,tone)
        nshow=min(numel(xn),round(0.08*audio.fs)); tt=(0:nshow-1)'/audio.fs; cla(axFilterTime); hold(axFilterTime,'on'); plot(axFilterTime,tt,xn(1:nshow),'DisplayName','含噪'); plot(axFilterTime,tt,y(1:nshow),'DisplayName','处理后'); hold(axFilterTime,'off'); legend(axFilterTime,'Location','best'); [f0,m0]=one_sided_spectrum(xn,audio.fs); [f1,m1]=one_sided_spectrum(y,audio.fs); cla(axBeforeSpec); hold(axBeforeSpec,'on'); plot(axBeforeSpec,f0,m0,'DisplayName','含噪'); plot(axBeforeSpec,f1,m1,'DisplayName','处理后'); hold(axBeforeSpec,'off'); legend(axBeforeSpec,'Location','best'); xlim(axBeforeSpec,[0 min(5000,audio.fs/2)]); [fr,H]=filter_response(b,audio.fs,4096); plot(axResponse,fr,20*log10(abs(H)+1e-8)); xlim(axResponse,[0 audio.fs/2]); ylim(axResponse,[-90 10]); [~,i0]=min(abs(f0-tone)); [~,i1]=min(abs(f1-tone)); vals=[m0(i0),m1(i1)]; bar(axMetric,[1 2],vals); axMetric.XTick=[1 2]; axMetric.XTickLabel={'处理前','处理后'}; axMetric.Title.String=sprintf('%.0f Hz 干扰频点',tone);
    end
    function onPlayNoisy(~,~), if isempty(noisyAudio), uialert(fig,'请先执行加噪与滤波。','尚无结果'); return; end; playSignal(noisyAudio,audio.fs); end
    function onPlayFiltered(~,~), if isempty(filteredAudio), uialert(fig,'请先执行加噪与滤波。','尚无结果'); return; end; playSignal(filteredAudio,audio.fs); end
    function onVoice(~,~)
        try, [voiceAudio,desc]=apply_voice_preset(audio.x,audio.fs,voiceDD.Value); voiceDesc.Value={desc;'';'提示：真正的 AI 声线转换需要独立模型与训练/推理环境，本程序第一版不依赖它。'}; n0=min(numel(audio.x),round(0.10*audio.fs)); n1=min(numel(voiceAudio),round(0.10*audio.fs)); cla(axVoiceTime); hold(axVoiceTime,'on'); plot(axVoiceTime,(0:n0-1)'/audio.fs,audio.x(1:n0),'DisplayName','原始'); plot(axVoiceTime,(0:n1-1)'/audio.fs,voiceAudio(1:n1),'DisplayName','变声后'); hold(axVoiceTime,'off'); legend(axVoiceTime,'Location','best'); [f0,m0]=one_sided_spectrum(audio.x,audio.fs); [f1,m1]=one_sided_spectrum(voiceAudio,audio.fs); plot(axVoiceBefore,f0,m0); xlim(axVoiceBefore,[0 min(5000,audio.fs/2)]); plot(axVoiceAfter,f1,m1); xlim(axVoiceAfter,[0 min(5000,audio.fs/2)]); setStatus('传统 DSP 变声完成'); catch ME, showError(ME); end
    end
    function onPlayVoice(~,~), if isempty(voiceAudio), uialert(fig,'请先应用一种变声效果。','尚无结果'); return; end; playSignal(voiceAudio,audio.fs); end
    function updateAudioInfo(), infoLabel.Text=sprintf('%s | %.0f Hz | %.2f s',audio.name,audio.fs,numel(audio.x)/audio.fs); end
    function clearDerived(), audio.processed=[]; audio.processedName=''; noisyAudio=[]; filteredAudio=[]; voiceAudio=[]; end
    function playSignal(x,fs), onStopSound([],[]); player=audioplayer(normalize_audio(x),fs); play(player); end
    function onStopSound(~,~), if ~isempty(player), try, stop(player); catch, end; end; end
    function setStatus(txt), statusLabel.Text=txt; drawnow limitrate; end
    function showError(ME), setStatus('操作失败'); uialert(fig,ME.message,'操作失败','Icon','error'); end
    function out=mapNoise(v), switch v, case '混合噪声', out='mixed'; case '单频干扰', out='tone'; case '白噪声', out='white'; otherwise, out='none'; end; end
    function out=mapFilter(v), switch v, case '带阻', out='bandstop'; case '低通', out='lowpass'; case '高通', out='highpass'; case '带通', out='bandpass'; otherwise, out='enhance'; end; end
end
