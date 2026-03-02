import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../models/timer_info.dart';
import '../providers/app_settings_provider.dart';
import '../providers/notification_provider.dart';

class AppSettingsPage extends ConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final notificationNotifier = ref.read(notificationStyleProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // 通知設定セクション
              _buildSectionHeader('通知設定'),
              const SizedBox(height: 8),
              _buildNotificationStyleCard(context, settings, settingsNotifier, notificationNotifier),
              
              const SizedBox(height: 24),
              // タイマーのバックグラウンド設定
              _buildSectionHeader('タイマーのバックグラウンド再生設定'),
              const SizedBox(height: 8),
              _buildBackgroundTimerCard(settings, settingsNotifier),

              const SizedBox(height: 24),

              // 休憩画面設定セクション
              _buildSectionHeader('休憩画面設定'),
              const SizedBox(height: 8),
              _buildBreakScreenCard(context, settings, settingsNotifier),
              
              const SizedBox(height: 24),
              
              // 将来の拡張用: キャラクター設定セクション（プレースホルダー）
              _buildSectionHeader('キャラクター設定', isComingSoon: true),
              const SizedBox(height: 8),
              _buildComingSoonCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isComingSoon = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
        ),
        if (isComingSoon) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '準備中',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationStyleCard(
    BuildContext context,
    AppSettings settings,
    AppSettingsNotifier settingsNotifier,
    NotificationStyleNotifier notificationNotifier,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通知の種類',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...NotificationStyle.values.map((style) {
              return RadioListTile<NotificationStyle>(
                title: Text(_getNotificationStyleLabel(style)),
                value: style,
                groupValue: settings.notificationStyle,
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.setNotificationStyle(value);
                    notificationNotifier.setStyle(value);
                  }
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakScreenCard(
    BuildContext context,
    AppSettings settings,
    AppSettingsNotifier settingsNotifier,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 休憩画面表示のON/OFF
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '休憩画面を表示する',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: settings.showBreakScreen,
                  onChanged: (value) {
                    settingsNotifier.setShowBreakScreen(value);
                  },
                  activeColor: Colors.orange.shade800,
                ),
              ],
            ),
            
            if (settings.showBreakScreen) ...[
              const Divider(height: 24),
              const Text(
                '背景の種類',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...BreakBackgroundType.values.map((type) {
                return RadioListTile<BreakBackgroundType>(
                  title: Text(_getBackgroundTypeLabel(type)),
                  subtitle: Text(_getBackgroundTypeDescription(type)),
                  value: type,
                  groupValue: settings.breakBackgroundType,
                  onChanged: (value) {
                    if (value != null) {
                      settingsNotifier.setBreakBackgroundType(value);
                    }
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'キャラクター設定機能は準備中です',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundTimerCard(AppSettings settings, AppSettingsNotifier settingsNotifier) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text(
          'バックグラウンド実行',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('アプリを閉じてもタイマーを継続します'),
        secondary: Icon(Icons.play_arrow, color: Colors.orange.shade600),
        value: settings.isBackgroundEnabled, // 1で追加したフィールド
        onChanged: (bool value) {
          settingsNotifier.setIsBackgroundEnabled(value); // 2で追加したメソッド
        },
        activeColor: Colors.orange,
      ),
    );
  }

  String _getNotificationStyleLabel(NotificationStyle style) {
    switch (style) {
      case NotificationStyle.silent:
        return '無音';
      case NotificationStyle.vibration:
        return '振動';
      case NotificationStyle.sound:
        return '音';
      case NotificationStyle.both:
        return '振動 + 音';
    }
  }

  String _getBackgroundTypeLabel(BreakBackgroundType type) {
    switch (type) {
      case BreakBackgroundType.forest:
        return '森';
      case BreakBackgroundType.sea:
        return '海';
      case BreakBackgroundType.onsen:
        return '温泉';
    }
  }

  String _getBackgroundTypeDescription(BreakBackgroundType type) {
    switch (type) {
      case BreakBackgroundType.forest:
        return '森の風景を表示します';
      case BreakBackgroundType.sea:
        return '海の風景を表示します';
      case BreakBackgroundType.onsen:
        return '温泉の風景を表示します';
    }
  }
}

