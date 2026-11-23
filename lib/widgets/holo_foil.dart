import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A holographic foil laid over a card face: rainbow bands and a bright spot
/// of light that slide across the card as it tilts, over a fine pattern of
/// diffraction lines that shimmer at a different speed.
///
/// [offset] is the tilt, from -1 to 1 on each axis. It blends with the card
/// painted beneath it, so it must sit in the same layer as the card face
/// (no RepaintBoundary or Opacity in between).
class HoloFoil extends StatelessWidget {
  const HoloFoil({
    super.key,
    required this.offset,
    this.intensity = 1,
    this.borderRadius = 24,
  });

  final Offset offset;

  /// From 0 (no foil) to 1 (full strength).
  final double intensity;
  final double borderRadius;

  /// The strength at rest. Tilting adds up to the rest.
  static const double restingIntensity = 0.6;

  /// A stronger foil the more the card is tilted, like a real hologram
  /// catching the light.
  static double intensityFor(Offset offset) =>
      restingIntensity +
      (1 - restingIntensity) * math.min(1.0, offset.distance);

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
          size: Size.infinite,
          painter: _HoloFoilPainter(offset: offset, intensity: intensity),
        ),
      ),
    );
  }
}

class _HoloFoilPainter extends CustomPainter {
  _HoloFoilPainter({required this.offset, required this.intensity});

  final Offset offset;
  final double intensity;

  static const _rainbow = [
    Color(0xFFFF7EB3),
    Color(0xFFFFD58A),
    Color(0xFFA6FFCB),
    Color(0xFF7FE7FF),
    Color(0xFFB79BFF),
    Color(0xFFFF7EB3),
  ];

  /// The rainbow, repeating every [period] pixels along the diagonal and
  /// shifted by [shift].
  ui.Gradient _rainbowShader(
    Size size,
    Offset shift,
    double period,
    double alpha,
  ) {
    final direction = Offset(size.width, size.height);
    final unit = direction / direction.distance;
    final start = shift;
    final end = shift + unit * period;
    return ui.Gradient.linear(
      start,
      end,
      [for (final c in _rainbow) c.withValues(alpha: alpha)],
      const [0, 0.2, 0.4, 0.6, 0.8, 1],
      TileMode.mirror,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Rainbow bands that glide across as the card tilts.
    final bandShift = Offset(
      offset.dx * size.width * 0.7,
      offset.dy * size.height * 0.7,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = _rainbowShader(
          size,
          bandShift,
          size.width * 0.55,
          0.24 * intensity,
        ),
    );

    // Fine diffraction lines, moving faster than the bands so the two
    // shimmer against each other.
    final linePaint = Paint()
      ..blendMode = BlendMode.screen
      ..strokeWidth = 0.7
      ..shader = _rainbowShader(
        size,
        bandShift * 1.8,
        size.width * 0.3,
        0.16 * intensity,
      );
    const spacing = 3.2;
    for (var x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }

    // A spot of light that moves the opposite way to the tilt, as if a
    // lamp above the card were reflecting off it.
    final spot = Offset(
      size.width * (0.5 - offset.dx * 0.45),
      size.height * (0.4 - offset.dy * 0.45),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          spot,
          size.width * 0.55,
          [
            Colors.white.withValues(alpha: 0.2 * intensity),
            Colors.white.withValues(alpha: 0.05 * intensity),
            Colors.transparent,
          ],
          const [0, 0.45, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _HoloFoilPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.intensity != intensity;
}
