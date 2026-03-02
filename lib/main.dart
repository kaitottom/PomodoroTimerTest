import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_timer/models/score.dart';
import 'package:pomo_timer/pages/draftevalation_page.dart';
import 'package:pomo_timer/pages/app_settings_page.dart';

import 'package:pomo_timer/pages/pages.dart';
import 'package:pomo_timer/widgets/concentration_bottomsheet.dart';

import 'data/database/daos/score_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 画面回転を縦固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final app = MyMainPage();
  final scope = ProviderScope(child: app);
  runApp(scope);
}


class MyMainPage extends ConsumerWidget {
  //StatelessWidget
  const MyMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/main',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final location = state.uri.toString();
            final isSettingsPage = location.startsWith('/settings');
            int currentIndex = 0;
            if (location.startsWith('/Timersettings') || location.startsWith('/Timer')) {
              currentIndex = 1;
            } else if (location.startsWith('/goal')) {
              currentIndex = 2;
            } else if (location.startsWith('/stats')) {
              currentIndex = 3;
            }

            return PopScope(
                canPop: false, // ← 戻る操作を内部では処理しない
              onPopInvokedWithResult: (didPop, result) {
                SystemNavigator.pop(); // ← アプリ終了
              },
            child: Scaffold(

              /*appBar: AppBar(
                title: const Text('ポモドーロタイマー'),
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.orange.shade800,
                // ポモドーロタイマーページの場合のみ設定ボタンを表示
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.go('/settings'),
                    tooltip: '設定',
                  ),
                ],
              ),

               */
              appBar: isSettingsPage
                  ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: const Text('設定画面'),
                backgroundColor: Colors.lightBlue.shade200,
                foregroundColor: Colors.blue.shade900,
              )
                  : AppBar(
                title: const Text('ポモドーロタイマー'),
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFFE8C957),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.push('/settings'),
                    tooltip: '設定',
                  ),
                ],
              ),

              body: child,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      context.go('/main');
                      break;
                    case 1:
                      context.go('/Timersettings');
                      break;
                    case 2:
                      context.go('/goal');
                      break;
                    case 3:
                      context.go('/stats');
                      break;
                  }
                },
                items: [
                  BottomNavigationBarItem(
                      icon:Image.asset(
                        'assets/images/home_iconbase.png',
                        width: 24,
                        height: 24,
                      ),
                      label: 'ホーム'),

                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/pomodoro_tomato.png',
                      width: 24,
                      height: 24,
                    ),

                    label: '設定',
                  ),
                  BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/images/goal_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      label: '目標'),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/stats_icon.png',
                      width: 24,
                      height: 24,
                    ),
                    label: '記録',
                  ),
                ],
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.orange.shade800,
                unselectedItemColor: Colors.grey,
              ),
            ),
            );
          },
          routes: [
            GoRoute(
              path: '/main',
              builder: (context, state) => const MainPage(),
            ),
            GoRoute(
              path: '/Timer',
              builder: (context, state) => const PomodoroTimerPage(),
            ),
            GoRoute(
              path: '/Timersettings',
              builder: (context, state) => const PomodoroSettingPage(),
            ),
            GoRoute(
              path: '/goal',
              builder: (context, state) => const GoalMainPage(),
              routes: [
                GoRoute(
                  path: 'new', // 目標goalの新規設定
                  builder: (context, state) => const GoalNewPage(), //{
                    //final fromReview =
                    //    state.uri.queryParameters['fromReview'] == 'true';
                    //return GoalNewPage(fromReview: fromReview);
                  //},
                ),
                /*GoRoute(
                  path: 'tasks', //目標へのタスクを入力や設定
                  builder: (context, state) => const GoalTasksPage(),
                ), */
                GoRoute(
                  path: 'review', //目標とタスクを全体的に確認
                  builder: (context, state) => const GoalReviewPage(),
                ),
                GoRoute(
                  path: 'edit', //既存の目標やタスクを変更、再設定
                  builder: (context, state) {
                    final from = state.uri.queryParameters['from']; // "review" が入る

                    return GoalEditPage(goalId: null, from: from);
                  },
                  routes: [
                    GoRoute(
                      path: ':goalId', //既存の目標やタスクを変更、再設定
                      builder: (context, state) {
                        final from = state.uri.queryParameters['from']; // "review" が入る

                        final idString = state.pathParameters['goalId'];
                        final goalId = int.tryParse(idString ?? '');
                        return GoalEditPage(goalId: goalId, from: from ?? 'main');
                      },
                    ),
                  ],
                  //builder: (context, state) => const GoalEditPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsPage(),
              routes: [
                GoRoute(
                  path: 'draftevaluation',
                  builder: (context, state) {
                    // 1. Mapとして受け取る
                    final args = state.extra as Map<String, dynamic>;

                    // 2. キーを指定して取り出す
                    final draft = args['draft'] as ScoreWithDetails;
                    //final concentration = args['concentration'] as int;
                    final reflectionData = args['reflectionData'] as ReflectionData;

                    return DraftEvaluationPage(
                      draft: draft,
                      //concentration: concentration,
                      reflectionData: reflectionData,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/evaluation',
              builder: (context, state) { //=> const EvaluationPage(),
              final data = state.extra as SessionData;

              return EvaluationPage(sessionData: data);
                },
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const AppSettingsPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }
}
