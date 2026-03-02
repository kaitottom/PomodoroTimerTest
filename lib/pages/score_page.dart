/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class ScorePage extends ConsumerStatefulWidget {
  const ScorePage({super.key});

  @override
  ConsumerState<ScorePage> createState() => _ScorePageState();
}

  class _ScorePageState extends ConsumerState<ScorePage> {
  String _evaluation = "A";
  @override
  Widget build(BuildContext context) {
    final currentGoal = ref.watch(currentGoalProvider);

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
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            '現在の目標',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentGoal?.goal ?? 'なし',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '今回の達成度評価',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(),
                      const Text(
                        "[達成度評価法の選択]",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RadioListTile<String>(
                        title: Text("まとめて"),
                        value: "A",
                        groupValue: _evaluation,
                        onChanged: (value) {
                          setState(() {
                            _evaluation = "A";
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      RadioListTile<String>(
                        title: Text("一つずつ"),
                        value: "B",
                        groupValue: _evaluation,
                        onChanged: (value) {
                          setState(() {
                            _evaluation = "B";
                          });
                        },
                      ),
                      Divider(),
                      const SizedBox(height: 20),

                      // まとめて評価
                      AbsorbPointer(
                        absorbing: _evaluation == "A", // 一括評価時は無効化
                        child: Opacity(
                          opacity: _evaluation == "B" ? 0.4 : 1.0,
                          child: const Text("まとめて 達成度：\n目標リスト..."),
                        ),
                      ),
                      const Divider(height: 32),
                      AbsorbPointer(
                        absorbing: _evaluation == "B", // 個別評価時は無効化
                        child: Opacity(
                          opacity: _evaluation == "A" ? 0.4 : 1.0,
                          child: const Text(
                            "1つずつ \n目標リスト...達成度：\n目標リスト...達成度：\n目標リスト...達成度：",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // タブレット・PC向け（2カラム）
              return Center(child: SizedBox(width: 900, height: 600));
            }
          },
        ),
      ),
    );
  }
}
*/