import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Number Count',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'iOS Number Count',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: NumberCounter(),
      ),
    );
  }
}

class NumberCounter extends StatefulWidget {
  const NumberCounter({super.key});

  @override
  State<NumberCounter> createState() => _NumberCounterState();
}

class _NumberCounterState extends State<NumberCounter> {
  int _counter = 1;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          AnimatedNumberDisplay(
            value: _counter,
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: _decrementCounter,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCB6E2F),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.remove, size: 20),
                SizedBox(width: 8),
                Text(
                  'DECREMENT',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _incrementCounter,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF76C14B),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text(
                  'INCREMENT',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

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
    
    // Use newValueString.length as the digit count for display
    final int displayLength = newValueString.length;
    String paddedOldValue;
    if (oldValueString.length < displayLength) {
      paddedOldValue = oldValueString.padLeft(displayLength, '0');
    } else if (oldValueString.length > displayLength) {
      paddedOldValue = oldValueString.substring(oldValueString.length - displayLength);
    } else {
      paddedOldValue = oldValueString;
    }
    
    // For the new value, we already have proper digit count
    final String paddedNewValue = newValueString;
    
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(displayLength, (index) {
          final oldDigit = paddedOldValue[index];
          final newDigit = paddedNewValue[index];
          // No leading zero logic needed since we are using displayLength
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

class _AnimatedDigitContainerState extends State<AnimatedDigitContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isLeadingZero) {
      // Immediately hide leading zeros on digit reduction
      if (!widget.shouldAnimate) {
        _visible = false;
      } else {
        Future.delayed(widget.animationDelay, () {
          if (mounted) {
            _controller.forward().then((_) {
              if (mounted) {
                setState(() {
                  _visible = false;
                });
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible && widget.isLeadingZero) {
      return const SizedBox(width: 0);
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: widget.isLeadingZero ? _opacityAnimation.value : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
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
          ),
        );
      },
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
  bool _isAnimating = false;
  bool _isIncrementing = true;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _positionAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
    
    if (widget.shouldAnimate && widget.oldDigit != widget.newDigit) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) {
          _startAnimation();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && widget.newDigit != oldWidget.newDigit && !_isAnimating) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) {
          _startAnimation();
        }
      });
    }
  }

  void _startAnimation() {
    _isAnimating = true;
    
    // Determine animation direction
    if (widget.oldDigit == '9' && widget.newDigit == '0') {
      _isIncrementing = true;
    } else if (widget.oldDigit == '0' && widget.newDigit == '9') {
      _isIncrementing = false;
    } else {
      _isIncrementing = int.parse(widget.newDigit) > int.parse(widget.oldDigit);
    }

    _controller.reset();
    _controller.forward().then((_) {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If we shouldn't animate, just show the new digit immediately
    if (!widget.shouldAnimate) {
      return Center(
        child: Text(
          widget.newDigit,
          style: widget.style,
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Old digit
              Positioned(
                top: _isIncrementing 
                    ? _positionAnimation.value * -100 
                    : _positionAnimation.value * 100,
                left: 0,
                right: 0,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: _blurAnimation.value * 6,
                    sigmaY: _blurAnimation.value * 6,
                  ),
                  child: Opacity(
                    opacity: 1 - _opacityAnimation.value,
                    child: Center(
                      child: Text(
                        widget.oldDigit,
                        style: widget.style,
                      ),
                    ),
                  ),
                ),
              ),
              // New digit
              Positioned(
                top: _isIncrementing 
                    ? (1 - _positionAnimation.value) * 100 
                    : (1 - _positionAnimation.value) * -100,
                left: 0,
                right: 0,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: (1 - _blurAnimation.value) * 6,
                    sigmaY: (1 - _blurAnimation.value) * 6,
                  ),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Center(
                      child: Text(
                        widget.newDigit,
                        style: widget.style,
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
