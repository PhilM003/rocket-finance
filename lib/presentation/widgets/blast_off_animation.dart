import 'package:flutter/material.dart';

class BlastOffAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlastOffAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<BlastOffAnimation> createState() => BlastOffAnimationState();
}

class BlastOffAnimationState extends State<BlastOffAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _translateController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _translateController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _translateAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -3)).animate(
      CurvedAnimation(parent: _translateController, curve: Curves.easeIn),
    );
  }

  Future<void> animateBlastOff(VoidCallback onComplete) async {
    await Future.wait([
      _scaleController.forward(),
      _translateController.forward(),
    ]);
    onComplete();
    _resetAnimation();
  }

  void _resetAnimation() {
    _scaleController.reset();
    _translateController.reset();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _translateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _translateAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: _translateAnimation.value * MediaQuery.of(context).size.height,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
