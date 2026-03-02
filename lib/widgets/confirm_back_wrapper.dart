
import 'package:flutter/material.dart';

class ConfirmBackWrapper extends StatefulWidget {
  final Widget child;
  final String? message;
  final VoidCallback onConfirmPop; // 戻り先操作をここに

  const ConfirmBackWrapper({
    super.key,
    required this.child,
    required this.onConfirmPop,
    this.message,
  });

  @override
  State<ConfirmBackWrapper> createState() => ConfirmBackWrapperState();
}

class ConfirmBackWrapperState extends State<ConfirmBackWrapper> {
  bool _allowNextPop = false;

  /// 完了ボタンなどで「確認なしで戻す」場合に呼ぶ
  void allowNextPop() {
    setState(() => _allowNextPop = true);
  }

  Future<bool> _showConfirmExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // 後ろ画面が勝手に pop されるのを防ぐ
      builder: (dialogContext) => AlertDialog(
        title: const Text('確認'),
        content: Text(widget.message ?? '入力内容が失われます。戻ってよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(true),
            child: const Text('戻る'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ← 常に false にして戻り操作は全て onPop で制御
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // すでに pop 済みなら何もしない

        if (_allowNextPop) {
          Navigator.of(context).pop(); // 完了操作で直接 pop
          return;
        }

        final shouldExit = await _showConfirmExitDialog(context);
        if (shouldExit && mounted) {
          widget.onConfirmPop(); // ← 戻り先ルート処理をここで安全に呼ぶ
        }
      },
      child: widget.child,
    );
  }
}

