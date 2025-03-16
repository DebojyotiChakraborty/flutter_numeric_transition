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

class AnimatedNumberDisplay extends StatelessWidget {
  final int value;
  final TextStyle style;

  const AnimatedNumberDisplay({
    super.key,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the number to a string without leading zeros
    final valueString = value.toString();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: valueString.split('').map((digit) {
        return Container(
          width: 60,
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedDigit(
            digit: digit,
            style: style,
          ),
        );
      }).toList(),
    );
  }
}

class AnimatedDigit extends StatefulWidget {
  final String digit;
  final TextStyle style;

  const AnimatedDigit({
    super.key,
    required this.digit,
    required this.style,
  });

  @override
  State<AnimatedDigit> createState() => _AnimatedDigitState();
}

class _AnimatedDigitState extends State<AnimatedDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  String _oldDigit = '';
  String _newDigit = '';
  bool _isAnimating = false;
  bool _isIncrementing = true;

  @override
  void initState() {
    super.initState();
    _oldDigit = widget.digit;
    _newDigit = widget.digit;
    
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
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit && !_isAnimating) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _isAnimating = true;
    _oldDigit = _newDigit;
    _newDigit = widget.digit;
    
    // Determine animation direction
    if (_oldDigit == '9' && _newDigit == '0') {
      _isIncrementing = true;
    } else if (_oldDigit == '0' && _newDigit == '9') {
      _isIncrementing = false;
    } else {
      _isIncrementing = int.parse(_newDigit) > int.parse(_oldDigit);
    }

    _controller.reset();
    _controller.forward().then((_) {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    sigmaX: _blurAnimation.value * 4,
                    sigmaY: _blurAnimation.value * 4,
                  ),
                  child: Opacity(
                    opacity: 1 - _opacityAnimation.value,
                    child: Center(
                      child: Text(
                        _oldDigit,
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
                    sigmaX: (1 - _blurAnimation.value) * 4,
                    sigmaY: (1 - _blurAnimation.value) * 4,
                  ),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Center(
                      child: Text(
                        _newDigit,
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
