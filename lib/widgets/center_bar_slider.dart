import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class CenterBarSlider extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Color centerBarColor;
  final Color linesColor;

  const CenterBarSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100000,
    this.centerBarColor = Colors.red,
    this.linesColor = const Color(0xFFDDDDDD),
  }) : super(key: key);

  @override
  State<CenterBarSlider> createState() => _CenterBarSliderState();
}

class _CenterBarSliderState extends State<CenterBarSlider> with SingleTickerProviderStateMixin {
  late int _value;
  late double _dragStartX;
  late double _dragStartValue;
  bool _isDragging = false;
  int? _lastFeedbackValue;
  
  // Constants for the slider appearance
  static const double _centerBarWidth = 6.0; // Increased width for bolder appearance
  static const double _lineWidth = 2.0;
  static const double _dotSize = 4.0;
  static const double _maxLineHeight = 45.0;
  
  // Number of visible dots/lines (we'll show a subset of the total range)
  static const int _visibleLines = 101; // Show 101 lines (center + 50 on each side)
  
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }
  
  @override
  void didUpdateWidget(CenterBarSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isDragging) {
      _value = widget.value;
    }
  }
  
  // Calculate the offset for lines based on current value
  double _calculateOffset(int currentValue, double containerWidth) {
    final centerPosition = containerWidth / 2;
    
    // Each line represents exactly 1 unit
    final pixelsPerUnit = containerWidth / (_visibleLines - 1);
    
    // Return the offset from center (negative value means lines move right)
    return centerPosition - (currentValue * pixelsPerUnit);
  }
  
  // Calculate line height based on distance from center position in pixels
  double _calculateLineHeightFromPosition(double xPosition, double centerPosition, double containerHeight) {
    // Calculate distance in pixels from the center
    final distanceFromCenter = (xPosition - centerPosition).abs();
    
    // Convert to a normalized distance (0 to 1)
    // Use a smaller divisor to make the transition more gradual
    final maxDistance = containerHeight * 1.2; // This controls how quickly lines become dots
    final normalizedDistance = math.min(1.0, distanceFromCenter / maxDistance);
    
    // Calculate height using a smooth curve
    // Lines closer to center are taller, gradually becoming dots further away
    double heightFactor = math.cos(normalizedDistance * math.pi / 2); // Gives a nice curve from 1.0 to 0.0
    heightFactor = math.pow(heightFactor, 1.5).toDouble(); // Make the curve steeper
    
    // Calculate height based on container height for responsiveness
    final maxHeight = math.min(containerHeight * 0.6, _maxLineHeight);
    final minHeight = _dotSize;
    
    return minHeight + heightFactor * (maxHeight - minHeight);
  }
  
  void _triggerHapticFeedback() {
    HapticFeedback.selectionClick();
  }
  
  // Check if the current value is at a position where haptic feedback should trigger
  bool _shouldTriggerFeedback(int value) {
    // Trigger feedback at each integer value
    return _lastFeedbackValue != value;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final linesColor = isDarkMode ? Colors.grey[700]! : widget.linesColor;
    
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;
          final centerPosition = containerWidth / 2;
          
          // Calculate the offset for the lines
          final linesOffset = _calculateOffset(_value, containerWidth);
          
          // Calculate spacing between lines
          final lineSpacing = containerWidth / (_visibleLines - 1);
          
          return GestureDetector(
            behavior: HitTestBehavior.opaque, // Ensures the entire area is tappable
            onHorizontalDragStart: (details) {
              setState(() {
                _isDragging = true;
                _dragStartX = details.localPosition.dx;
                _dragStartValue = _value.toDouble();
                _lastFeedbackValue = _value;
              });
            },
            onHorizontalDragUpdate: (details) {
              if (!_isDragging) return;
              
              final dx = details.localPosition.dx - _dragStartX;
              
              // Each pixel of movement corresponds to a fraction of a unit
              final pixelsPerUnit = containerWidth / (_visibleLines - 1);
              final valueDelta = dx / pixelsPerUnit;
              
              // Calculate new value - each line represents exactly 1 unit
              final newValue = (_dragStartValue - valueDelta).round().clamp(widget.min, widget.max);
              
              // Check if we're crossing an integer boundary for haptic feedback
              if (_shouldTriggerFeedback(newValue)) {
                _triggerHapticFeedback();
                _lastFeedbackValue = newValue;
              }
              
              if (newValue != _value) {
                setState(() {
                  _value = newValue;
                });
                widget.onChanged(newValue);
              }
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                _isDragging = false;
                _lastFeedbackValue = null;
              });
            },
            // Also handle tap events for direct positioning
            onTapDown: (details) {
              final tapPosition = details.localPosition.dx;
              final offset = tapPosition - centerPosition;
              
              // Each pixel of movement corresponds to a fraction of a unit
              final pixelsPerUnit = containerWidth / (_visibleLines - 1);
              final valueDelta = offset / pixelsPerUnit;
              
              // Calculate the new value based on tap position
              final newValue = (_value - valueDelta.round()).clamp(widget.min, widget.max);
              
              if (newValue != _value) {
                _triggerHapticFeedback();
                setState(() {
                  _value = newValue;
                });
                widget.onChanged(newValue);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Moving lines using Stack
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(linesOffset, 0),
                    child: Stack(
                      children: List.generate(_visibleLines, (index) {
                        // Calculate the actual position of this line in screen coordinates
                        final xPosition = index * lineSpacing;
                        // Calculate the absolute position after offset is applied
                        final absolutePosition = xPosition + linesOffset;
                        
                        // Calculate height based on current position relative to center
                        final lineHeight = _calculateLineHeightFromPosition(
                          absolutePosition, 
                          centerPosition, 
                          containerHeight
                        );
                        
                        // For dots, use circular shape when height is small
                        final bool isDot = lineHeight <= _dotSize * 1.5;
                        
                        // Calculate the value this line represents
                        final lineValue = index;
                        
                        // Only show lines that are within the valid range
                        if (lineValue < widget.min || lineValue > widget.max) {
                          return const SizedBox.shrink();
                        }
                        
                        return Positioned(
                          left: xPosition - (isDot ? _dotSize / 2 : _lineWidth / 2),
                          top: (containerHeight - lineHeight) / 2,
                          width: isDot ? _dotSize : _lineWidth,
                          height: lineHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: linesColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(isDot ? _dotSize : 1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                
                // Fixed center red bar (no animation)
                Container(
                  width: _centerBarWidth,
                  height: math.min(containerHeight * 0.6, _maxLineHeight),
                  decoration: BoxDecoration(
                    color: widget.centerBarColor,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 