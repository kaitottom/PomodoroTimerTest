import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pomo_timer/pages/timer_complete_handler.dart';
import 'package:pomo_timer/theme/app_colors.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:screen_state/screen_state.dart';

import '../data/database/app_database.dart';
import '../providers.dart';
import '../widgets/concentration_bottomsheet.dart';
import '../models/score.dart';
import '../models/pomodoro_settings.dart';
import '../models/timer_info.dart';
import '../models/app_settings.dart';
import 'package:pomo_timer/models/goal_with_tasks.dart';

import '../widgets/confirm_back_wrapper.dart';

class PomodoroTimerPage extends ConsumerStatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  ConsumerState<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends ConsumerState<PomodoroTimerPage>
    with WidgetsBindingObserver {
  Timer? _timer;
  // 2. ScreenState用の変数を追加
  late Screen _screen;
  StreamSubscription<ScreenStateEvent>? _screenSubscription;
  bool _isScreenOff = false; // 画面がオフかどうかを保持するフラグ

  //bool _redirectScheduled = false;
  bool _modalShown = false;
  bool _isWakelockEnabled = false;
  late VideoPlayerController _videoController;
  bool _videoControllerInitialized = false;
  BreakBackgroundType? _currentBackgroundType;
  //bool _showBackgroundVideo = true;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _screen = Screen();
    _tryStartScreenListener();

    _startTimer();

    // 動画コントローラーはbuildメソッドで設定を読み込んでから初期化する
    // ダミーの初期化（後で上書きされる）
    _videoController = VideoPlayerController.asset(
      'assets/videos/break_in_forests.mp4',
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // アプリアイコンを使用

    // iOS用の設定 (許可を求める)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    _notificationsPlugin.initialize(initializationSettings);
  }

  void _tryStartScreenListener() {
    try {
      _screenSubscription = _screen.screenStateStream.listen((
        ScreenStateEvent event,
      ) {
        // 画面の状態が変更されたらフラグを更新
        if (event == ScreenStateEvent.SCREEN_OFF) {
          _isScreenOff = true;
        } else if (event == ScreenStateEvent.SCREEN_ON) {
          _isScreenOff = false;
        }
      });
    } catch (exception) {}
  }

  /// 背景タイプに応じた動画パスを取得
  String _getVideoPath(BreakBackgroundType type) {
    switch (type) {
      case BreakBackgroundType.forest:
        return 'assets/videos/break_in_forests.mp4';
      case BreakBackgroundType.sea:
        return 'assets/videos/break_sea.mp4';
      case BreakBackgroundType.undersea:
        return 'assets/videos/break_undersea.mp4';
      case BreakBackgroundType.onsen:
        return 'assets/videos/break_onsen.mp4';
      case BreakBackgroundType.sky:
        return 'assets/videos/break_sky.mp4';
      case BreakBackgroundType.lavender:
        return 'assets/videos/break_lavender.mp4';
      case BreakBackgroundType.snow:
        return 'assets/videos/break_snow.mp4';
    }
  }

  /// 設定に基づいて動画コントローラーを初期化
  void _initializeVideoControllerWithSettings(
    BreakBackgroundType backgroundType,
  ) {
    if (_videoControllerInitialized) return;

    try {
      _videoController.dispose(); // 既存のコントローラーを破棄
    } catch (e) {
      // 既に破棄済みの場合は無視
    }

    _currentBackgroundType = backgroundType;
    _videoController =
        VideoPlayerController.asset(_getVideoPath(backgroundType))
          ..initialize().then((_) {
            _videoController.setLooping(true);
            _videoController.setVolume(0.4);
            _videoControllerInitialized = true;
            if (mounted) {
              setState(() {});
            }
          });
  }

  /// 動画コントローラーを再初期化（設定変更時）
  Future<void> _reinitializeVideoController(
    BreakBackgroundType backgroundType,
  ) async {
    if (_videoControllerInitialized) {
      try {
        await _videoController.dispose();
      } catch (e) {
        // エラー無視
      }
      _videoControllerInitialized = false;
    }

    _currentBackgroundType = backgroundType;
    _videoController =
        VideoPlayerController.asset(_getVideoPath(backgroundType))
          ..initialize().then((_) {
            _videoController.setLooping(true);
            _videoController.setVolume(0.4);
            _videoControllerInitialized = true;
            if (mounted) {
              setState(() {});
            }
          });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenSubscription?.cancel();
    _timer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timerInfo = ref.read(timerInfoProvider);
    final isBackgroundEnabled = ref.read(appSettingsProvider).isBackgroundEnabled;

    if (state == AppLifecycleState.paused) {
      // 【設定がOFF】かつ【タイマーが実行中】なら一時停止する
      if (!isBackgroundEnabled && timerInfo.state == TimerState.running) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_isScreenOff && mounted) {
            ref.read(timerInfoProvider.notifier).pauseTimer();
            _showPauseNotification(timerInfo.type == TimerType.focus);
          }
        });
      }
      // ONの場合はスルー
    }
  }

  // ★通知を表示する専用の関数を追加
  Future<void> _showPauseNotification(bool isFocus) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'timer_pause_channel', // チャンネルID
          'Timer Paused', // チャンネル名
          channelDescription: 'タイマー中断時の通知',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // メッセージの内容
    String title = 'タイマーを一時停止しました⚠️';
    String body = isFocus ? '今やっていることは、後で後悔してまわないか？' : '次に備えてしっかりと休憩取ってください！';

    await _notificationsPlugin.show(
      0, // 通知ID
      title,
      body,
      notificationDetails,
    );
  }

  void _startTimer() {
    // 1. 既存のタイマーがあれば確実に止める
    _timer?.cancel();
    _timer = null;

    // 2. タイマーを作成（通常通り1秒周期）
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });

  }

