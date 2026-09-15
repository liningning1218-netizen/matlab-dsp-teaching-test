function app = main()
%MAIN Start the Digital Signal Processing voice teaching platform.
root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(root, 'modules')));
addpath(fullfile(root, 'app'));
app = dsp_voice_teaching_app(root);
end
