%********************************************************************
% Nozaradan2011analyze.m
% author: Keigo Yoshida@keio University SFC
% created: November-28-2022
% explanation:
% This is a Matlab M file to analyze EEG depends on the paper.
% See: Nozaradan, S., Peretz, I., Missal, M., & Mouraux, A. (2011). 
% Tagging the neuronal entrainment to beat and meter. 
% The Journal of Neuroscience 31(28), 10234–10240.
%******************************************************************
%表示されると嬉しいfigure
%FFTの結果
%平均周波数スペクトル
%ウィスカープロットの中央値と四分位範囲
%聴覚イベント関連電位の時間スペクトル
%******************************************************************


%step1:
%独立成分分析（ICA）を用いて、目の瞬きや眼球運動によって生じるアーチファクトを除去する
%データを用意
%matlabにStastical toolboxが入っていることを確認
fs = 1000;
X1 = readtable('VieRawData.csv','ReadVariableNames', false);%or true if there is a header
data = table2array(X1(:,2:3));
[icasig, A, W] = fastica(data);
%data: 脳波データを表す行列、
%icasig: ICAによって抽出された独立成分を表す行列
%A: 独立成分を元の信号に戻すための行列
%W: 独立成分を抽出するための行列

%独立成分を用いて信号を再構成
reconstructed_data = A * icasig;

%******************************************************************

%step2:
%時間領域で平均化、S/N比を高める
% 脳波データをエポックごとに分割する
epoch_length = 500; % エポック長 (ms)
num_epochs = length(reconstructed_data) / epoch_length;
epochs = reshape(reconstructed_data, [epoch_length, num_epochs]);

% 各エポックを平均化
mean_waveform = mean(epochs, 2);

%******************************************************************

%step3:
% 離散フーリエ変換を実行
fft_result = fft(mean_waveform);

% 周波数分解能を計算
sampling_rate = 1000; % サンプリングレート (Hz)
freq_resolution = 1 / length(mean_waveform) * sampling_rate; % 周波数分解能 (Hz)

% 周波数スペクトルを計算
freq = (0:length(mean_waveform)-1) * freq_resolution; % 周波数軸 (Hz)
amplitude = abs(fft_result) / length(mean_waveform); % 振幅 (V)

% 0〜500Hzの範囲を選択
idx = freq >= 0 & freq <= 500;
freq = freq(idx);
amplitude = amplitude(idx);

% 周波数分解能を0.031Hzにする
freq_resolution = 0.031;
num_bins = 500 / freq_resolution;

% 周波数スペクトルをビンに分割
[binned_freq, ~] = bin_data(freq, amplitude, num_bins);

% 周波数スペクトルから、隣接する周波数ビンで測定した平均振幅を求める
num_bins = length(freq);
neighbor_amplitude = zeros(num_bins, 1);
for i = 1:num_bins
    if i == 1
        neighbor_amplitude(i) = (amplitude(i) + amplitude(i+1)) / 2;
    elseif i == num_bins
        neighbor_amplitude(i) = (amplitude(i) + amplitude(i-1)) / 2;
    else
        neighbor_amplitude(i) = (amplitude(i-1) + amplitude(i) + amplitude(i+1)) / 3;
    end
end

%******************************************************************

%step4:
% 周波数スペクトルから隣接する周波数ビンによる寄与を除去する
amplitude = amplitude - neighbor_amplitude;

%各定常EPの目標周波数を中心とする3つの周波数ビンで測定した信号振幅を平均する

% 目標周波数を中心とする3つの周波数ビンで信号振幅を平均する
target_freq = 2.4; % 目標周波数 (Hz)
bin_width = 0.4; % 周波数ビンの幅 (Hz)

% 目標周波数を中心とする3つの周波数ビンを抽出する
mask = (freq >= target_freq - bin_width/2) & (freq < target_freq + bin_width/2);
binned_amplitude = mean(amplitude(mask));

%******************************************************************

%step5:
% 中央値と四分位範囲を計算する
median_amplitude = median(amplitude);
iqr_amplitude = iqr(amplitude);

% 1標本のt検定を実行する
[h, p, ci, ~] = ttest(amplitude, 0);

% 結果を表示する
fprintf('中央値: %f\n', median_amplitude);
fprintf('四分位範囲: %f\n', iqr_amplitude);
if h == 1
    fprintf('有意差があります (p = %f)\n',p);
else
    fprintf('有意差がありません (p = %f)\n',p);
end

%******************************************************************
%ここからはまだ
% %step6:
% % コントロール、二元メーター、三元メーター条件で得られたノイズ減算振幅を読み込む
% control_amplitude = load('control_amplitude.mat');
% binary_amplitude = load('binary_amplitude.mat');
% ternary_amplitude = load('ternary_amplitude.mat');
% 
% % 一元配置反復測定ANOVAを実行する
% [p, tbl, stats] = anova1([control_amplitude, binary_amplitude, ternary_amplitude], ...
%     {'Control', 'Binary', 'Ternary'}, 'off', 'Greenhouse-Geisser');
% 
% % サイズ効果を表示する
% fprintf('サイズ効果: %f\n', partial_eta2(stats));
% 
% % 有意な場合にはpaired-sampling t検定を実行する
% if p < 0.05
%     fprintf('有意差があります (p = %f)\n', p);
%     % 各組を1対1で比較する
%     comparisons = multcompare(stats, 'Alpha', 0.05, 'CType', 'bonferroni');
%     % 結果を表示する
%     disp(comparisons);
% else
%     fprintf('有意差がありません (p = %f)\n', p);
% end
% 
% %バンドパスフィルタリングを実行し、音刺激の開始から1秒から33秒までのエピクロス分割の後に平均波形を計算する
% % 原点波形を読み込む
% raw_waveform = load('raw_waveform.mat');
% 
% % フィルターを設定する
% Wn = [0.3 30] / (Fs/2); % ナイキスト周波数を正規化する
% [b, a] = butter(4, Wn, 'bandpass'); % バンドパスフィルターを作成する
% 
% % フィルターを適用する
% filtered_waveform = filtfilt(b, a, raw_waveform);
% 
% % 音刺激の開始から1秒から33秒までのエピクロス分割を計算する
% epoch_start = Fs + 1; % 1秒後から
% epoch_end = Fs * 33; % 33秒後まで
% epoch_length = epoch_end - epoch_start + 1; % エピクロス長
% num_epochs = length(raw_waveform) / epoch_length; % エピクロス数
% 
% % 平均波形を計算する
% mean_waveform = zeros(epoch_length, 1);
% for i = 1:num_epochs
%     start_index = (i-1) * epoch_length + epoch_start;
%     end_index = start_index + epoch_length - 1;
%     epoch = filtered_waveform(start_index:end_index);
%     mean_waveform = mean_waveform + epoch;
% end
% mean_waveform = mean_waveform / num_epochs;
% 
% % 結果をプロットする
% plot(mean_waveform);
% 
% 
