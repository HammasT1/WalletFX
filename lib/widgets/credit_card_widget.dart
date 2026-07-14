import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/card_gradient_theme.dart';
import '../utils/card_number_formatter.dart';
import 'card_painter.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({super.key, required this.theme});

  final CardGradientTheme theme;

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with TickerProviderStateMixin {
  static const _cardNumber = '0562992173814242';
  static const _cardholder = 'MUHAMMAD HAMMAS';
  static const _expiry = '12/28';
  static const _cvv = '742';

  late final AnimationController _controller;
  late final AnimationController _flipController;
  late final AnimationController _peekController;
  late final Animation<double> _entryAnimation;
  late final Animation<double> _flipAnimation;
  late final Animation<double> _shineAnimation;

  Offset _tiltOffset = Offset.zero;
  bool _showBack = false;
  bool _revealCardNumber = false;
  bool _revealCvv = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _peekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _entryAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    _shineAnimation = Tween<double>(begin: -1.4, end: 1.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.85, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CreditCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
      _controller.forward(from: 0.12);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _flipController.dispose();
    _peekController.dispose();
    super.dispose();
  }

  void _onPanUpdate(Offset localPosition, Size size) {
    setState(() {
      final x = (localPosition.dx - size.width / 2) / size.width;
      final y = (localPosition.dy - size.height / 2) / size.height;
      _tiltOffset = Offset(
        x.clamp(-0.5, 0.5) * 0.22,
        y.clamp(-0.5, 0.5) * 0.28,
      );
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltOffset = Offset.zero;
    });
  }

  void _toggleFlip() {
    setState(() {
      _showBack = !_showBack;
    });
    if (_showBack) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _togglePeek() async {
    if (_showBack) {
      return;
    }

    setState(() {
      _revealCardNumber = !_revealCardNumber;
    });

    if (_revealCardNumber) {
      await _peekController.forward();
    } else {
      await _peekController.reverse();
    }
  }

  void _toggleCvv() {
    setState(() {
      _revealCvv = !_revealCvv;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _flipController,
        _peekController,
      ]),
      builder: (context, child) {
        final entry = Curves.easeOutCubic.transform(_entryAnimation.value);
        final lift = 18 * (1 - entry);
        final scale = 0.88 + (0.12 * entry);
        final glowStrength = 0.22 + (0.28 * entry);

        return Opacity(
          opacity: entry,
          child: Transform.translate(
            offset: Offset(0, lift),
            child: Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTap: _toggleFlip,
                onPanStart: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    _onPanUpdate(
                      box.globalToLocal(details.globalPosition),
                      box.size,
                    );
                  }
                },
                onPanUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    _onPanUpdate(
                      box.globalToLocal(details.globalPosition),
                      box.size,
                    );
                  }
                },
                onPanEnd: (_) => _resetTilt(),
                onPanCancel: _resetTilt,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = width / 1.586;
                    final flipValue = _flipAnimation.value;
                    final baseMatrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateX(_tiltOffset.dy)
                      ..rotateY(_tiltOffset.dx);

                    final frontMatrix = baseMatrix.clone()..rotateY(flipValue);
                    final backMatrix = baseMatrix.clone()
                      ..rotateY(flipValue + math.pi);

                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _CardFace(
                            visible: _flipController.value < 0.5,
                            matrix: frontMatrix,
                            gradient: widget.theme.gradient,
                            shinePosition: _shineAnimation.value,
                            glowStrength: glowStrength,
                            cardNumber: formatCardNumber(_cardNumber),
                            cardholder: _cardholder,
                            expiry: _expiry,
                            cvv: _cvv,
                            showBack: false,
                            isCardNumberRevealed: _revealCardNumber,
                            onPeekToggle: _togglePeek,
                            peekAnimation: _peekController,
                            isCvvRevealed: _revealCvv,
                            onCvvToggle: _toggleCvv,
                          ),
                          _CardFace(
                            visible: _flipController.value >= 0.5,
                            matrix: backMatrix,
                            gradient: widget.theme.gradient,
                            shinePosition: _shineAnimation.value,
                            glowStrength: glowStrength,
                            cardNumber: formatCardNumber(_cardNumber),
                            cardholder: _cardholder,
                            expiry: _expiry,
                            cvv: _cvv,
                            showBack: true,
                            isCardNumberRevealed: _revealCardNumber,
                            onPeekToggle: _togglePeek,
                            peekAnimation: _peekController,
                            isCvvRevealed: _revealCvv,
                            onCvvToggle: _toggleCvv,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.visible,
    required this.matrix,
    required this.gradient,
    required this.shinePosition,
    required this.glowStrength,
    required this.cardNumber,
    required this.cardholder,
    required this.expiry,
    required this.cvv,
    required this.showBack,
    required this.isCardNumberRevealed,
    required this.onPeekToggle,
    required this.peekAnimation,
    required this.isCvvRevealed,
    required this.onCvvToggle,
  });

  final bool visible;
  final Matrix4 matrix;
  final LinearGradient gradient;
  final double shinePosition;
  final double glowStrength;
  final String cardNumber;
  final String cardholder;
  final String expiry;
  final String cvv;
  final bool showBack;
  final bool isCardNumberRevealed;
  final Future<void> Function() onPeekToggle;
  final Animation<double> peekAnimation;
  final bool isCvvRevealed;
  final VoidCallback onCvvToggle;

  @override
  Widget build(BuildContext context) {
    final transformed = matrix.storage[10] < 0;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1 : 0,
        child: Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: CardPainter(isFront: !showBack)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Container(
                  key: ValueKey(
                    gradient.colors.map((color) => color.value).join('-'),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _CardShineOverlay(
                    shinePosition: shinePosition,
                    intensity: glowStrength,
                  ),
                ),
              ),
              if (!showBack)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ChipGraphic(),
                            const Spacer(),
                            IconButton(
                              onPressed: onPeekToggle,
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                child: Icon(
                                  isCardNumberRevealed
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  key: ValueKey(isCardNumberRevealed),
                                  color: Colors.white.withOpacity(0.9),
                                  size: 20,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minHeight: 32,
                                minWidth: 32,
                              ),
                              splashRadius: 18,
                              tooltip: isCardNumberRevealed
                                  ? 'Hide number'
                                  : 'Peek number',
                            ),
                            _NetworkLogo(
                              assetPath: _resolveNetworkAsset(gradient),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _AnimatedCardNumber(
                          cardNumber: cardNumber,
                          reveal: isCardNumberRevealed,
                          animation: peekAnimation,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: _CardMetaBlock(
                                label: 'CARDHOLDER',
                                value: cardholder,
                              ),
                            ),
                            const SizedBox(width: 24),
                            _CardMetaBlock(
                              label: 'EXPIRES',
                              value: expiry,
                              align: CrossAxisAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (showBack)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24, 0, 18),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        Container(height: 42, color: const Color(0xFF050505)),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'Authorized Signature',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 78,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.72),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: onCvvToggle,
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        switchInCurve: Curves.easeOutCubic,
                                        switchOutCurve: Curves.easeInCubic,
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                              scale: animation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            ),
                                        child: Text(
                                          isCvvRevealed ? cvv : '•••',
                                          key: ValueKey(isCvvRevealed),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                letterSpacing: 3,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: _NetworkLogo(
                              assetPath: _resolveNetworkAsset(gradient),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (transformed)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withOpacity(0.02),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveNetworkAsset(LinearGradient gradient) {
    final first = gradient.colors.first.value;
    if (first == const Color(0xFFFF512F).value) {
      return 'assets/mastercard.svg';
    }
    if (first == const Color(0xFF2193B0).value) {
      return 'assets/americanexpress.svg';
    }
    if (first == const Color(0xFF134E5E).value) {
      return 'assets/discover.svg';
    }
    return 'assets/visa.svg';
  }
}

class _AnimatedCardNumber extends StatelessWidget {
  const _AnimatedCardNumber({
    required this.cardNumber,
    required this.reveal,
    required this.animation,
  });

  final String cardNumber;
  final bool reveal;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final digitsOnly = cardNumber.replaceAll(' ', '');
    final digitStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: Colors.white,
      letterSpacing: 2.2,
      fontWeight: FontWeight.w700,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final children = <Widget>[];

        for (var index = 0; index < digitsOnly.length; index++) {
          if (index > 0 && index % 4 == 0) {
            children.add(const SizedBox(width: 14));
          }

          final isLastFour = index >= digitsOnly.length - 4;
          final digitText = digitsOnly[index];

          children.add(
            _CardDigitFlip(
              index: index,
              actualText: digitText,
              isRevealed: reveal || isLastFour,
              animation: animation,
              style: digitStyle,
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }
}

class _CardDigitFlip extends StatelessWidget {
  const _CardDigitFlip({
    required this.index,
    required this.actualText,
    required this.isRevealed,
    required this.animation,
    required this.style,
  });

  final int index;
  final String actualText;
  final bool isRevealed;
  final Animation<double> animation;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final start = index * 0.05;
    final end = start + 0.34;
    final staggerProgress = Curves.easeInOutCubic.transform(
      (((animation.value) - start) / (end - start)).clamp(0.0, 1.0),
    );
    final text = isRevealed ? actualText : '•';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final incoming = isRevealed;
            final angle = incoming
                ? (1 - staggerProgress) * math.pi / 2
                : -staggerProgress * math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(angle),
              child: Opacity(opacity: animation.value, child: child),
            );
          },
        );
      },
      child: Transform(
        key: ValueKey<String>(text),
        alignment: Alignment.center,
        transform: Matrix4.identity()..setEntry(3, 2, 0.0015),
        child: Text(text, style: style),
      ),
    );
  }
}

class _StaticCardDigit extends StatelessWidget {
  const _StaticCardDigit({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}

class _CardShineOverlay extends StatelessWidget {
  const _CardShineOverlay({
    required this.shinePosition,
    required this.intensity,
  });

  final double shinePosition;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.55,
      child: FractionalTranslation(
        translation: Offset(shinePosition, 0),
        child: Opacity(
          opacity: intensity,
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipGraphic extends StatelessWidget {
  const _ChipGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2C772), Color(0xFFB88A2B), Color(0xFFF5E4A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: CustomPaint(painter: _ChipPainter()),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height),
      paint..style = PaintingStyle.stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.6),
      paint..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardMetaBlock extends StatelessWidget {
  const _CardMetaBlock({
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white54,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NetworkLogo extends StatelessWidget {
  const _NetworkLogo({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        placeholderBuilder: (context) =>
            const Icon(Icons.credit_card, color: Colors.white70, size: 24),
      ),
    );
  }
}
