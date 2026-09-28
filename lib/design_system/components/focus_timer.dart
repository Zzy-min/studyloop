import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../colors.dart';
import '../radius.dart';
import '../typography.dart';
import 'corgi_portrait.dart';

class FocusTimerWidget extends StatelessWidget {
  const FocusTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalPlannedSeconds,
    required this.isRunning,
    required this.onTogglePlayPause,
    this.corgiState = DogState.focusing,
    this.pauseLabel = '暂停',
    this.resumeLabel = '继续',
  });

  final int remainingSeconds;
  final int totalPlannedSeconds;
  final bool isRunning;
  final VoidCallback onTogglePlayPause;
  final DogState corgiState;
  final String pauseLabel;
  final String resumeLabel;

  @override
  Widget build(BuildContext context) {
    final progress = totalPlannedSeconds > 0
        ? (remainingSeconds / totalPlannedSeconds).clamp(0.0, 1.0)
        : 1.0;

    final minutes = (remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: math.min(constraints.maxWidth, 360),
            height: math.min(constraints.maxWidth, 360),
            child: FittedBox(
              child: SizedBox(
                width: 340,
                height: 340,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Ring
                    CustomPaint(
                      size: const Size(340, 340),
                      painter: _TimerRingPainter(
                        progress: progress,
                        ringColor: StudyLoopColors.primary,
                        backgroundColor: const Color(0xFFB8D2AB),
                        strokeWidth: 14.0,
                      ),
                    ),

                    // Content inside ring
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Three subtle dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB5C6B7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB5C6B7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB5C6B7),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        CorgiPortrait(
                          state: corgiState,
                          size: CorgiPortraitSize.timer,
                        ),
                        const SizedBox(height: 6),

                        // Digital Timer
                        Text(
                          '$minutes:$seconds',
                          style: StudyLoopTypography.timerDigits.copyWith(
                            fontSize: 52,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Pause / Resume pill button
                        InkWell(
                          onTap: onTogglePlayPause,
                          borderRadius: StudyLoopRadius.borderPill,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: StudyLoopColors.primaryLight,
                              borderRadius: StudyLoopRadius.borderPill,
                              border: Border.all(color: StudyLoopColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isRunning
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 16,
                                  color: StudyLoopColors.primaryDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isRunning ? pauseLabel : resumeLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: StudyLoopColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color ringColor;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc
    final activePaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
