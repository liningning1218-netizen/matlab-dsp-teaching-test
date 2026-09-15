function ok = run_all_tests()
%RUN_ALL_TESTS Numerical smoke tests for the DSP teaching platform.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root, 'modules')));
addpath(fullfile(root, 'tests'));
fprintf('Running DSP teaching platform tests...\n');
test_aliasing();
test_spectrum();
test_filtering();
test_voice_change();
fprintf('All DSP teaching platform tests passed.\n');
ok = true;
end
