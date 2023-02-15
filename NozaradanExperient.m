% 画面の初期化
screens = Screen('Screens');
Screen('Preference','SkipSyncTests', 1);
Screen('Preference','TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
screenNumber = max(screens);
[window, rect] = Screen('OpenWindow', screenNumber);

% カウントダウンの準備
countdown_duration = 5; % [sec]
text = 'Get ready!';

% 音の準備
sound_files = {'audio1.wav', 'audio2.wav', 'audio3.wav'};

% ボタンの準備
button_text = 'Play next sound';

% 実験開始
for i = 1:length(sound_files)
    % 画面にカウントダウンのテキストを表示
    DrawFormattedText(window, text, 'center', 'center');
    Screen('Flip', window);
    WaitSecs(countdown_duration);
    
    % 音を再生
    [y, fs] = audioread(sound_files{i});
    sound = PsychPortAudio('Open', [], [], 0, fs, 1);
    PsychPortAudio('FillBuffer', sound, y');
    PsychPortAudio('Start', sound, 1, 0, 1);
    WaitSecs(length(y) / fs);
    PsychPortAudio('Close', sound);
    
    % ボタンを表示
    DrawFormattedText(window, button_text, 'center', 'center');
    Screen('Flip', window);
    
    % ボタンが押されるのを待つ
    % 実際のコードでは、ここにボタン押下のイベントのハンドリングコードを追加する必要があります
    WaitSecs(1);
end

% 画面を閉じる
Screen('CloseAll');
