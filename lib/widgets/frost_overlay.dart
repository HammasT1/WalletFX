import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Covers a card in frost while it is frozen.
///
/// Freezing: the card cools to an icy blue, frost spreads out from the
/// top-left corner and ice crystals branch across the face. Unfreezing: the
/// frost thins out, the crystals shrink back and a few droplets run down
/// before the card is clear again.
///
/// A card that is already frozen when this first builds appears frosted
/// straight away, without replaying the animation.
class FrostOverlay extends StatefulWidget {
  const FrostOverlay({super.key, required this.frozen, this.borderRadius = 24});

  final bool frozen;
  final double borderRadius;

  static const freezeDuration = Duration(milliseconds: 1100);
  static const meltDuration = Duration(milliseconds: 850);

  @override
  State<FrostOverlay> createState() => _FrostOverlayState();
}

class _FrostOverlayState extends State<FrostOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _melting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.frozen ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant FrostOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frozen == widget.frozen) {
      return;
    }
    if (widget.frozen) {
      _melting = false;
      _controller.animateTo(
        1,
        duration: FrostOverlay.freezeDuration,
        curve: Curves.easeOutCubic,
      );
    } else {
      _melting = true;
      _controller.animateTo(
        0,
        duration: FrostOverlay.meltDuration,
        curve: Curves.easeInOutSine,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        if (t <= 0.001) {
          return const SizedBox.shrink();
        }

        final radius = BorderRadius.circular(widget.borderRadius);
        // The snowflake badge waits until the frost has mostly spread.
        final badge = _melting
            ? t
            : Curves.easeOutBack.transform(((t - 0.45) / 0.55).clamp(0.0, 1.0));

        return ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ui.ImageFilter.compose(
              outer: ColorFilter.matrix(_icyMatrix(t)),
              inner: ui.ImageFilter.blur(sigmaX: 4 * t, sigmaY: 4 * t),
            ),
            child: CustomPaint(
              painter: _FrostPainter(progress: t, melting: _melting),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5 * t),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: badge.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: (1 - badge) * -1.2,
                      child: Transform.scale(
                        scale: 0.5 + 0.5 * badge,
                        child: const _FrozenBadge(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Blends from no change (t = 0) to a cool, desaturated blue (t = 1).
  static List<double> _icyMatrix(double t) {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    // Keep a little of the original colour so the theme still shows through.
    const keep = 0.3;
    const icy = <double>[
      0.70 * lr, 0.70 * lg, 0.70 * lb, 0, 18, //
      0.88 * lr, 0.88 * lg, 0.88 * lb, 0, 34,
      1.05 * lr, 1.05 * lg, 1.05 * lb, 0, 62,
      0, 0, 0, 1, 0,
    ];
    const identity = <double>[
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];
    final mix = t * (1 - keep);
    return List<double>.generate(
      20,
      (i) => identity[i] + (icy[i] - identity[i]) * mix,
    );
  }
}

class _FrozenBadge extends StatelessWidget {
  const _FrozenBadge();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.ac_unit_rounded,
          size: 46,
          color: Colors.white,
          shadows: [Shadow(color: Color(0x5525507A), blurRadius: 14)],
        ),
        const SizedBox(height: 6),
        Text(
          'FROZEN',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            shadows: const [Shadow(color: Color(0x5525507A), blurRadius: 10)],
          ),
        ),
      ],
    );
  }
}

/// One ice crystal: a stem with pairs of side branches, placed in unit
/// coordinates so it scales with the card.
class _Crystal {
  const _Crystal({
    required this.origin,
    required this.angle,
    required this.length,
    required this.distance,
  });

  final Offset origin;
  final double angle;

  /// Stem length as a fraction of the card's width.
  final double length;

  /// How far the crystal sits from the corner the frost starts in, 0 to ~1.
  final double distance;
}

class _Droplet {
  const _Droplet({
    required this.origin,
    required this.size,
    required this.speed,
  });

  final Offset origin;
  final double size;
  final double speed;
}

class _FrostPainter extends CustomPainter {
  _FrostPainter({required this.progress, required this.melting});

  final double progress;
  final bool melting;

  // Generated once from a fixed seed so every card freezes in the same
  // pattern and nothing shifts between frames.
  static final List<_Crystal> _crystals = _buildCrystals();
  static final List<Offset> _sparkles = _buildSparkles();
  static final List<_Droplet> _droplets = _buildDroplets();

  /// How far past the corner the frost front has travelled.
  double get _front => progress * 1.3;

  static double _distanceFromCorner(Offset p) =>
      math.sqrt(p.dx * p.dx + p.dy * p.dy) / math.sqrt2;

  static List<_Crystal> _buildCrystals() {
    final random = math.Random(7);
    final crystals = <_Crystal>[];
    for (var i = 0; i < 34; i++) {
      // Frost forms along the edges first, so most crystals start there.
      final Offset origin;
      if (i < 24) {
        final edgePos = random.nextDouble();
        final inset = random.nextDouble() * 0.08;
        origin = switch (i % 4) {
          0 => Offset(edgePos, inset),
          1 => Offset(inset, edgePos),
          2 => Offset(edgePos, 1 - inset),
          _ => Offset(1 - inset, edgePos),
        };
      } else {
        origin = Offset(random.nextDouble(), random.nextDouble());
      }
      // Point each crystal roughly toward the middle of the card.
      final toCentre = math.atan2(0.5 - origin.dy, 0.5 - origin.dx);
      crystals.add(
        _Crystal(
          origin: origin,
          angle: toCentre + (random.nextDouble() - 0.5) * 1.6,
          length: 0.08 + random.nextDouble() * 0.14,
          distance: _distanceFromCorner(origin),
        ),
      );
    }
    return crystals;
  }

