import 'package:flutter/material.dart';
import '../theme/theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final bool hasGlow;

  const NeonCard({
    Key? key,
    required this.child,
    this.hasGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack.withOpacity(0.8), // Frosted feel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasGlow ? AppTheme.neonGreen : Colors.white10,
          width: 1,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppTheme.neonGreen.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
