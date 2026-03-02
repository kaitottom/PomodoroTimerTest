import 'package:flutter/material.dart';

/// 振り返り情報を含むコールバック用のデータクラス
class ReflectionData {
  final int concentration; // 集中度（0-100）
  final String? goodPoints; // 良かった点
  final String? improvementPoints; // 改善点
  final String? futurePlans; // 今後の方針

  const ReflectionData({
    required this.concentration,
    this.goodPoints,
    this.improvementPoints,
    this.futurePlans,
  });
}

class ConcentrationBottomSheet extends StatefulWidget {
  final void Function(ReflectionData) onConfirm; // 集中度と振り返り情報を返す
  final VoidCallback onLater;
  final VoidCallback onSkip;

  const ConcentrationBottomSheet({
    super.key,
    required this.onConfirm,
    required this.onLater,
    required this.onSkip,
  });

  @override
  State<ConcentrationBottomSheet> createState() => _ConcentrationBottomSheetState();
}

class _ConcentrationBottomSheetState extends State<ConcentrationBottomSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // 1ページ目: 集中度評価
  int _selectedLevel = 5;
  
  // 2ページ目: 振り返り入力
  final TextEditingController _goodPointsController = TextEditingController();
  final TextEditingController _improvementPointsController = TextEditingController();
  final TextEditingController _futurePlansController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _goodPointsController.dispose();
    _improvementPointsController.dispose();
    _futurePlansController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 最終ページで確定
      widget.onConfirm(ReflectionData(
        concentration: _selectedLevel * 10,
        goodPoints: _goodPointsController.text.trim().isEmpty 
            ? null 
            : _goodPointsController.text.trim(),
        improvementPoints: _improvementPointsController.text.trim().isEmpty 
            ? null 
            : _improvementPointsController.text.trim(),
        futurePlans: _futurePlansController.text.trim().isEmpty 
            ? null 
            : _futurePlansController.text.trim(),
      ));
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ページインジケーター
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPageIndicator(0, '集中度'),
                  const SizedBox(width: 8),
                  _buildPageIndicator(1, '振り返り'),
                ],
              ),
              const SizedBox(height: 16),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildConcentrationPage(),
                    _buildReflectionPage(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ボタン群
              Row(
                children: [
                  if (_currentPage == 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSkip,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("記録をつけない/削除"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onLater,
                        child: const Text("後で評価"),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goToPreviousPage,
                        child: const Text("戻る"),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentPage == 0 ? "次へ" : "評価する"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageIndex, String label) {
    final isActive = _currentPage == pageIndex;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange.shade800 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildConcentrationPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '集中度を評価してください',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        Text(
          'レベル: $_selectedLevel / 10',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Slider(
          value: _selectedLevel.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.orange,
          label: '$_selectedLevel',
          onChanged: (value) => setState(() => _selectedLevel = value.toInt()),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              _getLevelDescription(_selectedLevel),
              style: TextStyle(
                fontSize: 15,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '振り返りを記録してください',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '任意項目です。記入しなくても次へ進めます。',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 良かった点
          _buildTextField(
            controller: _goodPointsController,
            label: '良かった点（感想）',
            hint: '今回のセッションで良かった点を記入してください',
            icon: Icons.thumb_up,
            color: Colors.green,
          ),
          const SizedBox(height: 16),

          // 改善点
          _buildTextField(
            controller: _improvementPointsController,
            label: '改善点',
            hint: '次回改善したい点を記入してください',
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),

          // 今後の方針
          _buildTextField(
            controller: _futurePlansController,
            label: '今後の方針',
            hint: '次回に向けた方針や目標を記入してください',
            icon: Icons.lightbulb,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.shade600, width: 2),
            ),
            filled: true,
            fillColor: color.shade50,
          ),
        ),
      ],
    );
  }

  String _getLevelDescription(int level) {
    if (level <= 2) return '全く集中できなかった';
    if (level <= 4) return 'あまり集中できなかった';
    if (level <= 6) return '普通だった';
    if (level <= 8) return 'よく集中できた';
    return '非常に集中できた！';
  }
}
