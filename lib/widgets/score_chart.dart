import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database/daos/score_dao.dart'; // ScoreWithDetailsのため

// 表示する指標の種類
enum ChartMetric {
  score,
  duration,
  concentration,
}

class ScoreChart extends StatefulWidget {
  final List<ScoreWithDetails> scores;

  const ScoreChart({super.key, required this.scores});

  @override
  State<ScoreChart> createState() => _ScoreChartState();
}

class _ScoreChartState extends State<ScoreChart> {
  // 現在選択されている指標（デフォルトはスコア）
  ChartMetric _currentMetric = ChartMetric.score;

  @override
  Widget build(BuildContext context) {
    if (widget.scores.isEmpty) {
      return const Center(child: Text("データがありません"));
    }

    // 日付順にソート
    final sortedScores = List.of(widget.scores)
      ..sort((a, b) => a.score.startedAt.compareTo(b.score.startedAt));

    // X軸の範囲計算（ミリ秒単位）
    final double minX = sortedScores.first.score.startedAt.millisecondsSinceEpoch.toDouble();
    final double maxX = sortedScores.last.score.startedAt.millisecondsSinceEpoch.toDouble();
    final double padding = (maxX - minX) * 0.05;
    // 3点表示（始点・中間・終点）にするためのインターバル計算
    // 差分が0（データ1件のみ）の場合は1.0にしてエラー回避
    //final double xInterval = (maxX - minX) > 0 ? (maxX - minX) / 2 : 1.0;

    // --- Y軸の最大値計算（動的設定用） ---
    // 現在の指標におけるデータの最大値を取得
    double currentMaxY = 0;
    for (var s in sortedScores) {
      final val = _getValueForMetric(s, _currentMetric);
      if (val > currentMaxY) currentMaxY = val;
    }
    // データが全部0だった場合や、余裕を持たせるための補正
    // スコア・時間はデータの最大値の1.2倍程度にする（グラフの天井に張り付かないように）
    // ただし、集中度は100固定なので後述の設定で無視されます
    final double adaptiveMaxY = currentMaxY == 0 ? 10 : currentMaxY * 1.2;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. 指標切り替えボタン ---
        SegmentedButton<ChartMetric>(
          segments: const [
            ButtonSegment(value: ChartMetric.score, label: Text('スコア')),
            ButtonSegment(value: ChartMetric.duration, label: Text('時間')),
            ButtonSegment(value: ChartMetric.concentration, label: Text('集中度')),
          ],
          selected: {_currentMetric},
          onSelectionChanged: (Set<ChartMetric> newSelection) {
            setState(() {
              _currentMetric = newSelection.first;
            });
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 16),

        // --- 2. 単位と軸の説明 ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMetricLabel(_currentMetric)} (${_getUnit(_currentMetric)})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
              // 横軸ラベルはグラフの右下にAxisTitleとして配置しますが、ここにも書くなら以下
              // const Text('横軸: 日時', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- 3. グラフ本体 ---
        AspectRatio(
          aspectRatio: 1.5,
          child: LineChart(
            LineChartData(
              // X軸の範囲指定（パディングを含めないときれいに端まで描画される）
              minX: minX - 0.1 * padding,
              maxX: maxX + padding,
              // --- Y軸の範囲指定（ここを修正） ---
              minY: 0, // 全ての指標で最小値は0
              maxY: _currentMetric == ChartMetric.concentration
                  ? 100 // 集中度の場合は最大100固定
                  : adaptiveMaxY, // スコア・時間の場合は計算した最大値を使用

              // タップ時の表示設定（ツールチップ）
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.blueGrey.withValues(alpha: 0.9),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      final dateStr = DateFormat('M/d HH:mm').format(date);
                      return LineTooltipItem(
                        // 日時 + 改行 + 値 + 単位
                        '$dateStr\n${spot.y.toStringAsFixed(0)} ${_getUnit(_currentMetric)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),

              // グリッド線設定
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false, // 縦線は消してスッキリさせる
                horizontalInterval: null, // 自動計算
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),

              // 枠線設定
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                  top: BorderSide.none,
                  right: BorderSide.none,
                ),
              ),

              // 軸ラベル設定
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                // X軸（日時）の設定
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text("期間", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                  axisNameSize: 20,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    //interval: (maxX - minX) > 0 ? (maxX - minX) : 1.0,
                    //xInterval, // ★重要: ここで計算したインターバルを指定
                    getTitlesWidget: (value, meta) {
                      // データがない、またはインターバル計算不能な場合は非表示
                      if (minX == maxX) return const SizedBox.shrink();

                      // 日付フォーマット
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      // 期間が長い場合は日付のみ、短い場合は時間も含めるなどの分岐も可能
                      // 今回は一律で見やすいフォーマットに
                      String text = DateFormat('M/d\nHH:mm').format(date);
                      // 3点（始点・中間・終点）の判定
                      // 浮動小数点の誤差を考慮して、近似値で判定
                      //final isStart = (value - minX).abs() < 1000;
                      //final isEnd = (value - maxX).abs() < 1000;
                      //final isMiddle = (value - (minX + xInterval)).abs() < (xInterval * 0.1);

                      final tolerance = (maxX - minX) * 0.01;

                      final isStart = (value - minX).abs() <= tolerance;
                      final isEnd = (value - maxX).abs() <= tolerance;

                      // ★ 中間地点を表示したい場合は以下を有効化
                      final isMiddle = (value - (minX + (maxX - minX)/2)).abs() <= tolerance;
                      // 始点、中間、終点 付近のみラベルを表示
                      if (isStart || isEnd || isMiddle) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Y軸（値）の設定
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // 数値が入る幅を確保
                    getTitlesWidget: (value, meta) {
                      // 数値が整数になるように表示
                      if ((value - value.roundToDouble()).abs() > 0.01) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
              ),

              // データのプロット
              lineBarsData: [
                LineChartBarData(
                  spots: sortedScores.map((s) {
                    final x = s.score.startedAt.millisecondsSinceEpoch.toDouble();
                    final y = _getValueForMetric(s, _currentMetric);
                    return FlSpot(x, y);
                  }).toList(),
                  isCurved: false, // 直線で結ぶ
                  color: _getColorForMetric(_currentMetric),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: sortedScores.length <= 50),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _getColorForMetric(_currentMetric).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 指標に応じた値を取得
  double _getValueForMetric(ScoreWithDetails data, ChartMetric metric) {
    switch (metric) {
      case ChartMetric.score:
        return data.score.totalScore;
      case ChartMetric.duration:
        return data.score.totalMinutes.toDouble();
      case ChartMetric.concentration:
        return data.score.concentrationLevel.toDouble();
    }
  }

  // 指標に応じた色を取得
  Color _getColorForMetric(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.score:
        return Colors.orange;
      case ChartMetric.duration:
        return Colors.blue;
      case ChartMetric.concentration:
        return Colors.green;
    }
  }

  // 指標の表示名を取得
  String _getMetricLabel(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.score:
        return 'スコア';
      case ChartMetric.duration:
        return '集中時間';
      case ChartMetric.concentration:
        return '集中度';
    }
  }

  // 指標の単位を取得
  String _getUnit(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.score:
        return 'pt';
      case ChartMetric.duration:
        return 'min';
      case ChartMetric.concentration:
        return '%'; // または 'Lv'
    }
  }
}
