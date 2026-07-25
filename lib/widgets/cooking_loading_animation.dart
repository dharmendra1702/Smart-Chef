import 'dart:async';
import 'dart:math';

import 'package:chef_buddy/constants/colors.dart';
import 'package:flutter/material.dart';

/// A lightweight, pure-Flutter "simmering pot with rising steam" loading
/// animation, with an optional rotating caption below it.
///
/// Built entirely with AnimationController + Transform/Opacity — no external
/// animation files (Lottie caused a stack-overflow crash on Flutter Web with
/// this project's asset, so we deliberately avoid that dependency here).
class CookingLoadingAnimation extends StatefulWidget {
  final double size;
  final bool showCaption;

  const CookingLoadingAnimation({
    super.key,
    this.size = 90,
    this.showCaption = true,
  });

  @override
  State<CookingLoadingAnimation> createState() =>
      _CookingLoadingAnimationState();
}

class _CookingLoadingAnimationState extends State<CookingLoadingAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _potController;
  late final AnimationController _steamController;
  Timer? _captionTimer;
  int _captionIndex = 0;

  static const _captions = [
    "Chopping the ingredients...",
    "Heating up the pan...",
    "Adding a pinch of masala...",
    "Simmering to perfection...",
    "Plating it up nicely...",
  ];

  @override
  void initState() {
    super.initState();
    _potController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    if (widget.showCaption) {
      _captionTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
        if (!mounted) return;
        setState(() {
          _captionIndex = (_captionIndex + 1) % _captions.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _potController.dispose();
    _steamController.dispose();
    _captionTimer?.cancel();
    super.dispose();
  }

  Widget _steamWisp({required double phase, required double dx}) {
    return AnimatedBuilder(
      animation: _steamController,
      builder: (context, child) {
        // t cycles 0->1 with a phase offset so wisps are staggered.
        final t = (_steamController.value + phase) % 1.0;
        final rise = -widget.size * 0.55 * t;
        final sway = sin(t * pi * 2) * (widget.size * 0.06);
        final opacity = (t < 0.15)
            ? t / 0.15
            : (t > 0.75)
                ? (1 - t) / 0.25
                : 1.0;
        return Transform.translate(
          offset: Offset(dx + sway, rise),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0).toDouble(),
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size * 0.09,
        height: widget.size * 0.22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.grey.withOpacity(0.0),
              Colors.grey.withOpacity(0.55),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.size * 1.15,
          width: widget.size * 1.3,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Steam wisps, staggered.
              Positioned(
                bottom: widget.size * 0.55,
                left: widget.size * 0.38,
                child: _steamWisp(phase: 0.0, dx: -widget.size * 0.14),
              ),
              Positioned(
                bottom: widget.size * 0.58,
                left: widget.size * 0.6,
                child: _steamWisp(phase: 0.33, dx: 0),
              ),
              Positioned(
                bottom: widget.size * 0.55,
                left: widget.size * 0.82,
                child: _steamWisp(phase: 0.66, dx: widget.size * 0.14),
              ),
              // The simmering pot itself — gentle rock + a subtle bounce.
              AnimatedBuilder(
                animation: _potController,
                builder: (context, child) {
                  final wobble = (_potController.value - 0.5) * 0.06;
                  return Transform.rotate(
                    angle: wobble,
                    child: Transform.translate(
                      offset: Offset(0, -_potController.value * 3),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '🍲',
                  style: TextStyle(fontSize: widget.size * 0.62),
                ),
              ),
            ],
          ),
        ),
        if (widget.showCaption) ...[
          SizedBox(height: widget.size * 0.12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              _captions[_captionIndex],
              key: ValueKey(_captionIndex),
              style: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
