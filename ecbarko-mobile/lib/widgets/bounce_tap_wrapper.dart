import 'package:flutter/material.dart';

class BounceTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BounceTapWrapper({
    required this.child,
    required this.onTap,
    super.key,
  });

  @override
  State<BounceTapWrapper> createState() => _BounceTapWrapperState();
}

class _BounceTapWrapperState extends State<BounceTapWrapper> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
