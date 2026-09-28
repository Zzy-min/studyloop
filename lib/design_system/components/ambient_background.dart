import 'package:flutter/material.dart';
import '../colors.dart';

/// A quiet, non-interactive canvas shared by the main learning screens.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child, this.hero = false});

  final Widget child;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StudyLoopColors.background,
            hero ? const Color(0xFFEDF3E1) : const Color(0xFFF5F6EC),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _AmbientPainter(hero: hero)),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({required this.hero});
  final bool hero;

  @override
  void paint(Canvas canvas, Size size) {
    final wash = Paint()
      ..color = StudyLoopColors.primary.withValues(alpha: .045);
    if (hero) {
      canvas.drawCircle(Offset(-12, size.height * .43), 65, wash);
      canvas.drawOval(
        Rect.fromLTWH(
          -size.width * .2,
          size.height * .66,
          size.width * 1.4,
          size.height * .6,
        ),
        wash,
      );
    }
    final line = Paint()
      ..color = const Color(0xFFE8DFC2).withValues(alpha: .3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    final path = Path()..moveTo(size.width * .54, 0);
    path.cubicTo(size.width * .5, 95, size.width * .95, 30, size.width, 130);
    canvas.drawPath(path, line);
    if (hero) {
      for (final point in [
        Offset(size.width * .12, size.height * .23),
        Offset(size.width * .8, size.height * .17),
      ]) {
        final star = Path()
          ..moveTo(point.dx, point.dy - 7)
          ..quadraticBezierTo(
            point.dx + 1,
            point.dy - 1,
            point.dx + 6,
            point.dy,
          )
          ..quadraticBezierTo(
            point.dx + 1,
            point.dy + 1,
            point.dx,
            point.dy + 7,
          )
          ..quadraticBezierTo(
            point.dx - 1,
            point.dy + 1,
            point.dx - 6,
            point.dy,
          )
          ..quadraticBezierTo(
            point.dx - 1,
            point.dy - 1,
            point.dx,
            point.dy - 7,
          );
        canvas.drawPath(
          star,
          Paint()..color = StudyLoopColors.primary.withValues(alpha: .6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) => hero != oldDelegate.hero;
}
