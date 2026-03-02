import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeSettingCard extends StatelessWidget {
  final String title;
  final int minutes;
  final int seconds;
  final int maxMinutes;
  final int maxSeconds;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;

  const TimeSettingCard({
    super.key,
    required this.title,
    required this.minutes,
    required this.seconds,
    this.maxMinutes = 100,
    this.maxSeconds = 59,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SafeScrollUnit(
                value: minutes,
                label: 'MIN',
                max: maxMinutes,
                onChanged: onMinutesChanged,
                title: '分を選択',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w200,
                    color: Colors.orange.shade300,
                  ),
                ),
              ),
              _SafeScrollUnit(
                value: seconds,
                label: 'SEC',
                max: maxSeconds,
                onChanged: onSecondsChanged,
                title: '秒を選択',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafeScrollUnit extends StatelessWidget {
  final int value;
  final String label;
  final int max;
  final ValueChanged<int> onChanged;
  final String title;

  const _SafeScrollUnit({
    required this.value,
    required this.label,
    required this.max,
    required this.onChanged,
    required this.title,
  });

  // 下からスクロールピッカーを表示する関数
  void _showModalPicker(BuildContext context) {
    HapticFeedback.heavyImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: value),
                  itemExtent: 45,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    onChanged(index);
                  },
                  children: List.generate(
                    max + 1,
                        (index) => Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: const TextStyle(fontSize: 28, fontFamily: 'RobotoMono'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('完了'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CustomRepeatButton(
          icon: Icons.add_circle_outline,
          onPressed: () {
            if (value < max) onChanged(value + 1);
          },
        ),
        const SizedBox(height: 8),
        // 数字部分：タップでモーダルを表示
        GestureDetector(
          onTap: () => _showModalPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w300,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 8),
        _CustomRepeatButton(
          icon: Icons.remove_circle_outline,
          onPressed: () {
            if (value > 0) onChanged(value - 1);
          },
        ),
      ],
    );
  }
}

/// 長押しで連続動作し、dispose後も安全なボタン (元の機能を維持)
class _CustomRepeatButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CustomRepeatButton({required this.icon, required this.onPressed});

  @override
  State<_CustomRepeatButton> createState() => _CustomRepeatButtonState();
}

class _CustomRepeatButtonState extends State<_CustomRepeatButton> {
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (mounted) {
        HapticFeedback.lightImpact();
        widget.onPressed();
      } else {
        t.cancel();
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, size: 28, color: Colors.blueGrey.shade300),
      ),
    );
  }
}

