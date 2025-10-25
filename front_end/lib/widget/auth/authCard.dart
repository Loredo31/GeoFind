import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double maxWidth;

  const AuthCard({
    Key? key,
    required this.child,
    this.width = 900,
    this.maxWidth = 1200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.green[100]!,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}