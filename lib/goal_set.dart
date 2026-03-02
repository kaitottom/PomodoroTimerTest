import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/goal_settings_provider.dart';
import '../models/goal_settings.dart';
import '../widgets/setting_card.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  final TextEditingController _goalController = TextEditingController();
  String _goal = '';
  int _difficulty = 3;
  int _impact = 3;
  DateTime _limit = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            //if (constraints.maxWidth < 600) {
            // スマホ向け（現状の縦並び）
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '目標設定',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '＜目標設定のコツ＞',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'description',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 目標設定フォーム
                    Container(
                      margin: const EdgeInsets.only(top: 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('目標：'),
                          TextField(
                            controller: _goalController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '目標を入力',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _goal = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('難易度：'),
                              Text('$_difficulty'),
                            ],
                          ),
                          Slider(
                            value: _difficulty.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: '$_difficulty',
                            onChanged: (value) {
                              setState(() {
                                _difficulty = value.round();
                              });
                            },
                            thumbColor: Colors.pinkAccent,
                            activeColor: Colors.pink,
                            inactiveColor: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [const Text('重要度：'), Text('$_impact')],
                          ),
                          Slider(
                            value: _impact.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: '$_impact',
                            onChanged: (value) {
                              setState(() {
                                _impact = value.round(); // 四捨五入してintへ
                              });
                            },
                            thumbColor: Colors.blue,
                            activeColor: Colors.lightBlue,
                            inactiveColor: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('期限：'),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _limit,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _limit = picked;
                                    });
                                  }
                                },
                                child: Text(
                                  '${_limit.year}/${_limit.month}/${_limit.day}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        // 詳細設定へ（/goal/detailへ遷移）
                        context.go('/goal/detail');
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
                        '目標決定（詳細設定へ）',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // 詳細なしでポモドーロ設定画面へ（/Timersettingsへ遷移）
                        context.go('/Timersettings');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '目標決定（詳細なしで始める）',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
            //}
            /**  else {
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
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: SettingCard(
                                    title: '集中時間\n上限60分',
                                    value: settings.focusMinutes,
                                    onIncrement: () {
                                      if (settings.focusMinutes < 60) {
                                        settingsNotifier.updateFocusMinutes(
                                          settings.focusMinutes + 1,
                                        );
                                      }
                                    },
                                    onDecrement: () {
                                      if (settings.focusMinutes > 1) {
                                        settingsNotifier.updateFocusMinutes(
                                          settings.focusMinutes - 1,
                                        );
                                      }
                                    },
                                    onChanged: (value) {
                                      final minutes = int.tryParse(value) ?? 25;
                                      if (minutes >= 1 && minutes <= 60) {
                                        settingsNotifier.updateFocusMinutes(
                                          minutes,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: SettingCard(
                                    title: '休憩時間\n上限30分',
                                    value: settings.breakMinutes,
                                    onIncrement: () {
                                      if (settings.breakMinutes < 30) {
                                        settingsNotifier.updateBreakMinutes(
                                          settings.breakMinutes + 1,
                                        );
                                      }
                                    },
                                    onDecrement: () {
                                      if (settings.breakMinutes > 1) {
                                        settingsNotifier.updateBreakMinutes(
                                          settings.breakMinutes - 1,
                                        );
                                      }
                                    },
                                    onChanged: (value) {
                                      final minutes = int.tryParse(value) ?? 5;
                                      if (minutes >= 1 && minutes <= 30) {
                                        settingsNotifier.updateBreakMinutes(
                                          minutes,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
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
                                context.go('/Timer');
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
            }*/
          },
        ),
      ),
    );
  }
}
