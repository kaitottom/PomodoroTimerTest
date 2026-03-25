import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
//import '../providers/pomodoro_settings_provider.dart';
//import '../providers/timer_provider.dart';
//import '../providers/goal_settings_provider.dart';
import '../models/pomodoro_settings.dart';
import '../theme/app_colors.dart';
import '../widgets/main_button.dart';
import '../pages/goal/goal_main_page.dart';
import 'package:pomo_timer/theme/app_theme.dart';


class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/pomodoro_tomato.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ポモドーロタイマー',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ParadiseColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '集中力を高めて、効率的に作業しましょう',
                        style: TextStyle(fontSize: 16, color: ParadiseColors.deepText),
                        textAlign: TextAlign.center,

                      ),
                      const SizedBox(height: 30),
                      // 設定中の目標表示
                      Consumer(
                        builder: (context, ref, child) {
                          final currentGoalAsync = ref.watch(currentGoalProvider);
                          //final currentGoal = ref.watch(currentGoalProvider);
                          //return Container(
                          return currentGoalAsync.when(
                              data: (currentgoal) =>
                              // Consumer内のcurrentGoalAsync.when(data: (currentgoal) => ... ) の中身を書き換えます
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    // --- 外側の「宝石の額縁」部分 ---
                                    decoration: BoxDecoration(
                                      // 画像の塔のようなエメラルドグリーン（ティール）
                                      color: ParadiseColors.primaryTeal,
                                      borderRadius: BorderRadius.circular(15),
                                      // 高級感を出すための深い影
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      // 微かな光沢を出すグラデーション
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          ParadiseColors.cloudGrey,
                                          ParadiseColors.groundBlue,
                                          ParadiseColors.skyDeepBlue,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      // 額縁の厚み（木枠の代わり）
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        // --- 内側の「大理石・空」のボード部分 ---
                                        decoration: BoxDecoration(
                                          color: ParadiseColors.groundWhite, // 画像の空の色（アリスブルー）
                                          borderRadius: BorderRadius.circular(11),
                                          // 内側に沈み込んでいるような立体感を出すための内影（風）
                                          border: Border.all(
                                            color: ParadiseColors.crystalRock.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                                          child: Row(
                                            children: [
                                              // アイコンもゴールドで統一
                                              const Icon(
                                                Icons.stars_rounded, // 旗よりも「特別な場所」感のあるアイコン
                                                color: ParadiseColors.accentGold,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      '現在の目標', // 英字にするとより高級感が出ます
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w800,
                                                        color: Color(0xFF004D4D),
                                                        letterSpacing: 2.0,
                                                        fontFamily: 'Serif',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      currentgoal?.goal.goal ?? '目標はセットされていません',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: ParadiseColors.accentGold,
                                                        fontFamily: 'Serif',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // --- ゴールドに修正済みのピンを配置 ---
                                  Positioned(top: 12, left: 9, child: _buildPin()),
                                  Positioned(top: 12, right: 9, child: _buildPin()),
                                  Positioned(bottom: 12, left: 9, child: _buildPin()),
                                  Positioned(bottom: 12, right: 9, child: _buildPin()),
                                ],
                              ),
                            loading: () => CircularProgressIndicator(color: ParadiseColors.accentGold, backgroundColor: ParadiseColors.skyBackground,),
                            error: (_, __) => Text('目標の取得に失敗しました'),
                          );
                          },
                      ),
                      const SizedBox(height: 16),
                      MainButton(
                        title: 'タイマーを開始',
                        subtitle: '設定した時間でポモドーロを開始',
                        icon: Icons.play_circle_filled,
                        color: Colors.green,
                        onPressed: () {
                          final timerNotifier = ref.read(
                            timerInfoProvider.notifier,
                          );
                          final settings = ref.read(pomodoroSettingsProvider);
                          final isDefault =
                              settings.focusMinutes == 25 &&
                              settings.breakMinutes == 5 &&
                              settings.cycles == 4;
                          final startSettings = isDefault
                              ? PomodoroSettings()
                              : settings;
                          timerNotifier.startTimer(startSettings);
                          context.go('/Timer');
                        },
                      ),
                      const SizedBox(height: 20),
                      MainButton(
                        title: '設定を変更',
                        subtitle: '集中時間・休憩時間・サイクル数を調整',
                        icon: Icons.settings,
                        color: Colors.blue,
                        onPressed: () => context.go('/Timersettings'),
                      ),
                      const SizedBox(height: 20),
                      MainButton(
                        title: '目標を設定',
                        subtitle: '今日の目標を設定してモチベーション向上',
                        icon: Icons.flag,
                        color: Colors.orange,
                        onPressed: () => context.go('/goal'),
                      ),
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.topCenter, // 中央上にピンを置く基準
                        children: [
                          Container(
                            // ピンの分、少しだけ上にマージンを持たせると収まりが良い
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ParadiseColors.groundWhite.withValues(alpha: 1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ParadiseColors.primaryTeal.withValues(alpha: 0.5),
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
                                  'ポモドーロテクニックとは？',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ParadiseColors.primaryTeal,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '25分の集中作業と5分の休憩のように\n集中と休憩をを繰り返すことで、\n集中力と生産性を向上させる時間管理手法です。',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ParadiseColors.deepText, // 文字を少し読みやすく
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // 📍 中央上部にピンを配置
                          Positioned(
                            top: 0,
                            child: Transform.rotate(
                              angle: -0.1, // 少しだけ斜めにすると「いかにも」感が出ます
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: ParadiseColors.accentGold, // ピンの色
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      ParadiseColors.accentGold,
                                      ParadiseColors.accentGold.withValues(alpha: 0.5),
                                    ],
                                    center: const Alignment(-0.3, -0.3), // 光沢の位置
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                // ピンの真ん中の小さな点（反射）
                                child: Center(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else {
              // タブレット・PC向け（2カラム）
              return Center(
                child: SizedBox(
                  width: 900,
                  child: SizedBox(
                    height: 600, // 最大高さを指定（必要に応じて調整）
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左カラム: アイコン・タイトル・説明
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 30),
                                const Icon(
                                  Icons.timer,
                                  size: 100,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'ポモドーロタイマー',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE8C957),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '集中力を高めて、効率的に作業しましょう',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        'ポモドーロテクニックとは？',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        '25分の集中作業と5分の休憩のように\n集中と休憩をを繰り返すことで、\n集中力と生産性を向上させる時間管理手法です。',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // 設定中の目標表示（PC向け）
                                Consumer(
                                  builder: (context, ref, child) {
                                    final currentGoalAsync = ref.watch(currentGoalProvider);
                                    return currentGoalAsync.when(
                                        data: (currentgoal) => Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '現在の目標',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  currentgoal?.goal.goal ?? 'なし',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                        ),
                                      loading: () => CircularProgressIndicator(),
                                      error: (_, __) => Text('目標の取得に失敗しました'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 60),
                        // 右カラム: ボタン群
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 80),
                              MainButton(
                                title: 'タイマーを開始',
                                subtitle: '設定した時間でポモドーロを開始',
                                icon: Icons.play_circle_filled,
                                color: Colors.green,
                                onPressed: () {
                                  final timerNotifier = ref.read(
                                    timerInfoProvider.notifier,
                                  );
                                  final settings = ref.read(
                                    pomodoroSettingsProvider,
                                  );
                                  final isDefault =
                                      settings.focusMinutes == 25 &&
                                      settings.breakMinutes == 5 &&
                                      settings.cycles == 4;
                                  final startSettings = isDefault
                                      ? PomodoroSettings()
                                      : settings;
                                  timerNotifier.startTimer(startSettings);
                                  context.go('/Timer');
                                },
                              ),
                              const SizedBox(height: 30),
                              MainButton(
                                title: '設定を変更',
                                subtitle: '集中時間・休憩時間・サイクル数を調整',
                                icon: Icons.settings,
                                color: Colors.blue,
                                onPressed: () => context.go('/Timersettings'),
                              ),
                              const SizedBox(height: 30),
                              MainButton(
                                title: '目標を設定',
                                subtitle: '今日の目標を設定してモチベーション向上',
                                icon: Icons.flag,
                                color: Colors.orange,
                                onPressed: () => context.go('/goal'),
                              ),
                            ],
                          ),
                        ),
                      ],
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


// ピンを表現するパーツ
  Widget _buildPin() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: ParadiseColors.accentGold, // ピンの色（画鋲っぽく赤など）
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFF8DC), // 中心：白に近いゴールド（光沢）
            const Color(0xFFD4AF37), // 外側：メタリックゴールド
          ],
          center: const Alignment(-0.3, -0.3), // 光沢の位置をずらす
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0.5, 0.5),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