/**
    import 'dart:async';

    import 'package:flutter/cupertino.dart';

    import 'package:flutter/material.dart';

    import 'package:flutter/services.dart';



    class TimeSettingCard extends StatelessWidget {

    final String title;

    final int minutes;

    final int seconds;

    final int maxMinutes;

    final int maxSeconds;

    final ValueChanged<int> onMinutesChanged;

    final ValueChanged<int> onSecondsChanged;



    const TimeSettingCard({

    super.key,

    required this.title,

    required this.minutes,

    required this.seconds,

    this.maxMinutes = 100,

    this.maxSeconds = 59,

    required this.onMinutesChanged,

    required this.onSecondsChanged,

    });



    @override

    Widget build(BuildContext context) {

    return Container(

    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),

    decoration: BoxDecoration(

    color: Colors.white,

    borderRadius: BorderRadius.circular(24),

    boxShadow: [

    BoxShadow(

    color: Colors.black.withOpacity(0.05),

    blurRadius: 15,

    offset: const Offset(0, 8),

    ),

    ],

    border: Border.all(color: Colors.grey.shade100),

    ),

    child: Column(

    mainAxisSize: MainAxisSize.min,

    children: [

    Text(

    title,

    style: TextStyle(

    fontSize: 15,

    fontWeight: FontWeight.w600,

    color: Colors.blueGrey.shade800,

    letterSpacing: 1.2,

    ),

    ),

    const SizedBox(height: 12),

    Row(

    mainAxisAlignment: MainAxisAlignment.center,

    children: [

    _SafeScrollUnit(

    value: minutes,

    label: 'MIN',

    max: maxMinutes,

    onChanged: onMinutesChanged,

    ),

    Padding(

    padding: const EdgeInsets.symmetric(horizontal: 10),

    child: Text(

    ':',

    style: TextStyle(

    fontSize: 32,

    fontWeight: FontWeight.w200,

    color: Colors.orange.shade300,

    ),

    ),

    ),

    _SafeScrollUnit(

    value: seconds,

    label: 'SEC',

    max: maxSeconds,

    onChanged: onSecondsChanged,

    ),

    ],

    ),

    ],

    ),

    );

    }

    }



    class _SafeScrollUnit extends StatefulWidget {

    final int value;

    final String label;

    final int max;

    final ValueChanged<int> onChanged;



    const _SafeScrollUnit({

    required this.value,

    required this.label,

    required this.max,

    required this.onChanged,

    });



    @override

    State<_SafeScrollUnit> createState() => _SafeScrollUnitState();

    }



    class _SafeScrollUnitState extends State<_SafeScrollUnit> {

    late FixedExtentScrollController _controller;

    bool _isManualScrolling = false;



    @override

    void initState() {

    super.initState();

    _controller = FixedExtentScrollController(initialItem: widget.value);

    }



    @override

    void didUpdateWidget(_SafeScrollUnit oldWidget) {

    super.didUpdateWidget(oldWidget);

    // ボタン操作などで値が変わった場合、スクロール位置を同期させる

    if (oldWidget.value != widget.value && !_isManualScrolling) {

    _syncController();

    }

    }



    void _syncController() {

    // UIの描画が終わってから安全にスクロールを実行（エラー防止）

    WidgetsBinding.instance.addPostFrameCallback((_) {

    if (_controller.hasClients) {

    _controller.animateToItem(

    widget.value,

    duration: const Duration(milliseconds: 200),

    curve: Curves.easeOut,

    );

    }

    });

    }



    @override

    void dispose() {

    _controller.dispose();

    super.dispose();

    }



    @override

    Widget build(BuildContext context) {

    return Column(

    children: [

    _CustomRepeatButton(

    icon: Icons.add_circle_outline,

    onPressed: () {

    if (widget.value < widget.max) widget.onChanged(widget.value + 1);

    },

    ),

    SizedBox(

    height: 120,

    width: 80,

    child: NotificationListener<ScrollNotification>(

    onNotification: (notification) {

    if (notification is ScrollStartNotification) _isManualScrolling = true;

    if (notification is ScrollEndNotification) _isManualScrolling = false;

    return false;

    },

    child: CupertinoPicker(

    scrollController: _controller,

    itemExtent: 45,

    onSelectedItemChanged: (index) {

    if (_isManualScrolling) {

    HapticFeedback.selectionClick();

    widget.onChanged(index);

    }

    },

    // 数字部分をタップしたときも反応しやすくする設定

    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(

    background: Colors.orange.withOpacity(0.05),

    ),

    children: List.generate(

    widget.max + 1,

    (index) => Center(

    child: Text(

    index.toString().padLeft(2, '0'),

    style: const TextStyle(

    fontSize: 32,

    fontWeight: FontWeight.w300,

    fontFamily: 'RobotoMono',

    ),

    ),

    ),

    ),

    ),

    ),

    ),

    Text(

    widget.label,

    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400),

    ),

    _CustomRepeatButton(

    icon: Icons.remove_circle_outline,

    onPressed: () {

    if (widget.value > 0) widget.onChanged(widget.value - 1);

    },

    ),

    ],

    );

    }

    }



    /// 長押しで連続動作し、dispose後も安全なボタン

    class _CustomRepeatButton extends StatefulWidget {

    final IconData icon;

    final VoidCallback onPressed;



    const _CustomRepeatButton({required this.icon, required this.onPressed});



    @override

    State<_CustomRepeatButton> createState() => _CustomRepeatButtonState();

    }



    class _CustomRepeatButtonState extends State<_CustomRepeatButton> {

    Timer? _timer;



    void _startTimer() {

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {

    if (mounted) {

    HapticFeedback.lightImpact();

    widget.onPressed();

    } else {

    t.cancel();

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

    padding: const EdgeInsets.all(8),

    decoration: BoxDecoration(

    color: Colors.grey.shade50,

    shape: BoxShape.circle,

    ),

    child: Icon(widget.icon, size: 28, color: Colors.blueGrey.shade300),

    ),

    );

    }

    }
 **/
