import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../colors.dart';
import 'cards.dart';

class PatternCardWidget extends StatelessWidget {
  const PatternCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconData,
    this.iconColor = StudyLoopColors.primary,
    this.iconBgColor = StudyLoopColors.primaryLight,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return StudyCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: StudyLoopColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: StudyLoopColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: StudyLoopColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 76,
            height: 76,
            child: CustomPaint(
              painter: _PatternIllustration(
                sun: iconData == Icons.wb_sunny_rounded,
                color: iconColor,
                background: iconBgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternIllustration extends CustomPainter {
  const _PatternIllustration({
    required this.sun,
    required this.color,
    required this.background,
  });
  final bool sun;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      36,
      Paint()..color = background.withValues(alpha: .6),
    );
    if (sun) {
      canvas.drawCircle(
        center + const Offset(0, 7),
        13,
        Paint()..color = const Color(0xFFF5C56E),
      );
      final ray = Paint()
        ..color = const Color(0xFFEFB653)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          center + const Offset(0, 7) + direction * 20,
          center + const Offset(0, 7) + direction * 25,
          ray,
        );
      }
    } else {
      canvas.drawCircle(
        center,
        24,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final hand = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6;
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(center + direction * 19, center + direction * 21, hand);
      }
      canvas.drawLine(center, center + const Offset(0, -14), hand);
      canvas.drawLine(center, center + const Offset(9, 5), hand);
      canvas.drawCircle(center, 2, Paint()..color = color);
    }
    canvas.drawOval(
      Rect.fromLTWH(1, 65, 46, 14),
      Paint()..color = const Color(0xFFDDE9D1),
    );
    canvas.drawOval(
      Rect.fromLTWH(32, 61, 47, 21),
      Paint()..color = const Color(0xFFB6CCA4),
    );
  }

  @override
  bool shouldRepaint(_PatternIllustration oldDelegate) =>
      oldDelegate.sun != sun ||
      oldDelegate.color != color ||
      oldDelegate.background != background;
}

class DonutDistributionCard extends StatelessWidget {
  const DonutDistributionCard({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<DonutSliceData> items;

  @override
  Widget build(BuildContext context) {
    return StudyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: StudyLoopColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 96,
                height: 96,
                child: CustomPaint(painter: _DonutChartPainter(items: items)),
              ),
              const SizedBox(width: 24),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in items) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: StudyLoopColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${(item.percentage * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                color: StudyLoopColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutSliceData {
  const DonutSliceData({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final double percentage;
  final Color color;
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.items});

  final List<DonutSliceData> items;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 18.0;

    double startAngle = -math.pi / 2;

    for (final slice in items) {
      final sweepAngle = 2 * math.pi * slice.percentage;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
