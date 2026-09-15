function test_gui_workflow()
%TEST_GUI_WORKFLOW Exercise the main classroom buttons in a real uifigure.
f = main();
cleanup = onCleanup(@()close_if_valid(f)); %#ok<NASGU>
drawnow;
assert(isvalid(f), 'Main uifigure was not created.');
assert(numel(findall(f,'Type','uitab')) == 4, 'Expected four teaching tabs.');
invoke_button(f, '运行正弦采样实验');
invoke_button(f, '分析当前语音');
invoke_button(f, '加噪并处理');
assert(~isempty(findall(f,'Type','uilabel','Text','滤波处理完成，可试听前后结果')), 'Filtering callback did not reach the success state.');
invoke_button(f, '应用传统 DSP 变声');
assert(~isempty(findall(f,'Type','uilabel','Text','传统 DSP 变声完成')), 'Voice-change callback did not reach the success state.');
drawnow;
end

function invoke_button(f, textValue)
b = findall(f, 'Type', 'uibutton', 'Text', textValue);
assert(numel(b) == 1, 'Could not uniquely find button: %s', textValue);
feval(b.ButtonPushedFcn, b, []);
drawnow;
end

function close_if_valid(f)
if ~isempty(f) && isvalid(f)
    close(f);
    drawnow;
end
end
