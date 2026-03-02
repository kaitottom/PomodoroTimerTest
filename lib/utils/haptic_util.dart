import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void playCompletionHaptic() async {
  for(int i = 0; i < 2; i++){
  await HapticFeedback.mediumImpact();
  await Future.delayed(const Duration(milliseconds: 120));
  await HapticFeedback.heavyImpact();
  }
}


void playGentleBell() {
  final player = AudioPlayer();
  player.play(AssetSource('sounds/beep.mp3'));
}
