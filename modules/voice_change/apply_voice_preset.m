function [y, description] = apply_voice_preset(x, fs, preset)
%APPLY_VOICE_PRESET Explainable non-AI teaching voice effects.
preset = lower(char(string(preset)));
switch preset
    case {'higher','升调'}
        y = change_pitch_speed(x, 1.25);
        description = '升调：通过时间轴压缩使播放速度与音调同时升高；不是独立音高变换，也不是声线克隆。';
    case {'lower','降调'}
        y = change_pitch_speed(x, 0.80);
        description = '降调：通过时间轴拉伸使播放速度与音调同时降低；不是独立音高变换，也不是声线克隆。';
    case {'robot','机器人'}
        y = robot_voice(x, fs, 35);
        description = '机器人声：采用约 35 Hz 环形调制，在频域产生平移后的边带，便于解释调制与频谱变化。';
    case {'bright','明亮'}
        y = enhance_speech(x, fs, 0.75);
        description = '明亮效果：采用宽语音频段 FIR 进行温和频谱整形，属于音色调整，不是 AI 声线转换。';
    otherwise
        error('apply_voice_preset:UnknownPreset', '未知变声预设: %s', preset);
end
y = normalize_audio(y, 0.98);
end
