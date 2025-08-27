import 'package:flutter/material.dart';

class SlidingText extends StatefulWidget {
  final String text;

  const SlidingText({super.key, required this.text});
  @override
  State<SlidingText> createState() => _SlidingTextState();
}

class _SlidingTextState extends State<SlidingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Adjust for desired speed
    );

    // Define animation from full screen width to negative text width
    _animation = Tween<double>(
      begin: 1.0, // Start offscreen (right)
      end: -1.0, // Move offscreen (left)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Repeat the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Calculate position based on animation value
            final dx = _animation.value * (width + 100); // Text width offset
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Text(
            "ከ ${widget.text}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