  static List<Offset> _buildSparkles() {
    final random = math.Random(13);
    return List.generate(
      40,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
  }

  static List<_Droplet> _buildDroplets() {
    final random = math.Random(21);
    return List.generate(
      9,
      (_) => _Droplet(
        origin: Offset(
          0.06 + random.nextDouble() * 0.88,
          random.nextDouble() * 0.55,
        ),
        size: 2.2 + random.nextDouble() * 2,
        speed: 0.6 + random.nextDouble() * 0.6,
      ),
    );
  }

  /// How grown something at [distance] from the corner is, from 0 to 1.
  double _growthAt(double distance) {
    if (melting) {
      return progress;
    }
    return ((_front - distance) / 0.28).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    _paintFrostFill(canvas, rect, diagonal);
    _paintCrystals(canvas, size);
    _paintSparkles(canvas, size);
    if (melting) {
      _paintDroplets(canvas, size);
    }
  }

  void _paintFrostFill(Canvas canvas, Rect rect, double diagonal) {
    final strength = melting ? progress : 1.0;

    // A milky haze that spreads from the top-left corner.
    final reach = math.max(_front * diagonal, 1.0);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          melting ? diagonal * 1.3 : reach,
          [
            Colors.white.withValues(alpha: 0.24 * strength),
            const Color(0xFFDDF3FF).withValues(alpha: 0.16 * strength),
            Colors.transparent,
          ],
          const [0, 0.8, 1],
        ),
    );

    // Thicker frost around the rim, the way ice gathers on a cold edge.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          diagonal * 0.6,
          [Colors.transparent, Colors.white.withValues(alpha: 0.26 * progress)],
          const [0.45, 1],
        ),
    );
  }

  void _paintCrystals(Canvas canvas, Size size) {
    final unit = size.width;
    final glow = Paint()
      ..color = const Color(0xFFE1F5FE).withValues(alpha: 0.18 * progress)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.62 * progress)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    for (final crystal in _crystals) {
      final growth = _growthAt(crystal.distance);
      if (growth <= 0) {
        continue;
      }
      final origin = Offset(
        crystal.origin.dx * size.width,
        crystal.origin.dy * size.height,
      );
      final path = _crystalPath(
        origin,
        crystal.angle,
        crystal.length * unit * growth,
      );
      canvas
        ..drawPath(path, glow)
        ..drawPath(path, line);
    }
  }

  /// A stem with three pairs of side branches at 60°, each pair shorter than
  /// the last, like a fern of frost.
  Path _crystalPath(Offset origin, double angle, double length) {
    final path = Path();
    final direction = Offset(math.cos(angle), math.sin(angle));
    path
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(
        origin.dx + direction.dx * length,
        origin.dy + direction.dy * length,
      );

    for (var i = 1; i <= 3; i++) {
      final along = length * i / 4;
      final base = origin + direction * along;
      final branch = length * (0.42 - i * 0.09);
      for (final side in const [-1, 1]) {
        final a = angle + side * math.pi / 3;
        path
          ..moveTo(base.dx, base.dy)
          ..lineTo(
            base.dx + math.cos(a) * branch,
            base.dy + math.sin(a) * branch,
          );
      }
    }
    return path;
  }

  void _paintSparkles(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < _sparkles.length; i++) {
      final p = _sparkles[i];
      final growth = _growthAt(_distanceFromCorner(p));
      if (growth <= 0) {
        continue;
      }
      paint.color = Colors.white.withValues(
        alpha: (0.35 + (i % 3) * 0.2) * growth * progress,
      );
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        0.6 + (i % 4) * 0.35,
        paint,
      );
    }
  }

  void _paintDroplets(Canvas canvas, Size size) {
    // 0 when the melt starts, 1 when the card is clear.
    final melt = 1 - progress;
    final visibility = math.sin(melt * math.pi);
    if (visibility <= 0) {
      return;
    }
    final body = Paint()
      ..color = const Color(0xFFE1F5FE).withValues(alpha: 0.55 * visibility);
    final trail = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.18 * visibility);
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.9 * visibility);

    for (final drop in _droplets) {
      final start = Offset(
        drop.origin.dx * size.width,
        drop.origin.dy * size.height,
      );
      final fall =
          Curves.easeIn.transform(melt) * size.height * 0.4 * drop.speed;
      final centre = start.translate(0, fall);
      trail.strokeWidth = drop.size * 0.9;
      canvas
        ..drawLine(start, centre, trail)
        ..drawCircle(centre, drop.size, body)
        ..drawCircle(
          centre.translate(-drop.size * 0.35, -drop.size * 0.35),
          drop.size * 0.3,
          highlight,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _FrostPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.melting != melting;
}
