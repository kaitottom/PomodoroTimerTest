import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingCard extends StatefulWidget {
  final String title;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Function(String) onChanged;

  const SettingCard({
    super.key,
    required this.title,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
  });

  @override
  State<SettingCard> createState() => _SettingCardState();
}

class _SettingCardState extends State<SettingCard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();

    // フォーカス状態を監視して、入力中フラグを管理
    _focusNode.addListener(() {
      setState(() {
        _isEditing = _focusNode.hasFocus;
        if (!_isEditing) {
          // 入力が終わった瞬間に、最新の数値をコントローラーに同期
          _controller.text = widget.value.toString();
        }
      });
    });
  }

  @override
  void didUpdateWidget(SettingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 入力中（フォーカスがある時）は、外部からの値更新をコントローラーに反映させない
    // これにより、入力中に勝手に文字が書き換わるのを防ぎます
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isEditing ? Colors.orange.shade200 : Colors.grey.shade100),
        boxShadow: [
          if (_isEditing)
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 2,
            )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _HoldableButton(
                  icon: Icons.remove_rounded,
                  onPressed: widget.onDecrement,
                ),
                SizedBox(
                  width: 60, // 入力しやすいよう少し幅を広げました
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    // 数字のみ許可して入力をスムーズに
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      // 入力された瞬間に親に通知するが、コントローラーの文字は弄らない
                      widget.onChanged(val);
                    },
                    onSubmitted: (val) {
                      _focusNode.unfocus(); // キーボードを閉じる
                    },
                  ),
                ),
                _HoldableButton(
                  icon: Icons.add_rounded,
                  onPressed: widget.onIncrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 長押し対応ボタン（デザインは上側のコードを継承）
class _HoldableButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HoldableButton({required this.icon, required this.onPressed});

  @override
  State<_HoldableButton> createState() => _HoldableButtonState();
}

class _HoldableButtonState extends State<_HoldableButton> {
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        HapticFeedback.lightImpact();
        widget.onPressed();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startTimer(),
      onLongPressEnd: (_) => _stopTimer(),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(widget.icon, size: 22, color: Colors.blueGrey.shade400),
      ),
    );
  }
}
