import 'package:flutter/material.dart';

class CardPainter extends CustomPainter {
  CardPainter({required this.isFront});

  final bool isFront;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isFront
            ? const [Color(0xFF202124), Color(0xFF3B3F59)]
            : const [Color(0xFF101114), Color(0xFF23272B)],
      ).createShader(Offset.zero & size);

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );
    canvas.drawRRect(rect, paint);

    // Soft glow adds depth behind the card body.
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withOpacity(0.16), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: size.topRight(Offset(-40, 40)),
              radius: size.width * 0.7,
            ),
          );
    canvas.drawRRect(rect.deflate(1), glowPaint);

    if (isFront) {
      _drawFrontDetails(canvas, size);
    } else {
      _drawBackDetails(canvas, size);
    }
  }

  void _drawFrontDetails(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (var i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 16), Offset(x, size.height - 16), gridPaint);
    }

    for (var i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), gridPaint);
    }
  }

  void _drawBackDetails(Canvas canvas, Size size) {
    final stripePaint = Paint()..color = const Color(0xFF090909);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.16, size.width, size.height * 0.16),
        const Radius.circular(8),
      ),
      stripePaint,
    );

    final signaturePaint = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.46,
          size.width * 0.62,
          size.height * 0.18,
        ),
        const Radius.circular(10),
      ),
      signaturePaint,
    );

    final cvvPaint = Paint()..color = Colors.black.withOpacity(0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.74,
          size.height * 0.46,
          size.width * 0.18,
          size.height * 0.18,
        ),
        const Radius.circular(10),
      ),
      cvvPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CardPainter oldDelegate) {
    return oldDelegate.isFront != isFront;
  }
}
