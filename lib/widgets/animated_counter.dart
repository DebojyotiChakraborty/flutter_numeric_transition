import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AnimatedNumberDisplay extends StatefulWidget {
  final int value;
  final TextStyle style;

  const AnimatedNumberDisplay({
    super.key,
    required this.value,
    required this.style,
  });

  @override
  State<AnimatedNumberDisplay> createState() => _AnimatedNumberDisplayState();
}

class _AnimatedNumberDisplayState extends State<AnimatedNumberDisplay> {
  late int _oldValue;
  late int _newValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedNumberDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final oldValueString = _oldValue.toString();
    final newValueString = _newValue.toString();
    
    final int displayLength = newValueString.length;
    String paddedOldValue = oldValueString.padLeft(displayLength, '0');
    final String paddedNewValue = newValueString;
    
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(displayLength, (index) {
          final oldDigit = paddedOldValue[index];
          final newDigit = paddedNewValue[index];
          return AnimatedDigitContainer(
            oldDigit: oldDigit,
            newDigit: newDigit,
            style: widget.style,
            isLeadingZero: false,
            animationDelay: Duration(milliseconds: 50 * index),
            shouldAnimate: true,
          );
        }),
      ),
    );
  }
}

class AnimatedDigitContainer extends StatefulWidget {
  final String oldDigit;
  final String newDigit;
  final TextStyle style;
  final bool isLeadingZero;
  final Duration animationDelay;
  final bool shouldAnimate;

  const AnimatedDigitContainer({
    super.key,
    required this.oldDigit,
    required this.newDigit,
    required this.style,
    required this.isLeadingZero,
    required this.animationDelay,
    this.shouldAnimate = true,
  });

  @override
  State<AnimatedDigitContainer> createState() => _AnimatedDigitContainerState();
}

class _AnimatedDigitContainerState extends State<AnimatedDigitContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45, 
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: AnimatedDigit(
        oldDigit: widget.oldDigit,
        newDigit: widget.newDigit,
        style: widget.style,
        animationDelay: widget.animationDelay,
        shouldAnimate: widget.shouldAnimate && widget.oldDigit != widget.newDigit,
      ),
    );
  }
}

class AnimatedDigit extends StatefulWidget {
  final String oldDigit;
  final String newDigit;
  final TextStyle style;
  final Duration animationDelay;
  final bool shouldAnimate;

  const AnimatedDigit({
    super.key,
    required this.oldDigit,
    required this.newDigit,
    required this.style,
    required this.animationDelay,
    this.shouldAnimate = true,
  });

  @override
  State<AnimatedDigit> createState() => _AnimatedDigitState();
}

class _AnimatedDigitState extends State<AnimatedDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;
  bool _isIncrementing = true;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    _positionAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _blurAnimation = Tween<double>(
      begin: 14.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));
    
    if (widget.shouldAnimate && widget.oldDigit != widget.newDigit) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.newDigit != oldWidget.newDigit) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _isAnimating = true;
    
    if (widget.oldDigit == '9' && widget.newDigit == '0') {
      _isIncrementing = true;
    } else if (widget.oldDigit == '0' && widget.newDigit == '9') {
      _isIncrementing = false;
    } else {
      _isIncrementing = int.parse(widget.newDigit) > int.parse(widget.oldDigit);
    }

    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.reset();
        _controller.forward().then((_) {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final oldDigitOpacity = (1.0 - _positionAnimation.value).clamp(0.0, 1.0);
          final newDigitOpacity = _positionAnimation.value.clamp(0.0, 1.0);
          
          return Stack(
            children: [
              Positioned(
                top: _isIncrementing 
                    ? _positionAnimation.value * -100 
                    : _positionAnimation.value * 100,
                left: 0,
                right: 0,
                child: Transform.scale(
                  scale: 1.0 - (_positionAnimation.value * 0.3),
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: _positionAnimation.value * 14,
                      sigmaY: _positionAnimation.value * 14,
                    ),
                    child: Opacity(
                      opacity: oldDigitOpacity,
                      child: Center(
                        child: Text(
                          widget.oldDigit,
                          style: widget.style,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _isIncrementing 
                    ? (1 - _positionAnimation.value) * 100 
                    : (1 - _positionAnimation.value) * -100,
                left: 0,
                right: 0,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: (1.0 - newDigitOpacity) * 14,
                      sigmaY: (1.0 - newDigitOpacity) * 14,
                    ),
                    child: Opacity(
                      opacity: newDigitOpacity,
                      child: Center(
                        child: Text(
                          widget.newDigit,
                          style: widget.style,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 