import 'package:flutter/material.dart';

class CustomLoadingPin extends StatefulWidget {
  const CustomLoadingPin({super.key});

  @override
  State<CustomLoadingPin> createState() => _CustomLoadingPinState();
}

class _CustomLoadingPinState extends State<CustomLoadingPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your custom asset image
          Image.asset(
            'assets/images/logo.png', // Make sure this matches your pubspec.yaml path
            width: 70,
            height: 70,
          ),
          const SizedBox(height: 5),
          Text(
            'Finding spots...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