// ロジックを共通化するために外に出します
  void _updateRemainingTime() {
    if (!mounted) return;

    final timerInfo = ref.read(timerInfoProvider);
    final settings = ref.read(pomodoroSettingsProvider);

    if (timerInfo.state == TimerState.running && timerInfo.endTime != null) {
      final now = DateTime.now();
      final remainingSeconds = timerInfo.endTime!.difference(now).inSeconds;

      if (remainingSeconds <= 0) {
        _timer?.cancel();
        _timer = null;
        ref.read(timerInfoProvider.notifier).updateRemainingSeconds(0);
        if (!_modalShown) {
          _modalShown = true;
          _handleTimerComplete(settings);
        }
      } else {
        ref.read(timerInfoProvider.notifier).updateRemainingSeconds(remainingSeconds);
      }
    }
  }

  void _handleTimerComplete(PomodoroSettings settings) async {
    final timerInfo = ref.read(timerInfoProvider);
    if (timerInfo.type == TimerType.focus) {
      if (timerInfo.currentCycle <= timerInfo.totalCycles) {
        await ref.read(timerInfoProvider.notifier).switchToBreak(settings);
        _startTimer();
        _modalShown = false;
      } else {
        onTimerComplete(context, ref);
        // 全サイクル完了時は集中度評価へ
        // 少し遅延させてからモーダルを表示（音声再生完了後に）
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showConcentrationModal(settings);
          }
        });
      }
    } else {
      if (timerInfo.currentCycle < timerInfo.totalCycles) {
        await ref.read(timerInfoProvider.notifier).switchToFocus(settings);
        _startTimer();
        _modalShown = false;
      } else {
        onTimerComplete(context, ref);
        // 全サイクル完了時は集中度評価へ
        // 少し遅延させてからモーダルを表示（音声再生完了後に）
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showConcentrationModal(settings);
          }
        });
      }
    }
  }

  void _showConcentrationModal(PomodoroSettings settings) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ConcentrationBottomSheet(
          onConfirm: (reflectionData) async {
            final timerInfo = ref.read(timerInfoProvider);
            final startTime = timerInfo.startTime ?? DateTime.now();
            final endTime = DateTime.now();

            final int currentCycle = timerInfo.currentCycle > 0
                ? timerInfo.currentCycle
                : 1;
            final int remainingSeconds = timerInfo.remainingSeconds;

            ref.read(timerInfoProvider.notifier).stopTimer();

            // 秒単位で計算してから分に変換
            final int focusTotalSeconds = settings.focusTotalSeconds;
            final int breakTotalSeconds = settings.breakTotalSeconds;
            final int focusOnlySeconds = timerInfo.type == TimerType.focus?
            (focusTotalSeconds * currentCycle) - remainingSeconds :
            (focusTotalSeconds * currentCycle);
            final int totalSeconds = timerInfo.type == TimerType.focus?
            focusTotalSeconds * currentCycle + breakTotalSeconds * (currentCycle - 1) - remainingSeconds :
            focusTotalSeconds * currentCycle + breakTotalSeconds * currentCycle - remainingSeconds;

            int focusOnlyMinutes = (focusOnlySeconds / 60).floor();
            int totalMinutes = (totalSeconds / 60).floor();

            if (focusOnlyMinutes < 0) focusOnlyMinutes = 0;
            if (totalMinutes < 0) totalMinutes = 0;

            // currentGoalProvider の最新状態を watch
            final currentGoalAsync = ref.read(currentGoalProvider);

            await currentGoalAsync.when(
              data: (currentGoal) async {
                final sessionData = SessionData(
                  goal: currentGoal, // GoalWithTasks
                  startedAt: startTime,
                  endedAt: endTime,
                  durationMinutes: totalMinutes,
                  focusMinutes: focusOnlyMinutes,
                  concentrationLevel: reflectionData.concentration,
                  goodPoints: reflectionData.goodPoints,
                  improvementPoints: reflectionData.improvementPoints,
                  futurePlans: reflectionData.futurePlans,
                );

                Navigator.pop(context); // BottomSheet を閉じる

                // 少し遅延してから遷移
                Future.delayed(const Duration(milliseconds: 100), () {
                  // 引数で時間や集中度を渡す
                  if (mounted) context.push('/evaluation', extra: sessionData);
                });
              },
              loading: () async {
                // ローディング中なら待機 or ボタン無効化
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('目標を読み込み中です')));
              },
              error: (err, _) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('目標データの読み込みに失敗しました: $err')),
                );
              },
            );
          },
          onLater: () async {
            final timerInfo = ref.read(timerInfoProvider);
            final startTime = timerInfo.startTime ?? DateTime.now();
            final endTime = DateTime.now();

            final int currentCycle = timerInfo.currentCycle > 0
                ? timerInfo.currentCycle
                : 1;
            final int remainingSeconds = timerInfo.remainingSeconds;

            ref.read(timerInfoProvider.notifier).stopTimer();

            // 秒単位で計算してから分に変換
            final int focusTotalSeconds = settings.focusTotalSeconds;
            final int breakTotalSeconds = settings.breakTotalSeconds;
            final int focusOnlySeconds = timerInfo.type == TimerType.focus?
            (focusTotalSeconds * currentCycle) - remainingSeconds :
            (focusTotalSeconds * currentCycle);
            final int totalSeconds = timerInfo.type == TimerType.focus?
            focusTotalSeconds * currentCycle + breakTotalSeconds * (currentCycle - 1) - remainingSeconds :
            focusTotalSeconds * currentCycle + breakTotalSeconds * currentCycle - remainingSeconds;

            int focusOnlyMinutes = (focusOnlySeconds / 60).floor();
            int totalMinutes = (totalSeconds / 60).floor();

            if (focusOnlyMinutes < 0) focusOnlyMinutes = 0;
            if (totalMinutes < 0) totalMinutes = 0;

            final currentGoalAsync = ref.read(currentGoalProvider);
            final currentGoal = currentGoalAsync.maybeWhen(
              data: (goal) => goal,
              orElse: () => null,
            );

            final sessionDataLater = SessionData(
              goal: currentGoal, // GoalWithTasks
              startedAt: startTime,
              endedAt: endTime,
              durationMinutes: totalMinutes,
              focusMinutes: focusOnlyMinutes,
              concentrationLevel: 0,
              goodPoints: '',
              improvementPoints: '',
              futurePlans: '',
            );

            final tasksToSave = currentGoal?.tasks ?? [];
            await ref
                .read(scoreDaoProvider)
                .addScoreDraft(sessionDataLater, tasksToSave);

            Navigator.pop(context); // BottomSheet を閉じる
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) context.go('/Timersettings');
            });
          },
          onSkip: () {
            Navigator.pop(context); // BottomSheet を閉じる
            context.go('/Timersettings'); // 評価せず終了
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final timerInfo = ref.watch(timerInfoProvider);
    final formattedTime = ref.watch(formattedTimeProvider);
    final timerStateText = ref.watch(timerStateTextProvider);
    final settings = ref.watch(pomodoroSettingsProvider);
    final currentGoal = ref.watch(currentGoalProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final isBreakMode = timerInfo.type == TimerType.break_;
    final shouldShowBreakScreen = appSettings.showBreakScreen && isBreakMode;
    final isVideoReady = _videoController.value.isInitialized;

    // 設定に基づいて動画コントローラーを初期化（初回のみ）
    if (!_videoControllerInitialized ||
        _currentBackgroundType != appSettings.breakBackgroundType) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentBackgroundType != appSettings.breakBackgroundType) {
          _reinitializeVideoController(appSettings.breakBackgroundType);
        } else {
          _initializeVideoControllerWithSettings(
            appSettings.breakBackgroundType,
          );
        }
      });
    }

    // 背景タイプが変更された場合、動画コントローラーを再初期化
    ref.listen<AppSettings>(appSettingsProvider, (previous, next) {
      if (previous?.breakBackgroundType != next.breakBackgroundType) {
        _reinitializeVideoController(next.breakBackgroundType);
      }
    });

    if (_isWakelockEnabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    // ★追加: タイマーの状態変化を監視して動画の再生/停止を制御
    ref.listen<TimerInfo>(timerInfoProvider, (previous, next) {
      // 休憩画面表示がOFFの場合は何もしない
      final currentAppSettings = ref.read(appSettingsProvider);
      if (!currentAppSettings.showBreakScreen) return;

      // 直前が「休憩」ではなく、現在が「休憩」になった瞬間 -> 再生
      if (previous?.type != TimerType.break_ && next.type == TimerType.break_) {
        if (_videoController.value.isInitialized) {
          _videoController.play();
        }
      }

      // 直前が「休憩」で、現在が「休憩」ではなくなった瞬間 -> 停止
      if (previous?.type == TimerType.break_ && next.type != TimerType.break_) {
        // 動画を一時停止（または停止）
        _videoController.pause();
      }

      // 3. タイマー自体が停止(stopped)または一時停止(paused)された場合も動画を止める
      if (next.state == TimerState.paused || next.state == TimerState.stopped) {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
        }
      } else if (next.state == TimerState.running &&
          next.type == TimerType.break_) {
        // 再開時、もし休憩中なら動画も再開
        if (!_videoController.value.isPlaying) {
          _videoController.play();
        }
      }
    });

    /*if (timerInfo.state == TimerState.stopped && timerInfo.startTime == null) {
      //if (!_redirectScheduled) {
      //  _redirectScheduled = true; // 一度だけ実行
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/Timersettings');
          }
        });
      //}


      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 回り続けないインジケーター
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'タイマーを開始のため自動で設定画面に移動します',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    */

    return ConfirmBackWrapper(
      onConfirmPop: () => context.go('/Timersettings'),
      message: 'タイマーを中断して戻りますか？後から再開できません。',
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (_) {},
            onPanDown: (_) {},
            child: Scaffold(
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
                child: FloatingActionButton.small(
                  heroTag: "wakelock_button",
                  onPressed: () {
                    setState(() {
                      _isWakelockEnabled = !_isWakelockEnabled;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isWakelockEnabled
                              ? '画面を自動で消さずに表示し続けます。'
                              : '画面は自動消灯に戻りました。',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: _isWakelockEnabled
                      ? Colors.orange[200]
                      : Colors.blue[400],
                  tooltip: _isWakelockEnabled
                      ? '画面を常に ON にする設定が有効です'
                      : '画面を常に ON にする設定を有効化',
                  child: //const Text("☀"),
                  Icon(
                    _isWakelockEnabled
                        ? CupertinoIcons.sun_max_fill
                        : CupertinoIcons.moon_fill,
                    color: Colors.white,
                  ),
                ),
              ),

              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    /*if (constraints.maxWidth < 600) {
              // スマホ向け（現状の縦並び）
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),//all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,///
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:  currentGoal.when(
                                data: (goal) {
                                  if (goal == null) {
                                    return const Text('目標がありません',
                                    style: TextStyle(color: Colors.red, fontSize: 16),
                                  );
                                  }
                                  return CurrentGoalOverview(
                                    goalWithTasks: goal,
                                  );
                                },

                                loading: () => Text(
                                  '目標を読み込み中...',
                                  style: TextStyle(color: Colors.blue.shade200),
                                ),
                                error: (e, _) => Text(
                                  '目標の取得に失敗しました',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),

                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: timerInfo.type == TimerType.focus
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: timerInfo.type == TimerType.focus
                                ? Colors.red.shade200
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          timerStateText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: timerInfo.type == TimerType.focus
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      //const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '残り時間',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (timerInfo.type == TimerType.focus)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: LinearPercentIndicator(
                            lineHeight: 8.0,
                            percent:
                                1 -
                                timerInfo.remainingSeconds /
                                    settings.focusTotalSeconds,
                            backgroundColor: Colors.grey.shade300,
                            progressColor: Colors.green,
                            animation: true,
                            animateFromLastPercent: true,
                            alignment: MainAxisAlignment.center,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.repeat, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'サイクル ${timerInfo.currentCycle} / ${timerInfo.totalCycles}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (timerInfo.state != TimerState.stopped)
                            ElevatedButton.icon(
                              onPressed: () {
                                if (timerInfo.state == TimerState.running) {
                                  ref
                                      .read(timerInfoProvider.notifier)
                                      .pauseTimer();
                                } else if (timerInfo.state ==
                                    TimerState.paused) {
                                  ref
                                      .read(timerInfoProvider.notifier)
                                      .resumeTimer();
                                }
                              },
                              icon: Icon(
                                timerInfo.state == TimerState.running
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                timerInfo.state == TimerState.running
                                    ? '一時停止'
                                    : '再開',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(timerInfoProvider.notifier).pauseTimer();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('タイマーを中断しますか？'),
                                  content: const Text('現在のセッションがリセットされます。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                          Navigator.of(context).pop();
                                          ref.read(timerInfoProvider.notifier).resumeTimer();
                                          },
                                      child: const Text('キャンセル'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _showConcentrationModal(settings);
                                      },
                                      child: const Text('中断'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('中断'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () => context.go('/Timersettings'),
                        child: const Text('設定を変更'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );

            }
             */

                    if (constraints.maxWidth < 600) {
                      // --- ヘルパー: 進捗率の計算 (0.0 ~ 1.0) ---
                      double progress = 0.0;
                      final int totalSeconds = () {
                        if (timerInfo.type == TimerType.focus) {
                          return settings.focusTotalSeconds;
                        } else {
                          return settings.breakTotalSeconds;
                        }
                      }();
                      if (totalSeconds > 0) {
                        progress = (totalSeconds == 0)
                            ? 0
                            : 1 - (timerInfo.remainingSeconds / totalSeconds);
                      }
                      // ------------------------------------------

                      return Stack(
                        fit: StackFit.expand, // 画面いっぱいに広げる
                        children: [
                          // --- 1. 背景動画レイヤー (休憩中で設定がONの場合のみ表示) ---
                          if (shouldShowBreakScreen && isVideoReady)
                            SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover, // アスペクト比を維持して画面を埋める
                                child: SizedBox(
                                  width: _videoController.value.size.width,
                                  height: _videoController.value.size.height,
                                  child: VideoPlayer(_videoController),
                                ),
                              ),
                            ),

                          // --- 2. フィルターレイヤー (文字を見やすくするための半透明の黒) ---
                          if (shouldShowBreakScreen)
                            Container(color: Colors.black.withValues(alpha: 0.3)),

                          // --- 3. メインコンテンツ (既存のSingleChildScrollView) ---
                          SingleChildScrollView(
                            child: ConstrainedBox(
                              // Containerの高さを画面サイズに合わせるための工夫
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      // 画面の高さ確保（スクロール可能だが、コンテンツが少ない時は中央に寄せるための制約）
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight - 20,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                        vertical: 16.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // 1. 目標・タスク表示エリア (コンパクトな開閉式)
                                          currentGoal.when(
                                            data: (goalWithTasks) {
                                              if (goalWithTasks == null) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text('目標なし', style: TextStyle(color: Colors.grey)),
                                                );
                                              }
                                              return Container(
                                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                // --- 1. 土台：木製のボード ---
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF4E342E), // 濃い木の色
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: const [
                                                    BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
                                                  ],
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // --- 2. メイン：羊皮紙風のExpansionTile ---
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0), // 木枠を見せるための余白
                                                      child: Theme(
                                                        // ExpansionTileの境界線を消すためのTheme
                                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            // 羊皮紙グラデーション
                                                            gradient: const RadialGradient(
                                                              colors: [Color(0xFFE1D4A1), Color(0xFFE6D5B8), Color(0xFFF1EDDD), Color(0xFFFBEBAB)],
                                                              center: Alignment.bottomRight,
                                                              radius: 1.5,
                                                            ),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: ExpansionTile(
                                                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

                                                            // 閉じた状態の見出し
                                                            leading: Transform.rotate(
                                                              angle: -0.1,
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: const Color(0xFF3E2723), width: 1),
                                                                ),
                                                                child: const Text(
                                                                  'QUEST',
                                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                                                                ),
                                                              ),
                                                            ),
                                                            title: Text(
                                                              goalWithTasks.goal.goal,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 17,
                                                                fontFamily: 'Serif',
                                                                color: Color(0xFF3E2723),
                                                              ),
                                                              maxLines: 2, // 長い目標名も2行まで許容
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            subtitle: Text(
                                                              "進捗: ${goalWithTasks.tasks.where((t) => t.isCompleted).length}/${goalWithTasks.tasks.length}  期限: ${DateFormat('MM/dd').format(goalWithTasks.goal.limit)}",
                                                              style: TextStyle(fontSize: 12, color: Colors.brown.shade700),
                                                            ),

                                                            // 開いた状態の中身
                                                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                            children: [
                                                              const Divider(color: Color(0x333E2723)),
                                                              if (goalWithTasks.tasks.isEmpty)
                                                                const Text("タスクなし", style: TextStyle(color: Colors.brown, fontStyle: FontStyle.italic))
                                                              else
                                                                ...goalWithTasks.tasks.map((task) => Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start, // 長文時もチェックを上に固定
                                                                    children: [
                                                                      // カスタムチェックボックス
                                                                      Container(
                                                                        margin: const EdgeInsets.only(top: 2),
                                                                        width: 18,
                                                                        height: 18,
                                                                        decoration: BoxDecoration(
                                                                          border: Border.all(color: const Color(0xFF3E2723), width: 2),
                                                                          borderRadius: BorderRadius.circular(4),
                                                                          color: task.isCompleted ? const Color(0xFF3E2723) : Colors.transparent,
                                                                        ),
                                                                        child: task.isCompleted
                                                                            ? const Icon(Icons.check, size: 14, color: Color(0xFFF7F0D5))
                                                                            : null,
                                                                      ),
                                                                      const SizedBox(width: 12),
                                                                      // タスク詳細
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              task.task,
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                height: 1.2,
                                                                                fontFamily: 'Serif',
                                                                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                                                                color: task.isCompleted ? Colors.brown.withValues(alpha: 0.5) : const Color(0xFF3E2723),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 2),
                                                                            Text(
                                                                              '期限: ${DateFormat('MM/dd').format(task.limit)}',
                                                                              style: const TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            loading: () => Text(
                                              '読み込み中...',
                                              style: TextStyle(
                                                color: Colors.blue.shade200,
                                              ),
                                            ),
                                            error: (_, __) => const SizedBox.shrink(),
                                          ),

                                          const SizedBox(height: 20),

                                          // 2. タイマー & サイクル表示エリア (Stackで重ねて表示)
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // 背景の円グラフ (プログレス)
                                              SizedBox(
                                                width: 280,
                                                height: 280,
                                                child: CircularProgressIndicator(
                                                  value: progress.clamp(0, 1.0),
                                                  strokeWidth: 12,
                                                  backgroundColor:
                                                  Colors.white,
                                                  color:
                                                  timerInfo.type ==
                                                      TimerType.focus
                                                      ? ParadiseColors.subaccentGold
                                                      : ParadiseColors.primaryTeal,
                                                  strokeCap: StrokeCap.round,
                                                ),
                                              ),
                                              // 中央の情報
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // 状態ラベル (集中 or 休憩)
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                      timerInfo.type ==
                                                          TimerType.focus
                                                          ? Colors.red.shade50
                                                          : Colors.green.shade50,
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      timerStateText, // Providerから取得したテキスト
                                                      style: TextStyle(
                                                        color:
                                                        timerInfo.type ==
                                                            TimerType.focus
                                                            ? Colors.red
                                                            : Colors.green,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  // 残り時間（特大かつ等幅フォント）
                                                  Text(
                                                    formattedTime,
                                                    style: const TextStyle(
                                                      fontSize: 64,
                                                      fontWeight: FontWeight.bold,
                                                      fontFeatures: [
                                                        FontFeature.tabularFigures(),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // サイクル情報
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.repeat,
                                                        size: 18,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '${timerInfo.currentCycle} / ${timerInfo.totalCycles} サイクル',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 30),

                                          // 3. 操作ボタンエリア (大きく押しやすく)
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              // 再生・一時停止ボタン
                                              SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Column(
                                                  children: [
                                                    FloatingActionButton(
                                                      onPressed: () {
                                                        if (timerInfo.state ==
                                                            TimerState.running) {
                                                          ref
                                                              .read(
                                                            timerInfoProvider
                                                                .notifier,
                                                          )
                                                              .pauseTimer();
                                                        } else {
                                                          // 停止中または一時停止中なら開始/再開
                                                          if (timerInfo.state ==
                                                              TimerState.stopped) {
                                                            ref
                                                                .read(
                                                              timerInfoProvider
                                                                  .notifier,
                                                            )
                                                                .startTimer(settings);
                                                          } else {
                                                            ref
                                                                .read(
                                                              timerInfoProvider
                                                                  .notifier,
                                                            )
                                                                .resumeTimer();
                                                          }
                                                        }
                                                      },
                                                      backgroundColor:
                                                      timerInfo.state ==
                                                          TimerState.running
                                                          ? Colors.orangeAccent
                                                          : Colors.blueAccent,
                                                      elevation: 4,
                                                      child: Icon(
                                                        timerInfo.state ==
                                                            TimerState.running
                                                            ? Icons.pause_rounded
                                                            : Icons
                                                            .play_arrow_rounded,
                                                        size: 48,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      timerInfo.state ==
                                                          TimerState.running
                                                          ? '一時停止'
                                                          : '再開',
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 30),
                                              // 中断ボタン (少し小さめ)
                                              Column(
                                                children: [
                                                  IconButton.filledTonal(
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                        timerInfoProvider
                                                            .notifier,
                                                      )
                                                          .pauseTimer();
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text(
                                                            '中断しますか？',
                                                          ),
                                                          content: const Text(
                                                            '現在の経過時間を記録してセッションを終了します。',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                                ref
                                                                    .read(
                                                                  timerInfoProvider
                                                                      .notifier,
                                                                )
                                                                    .resumeTimer();
                                                              },
                                                              child: const Text(
                                                                'キャンセル',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                                _showConcentrationModal(
                                                                  settings,
                                                                );
                                                              },
                                                              child: const Text(
                                                                '中断して記録',
                                                                style: TextStyle(
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.stop_rounded,
                                                      color: Colors.red,
                                                    ),
                                                    iconSize: 32,
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                      Colors.red.shade50,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    '中断',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          OutlinedButton(
                                            onPressed: () =>
                                                context.go('/Timersettings'),
                                            child: const Text(
                                              '設定を変更',
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // タブレット・PC向け（2カラム）
                      return Center(
                        child: SizedBox(
                          width: 900,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左カラム: タイマー情報
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 40),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 32,
                                      ),
                                      decoration: BoxDecoration(
                                        color: timerInfo.type == TimerType.focus
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: timerInfo.type == TimerType.focus
                                              ? Colors.red.shade200
                                              : Colors.green.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        timerStateText,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: timerInfo.type == TimerType.focus
                                              ? Colors.red.shade700
                                              : Colors.green.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Container(
                                      padding: const EdgeInsets.all(48),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            '残り時間',
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 64,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (timerInfo.type == TimerType.focus)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: LinearPercentIndicator(
                                          lineHeight: 8.0,
                                          percent:
                                          1 -
                                              timerInfo.remainingSeconds /
                                                  settings.focusTotalSeconds,
                                          backgroundColor: Colors.grey.shade300,
                                          progressColor: Colors.green,
                                          animation: true,
                                          animateFromLastPercent: true,
                                          alignment: MainAxisAlignment.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                              // 右カラム: 目標・サイクル・ボタン群
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 40),
                                    Container(
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
                                          Icon(Icons.flag, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: currentGoal.when(
                                              data: (goal) => CurrentGoalOverview(
                                                goalWithTasks: goal!,
                                              ),

                                              loading: () => Text(
                                                '目標を読み込み中...',
                                                style: TextStyle(
                                                  color: Colors.blue.shade200,
                                                ),
                                              ),
                                              error: (e, _) => Text(
                                                '目標の取得に失敗しました',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.repeat,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'サイクル ${timerInfo.currentCycle} / ${timerInfo.totalCycles}',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 60),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (timerInfo.state != TimerState.stopped)
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (timerInfo.state ==
                                                  TimerState.running) {
                                                ref
                                                    .read(timerInfoProvider.notifier)
                                                    .pauseTimer();
                                              } else if (timerInfo.state ==
                                                  TimerState.paused) {
                                                ref
                                                    .read(timerInfoProvider.notifier)
                                                    .resumeTimer();
                                              }
                                            },
                                            icon: Icon(
                                              timerInfo.state == TimerState.running
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                            ),
                                            label: Text(
                                              timerInfo.state == TimerState.running
                                                  ? '一時停止'
                                                  : '再開',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 20,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 32),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('タイマーを中断しますか？'),
                                                content: const Text(
                                                  '現在のセッションがリセットされます。',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context).pop(),
                                                    child: const Text('キャンセル'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      _showConcentrationModal(
                                                        settings,
                                                      );

                                                      ///中断
                                                    },
                                                    child: const Text('中断'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.stop),
                                          label: const Text('中断'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      width: 250,
                                      child: OutlinedButton(
                                        onPressed: () => context.go('/Timersettings'),
                                        child: const Text('設定を変更'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



}

class CurrentGoalOverview extends ConsumerWidget {
  final GoalWithTasks goalWithTasks;

  const CurrentGoalOverview({super.key, required this.goalWithTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = goalWithTasks.goal;
    final tasks = goalWithTasks.tasks;
    final dateFormat = DateFormat('yyyy/MM/dd');

    // 期限切れチェック
    final isOverdue =
        goal.limit.isBefore(DateTime.now()) && goal.completedAt == null;
    final limitColor = isOverdue ? Colors.red : Colors.grey[700];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ヘッダー部分（目標名・期限） ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.goal,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 期限バッジ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOverdue
                          ? Colors.red.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '期限 : ',
                        style: TextStyle(fontSize: 10, color: limitColor),
                      ),
                      Text(
                        dateFormat.format(goal.limit),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: limitColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 1),

            // --- タスク一覧部分 ---
            const SizedBox(height: 8),

            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'タスクが設定されていません',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...tasks.map(
                (task) => _buildTaskRow(context, ref, task, dateFormat),
              ),
          ],
        ),
      ),
    );
  }

  // タスク1行分の表示
  Widget _buildTaskRow(
    BuildContext context,
    WidgetRef ref,
    TaskData task,
    DateFormat dateFormat,
  ) {
    final isTaskOverdue =
        task.limit.isBefore(DateTime.now()) && !task.isCompleted;

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // チェックマーク部分
            Icon(
              task.isCompleted
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 22,
              color: task.isCompleted ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タスク名
                  Text(
                    task.task,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  // タスク期限
                  Text(
                    '期限: ${dateFormat.format(task.limit)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isTaskOverdue ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
return SingleChildScrollView(
                child: Container(
                  // 画面の高さ確保（スクロール可能だが、コンテンツが少ない時は中央に寄せるための制約）
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. 目標・タスク表示エリア (コンパクトな開閉式)
                      currentGoal.when(
                        data: (goalWithTasks) {
                          if (goalWithTasks == null) {
                            return const Text('目標なし',
                                style: TextStyle(color: Colors.grey));
                          }
                          return Card(
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.blue.shade100),
                            ),
                            child: ExpansionTile(
                              // --- 閉じた状態: コンパクト ---
                              shape: const Border(), // 区切り線を消す
                              collapsedShape: const Border(),
                              leading: const Icon(Icons.flag,
                                  color: Colors.blue, size: 24),
                              title: Text(
                                goalWithTasks.goal.goal,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                // 進捗率を簡易表示
                                "タスク: ${goalWithTasks.tasks.where((t) => t.isCompleted).length}/${goalWithTasks.tasks.length}完了済  期限: ${DateFormat('MM/dd').format(goalWithTasks.goal.limit)}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              childrenPadding: const EdgeInsets.all(16),
                              // --- 開いた状態: 詳細リスト ---
                              children: [
                                const Divider(),
                                if (goalWithTasks.tasks.isEmpty)
                                  const Text("タスクなし",
                                      style: TextStyle(color: Colors.grey))
                                else
                                  ...goalWithTasks.tasks.map((task) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          task.isCompleted
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          size: 18,
                                          color: task.isCompleted
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  task.task,
                                                  style: TextStyle(
                                                      decoration: task.isCompleted
                                                          ? TextDecoration
                                                          .lineThrough
                                                          : null,
                                                      color: task.isCompleted
                                                          ? Colors.grey
                                                          : Colors.black87),
                                                ),
                                                Text('期限: ${DateFormat('MM/dd').format(task.limit)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),

                                        ),
                                      ],
                                    ),
                                  )),
                              ],
                            ),
                          );
                        },
                        loading: () => Text(
                          '読み込み中...',
                          style: TextStyle(color: Colors.blue.shade200),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 20),

                      // 2. タイマー & サイクル表示エリア (Stackで重ねて表示)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // 背景の円グラフ (プログレス)
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: progress.clamp(0, 1.0),
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade100,
                              color: timerInfo.type == TimerType.focus
                                  ? Colors.redAccent
                                  : Colors.green,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          // 中央の情報
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 状態ラベル (集中 or 休憩)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: timerInfo.type == TimerType.focus
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  timerStateText, // Providerから取得したテキスト
                                  style: TextStyle(
                                    color: timerInfo.type == TimerType.focus
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // 残り時間（特大かつ等幅フォント）
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // サイクル情報
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.repeat,
                                      size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${timerInfo.currentCycle} / ${timerInfo.totalCycles} サイクル',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 3. 操作ボタンエリア (大きく押しやすく)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 再生・一時停止ボタン
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Column(
                              children: [
                                FloatingActionButton(
                                  onPressed: () {
                                    if (timerInfo.state == TimerState.running) {
                                      ref
                                          .read(timerInfoProvider.notifier)
                                          .pauseTimer();
                                    } else {
                                      // 停止中または一時停止中なら開始/再開
                                      if (timerInfo.state == TimerState.stopped) {
                                        ref
                                            .read(timerInfoProvider.notifier)
                                            .startTimer(settings);
                                      } else {
                                        ref
                                            .read(timerInfoProvider.notifier)
                                            .resumeTimer();
                                      }
                                    }
                                  },
                                  backgroundColor:
                                  timerInfo.state == TimerState.running
                                      ? Colors.orangeAccent
                                      : Colors.blueAccent,
                                  elevation: 4,
                                  child: Icon(
                                    timerInfo.state == TimerState.running
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(timerInfo.state == TimerState.running ? '一時停止' : '再開', ),
                              ],
                            )
                          ),
                          const SizedBox(width: 30),
                          // 中断ボタン (少し小さめ)
                          Column(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () {
                                  ref
                                      .read(timerInfoProvider.notifier)
                                      .pauseTimer();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('中断しますか？'),
                                      content:
                                      const Text('現在の経過時間を記録してセッションを終了します。'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              ref
                                                  .read(
                                                  timerInfoProvider.notifier)
                                                  .resumeTimer();
                                            },
                                            child: const Text('キャンセル')),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _showConcentrationModal( settings);
                                          },
                                          child: const Text('中断して記録',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.stop_rounded,
                                    color: Colors.red),
                                iconSize: 32,
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.shade50),
                              ),
                              const SizedBox(height: 4),
                              const Text('中断',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () => context.go('/Timersettings'),
                        child: const Text('設定を変更'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
 */
