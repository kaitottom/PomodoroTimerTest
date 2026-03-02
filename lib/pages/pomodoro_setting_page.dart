import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pomodoro_settings_provider.dart';
import '../providers/timer_provider.dart';
//import '../models/pomodoro_settings.dart';
import '../widgets/setting_card.dart';
import '../widgets/time_setting_card.dart';

class PomodoroSettingPage extends ConsumerWidget {
  const PomodoroSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final settingsNotifier = ref.read(pomodoroSettingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // スマホ向け（現状の縦並び）
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'ポモドーロ設定',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.topCenter, // 中央上にピンを置く基準
                        children: [
                          Container(
                            // ピンの分、少しだけ上にマージンを持たせると収まりが良い
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade100,
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                SizedBox(height: 8), // ピンと重ならないための余白
                                Text(
                                  '自身にとって最適な時間とサイクルを見つけましょう',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TimeSettingCard(
                        title: '集中時間\n上限100分',
                        minutes: settings.focusMinutes,
                        seconds: settings.focusSeconds,
                        maxMinutes: 100,
                        maxSeconds: 59,
                        onMinutesChanged: (minutes) {
                          settingsNotifier.updateFocusMinutes(minutes);
                        },
                        onSecondsChanged: (seconds) {
                          settingsNotifier.updateFocusSeconds(seconds);
                        },
                      ),
                      const SizedBox(height: 8),
                      TimeSettingCard(
                        title: '休憩時間\n上限30分',
                        minutes: settings.breakMinutes,
                        seconds: settings.breakSeconds,
                        maxMinutes: 30,
                        maxSeconds: 59,
                        onMinutesChanged: (minutes) {
                          settingsNotifier.updateBreakMinutes(minutes);
                        },
                        onSecondsChanged: (seconds) {
                          settingsNotifier.updateBreakSeconds(seconds);
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingCard(
                        title: 'サイクル数\n上限10サイクル',
                        value: settings.cycles,
                        onIncrement: () {
                          if (settings.cycles < 10) {
                            settingsNotifier.updateCycles(settings.cycles + 1);
                          }
                        },
                        onDecrement: () {
                          if (settings.cycles > 1) {
                            settingsNotifier.updateCycles(settings.cycles - 1);
                          }
                        },
                        onChanged: (value) {
                          final cycles = int.tryParse(value) ?? 4;
                          if (cycles >= 1 && cycles <= 10) {
                            settingsNotifier.updateCycles(cycles);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final timerNotifier = ref.read(
                            timerInfoProvider.notifier,
                          );
                          timerNotifier.startTimer(settings);
                          context.push('/Timer');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'タイマー開始',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else {
              // タブレット・PC向け（SettingCardを横並び）
              return Center(
                child: SizedBox(
                  width: 800,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            'ポモドーロ設定',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TimeSettingCard(
                                      title: '集中時間\n上限100分',
                                      minutes: settings.focusMinutes,
                                      seconds: settings.focusSeconds,
                                      maxMinutes: 100,
                                      maxSeconds: 59,
                                      onMinutesChanged: (minutes) {
                                        settingsNotifier.updateFocusMinutes(minutes);
                                      },
                                      onSecondsChanged: (seconds) {
                                        settingsNotifier.updateFocusSeconds(seconds);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: TimeSettingCard(
                                      title: '休憩時間\n上限30分',
                                      minutes: settings.breakMinutes,
                                      seconds: settings.breakSeconds,
                                      maxMinutes: 30,
                                      maxSeconds: 59,
                                      onMinutesChanged: (minutes) {
                                        settingsNotifier.updateBreakMinutes(minutes);
                                      },
                                      onSecondsChanged: (seconds) {
                                        settingsNotifier.updateBreakSeconds(seconds);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SettingCard(
                                      title: 'サイクル数\n上限10サイクル',
                                      value: settings.cycles,
                                      onIncrement: () {
                                        if (settings.cycles < 10) {
                                          settingsNotifier.updateCycles(
                                            settings.cycles + 1,
                                          );
                                        }
                                      },
                                      onDecrement: () {
                                        if (settings.cycles > 1) {
                                          settingsNotifier.updateCycles(
                                            settings.cycles - 1,
                                          );
                                        }
                                      },
                                      onChanged: (value) {
                                        final cycles = int.tryParse(value) ?? 4;
                                        if (cycles >= 1 && cycles <= 10) {
                                          settingsNotifier.updateCycles(cycles);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              onPressed: () {
                                final timerNotifier = ref.read(
                                  timerInfoProvider.notifier,
                                );
                                timerNotifier.startTimer(settings);
                                context.push('/Timer');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'タイマー開始',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
