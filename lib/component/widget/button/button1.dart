import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ButtonVariant {
  primary,
  secondary,
  tertiary,
}

class MyButton1 extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isRounded;
  final bool isTapped;
  final ButtonVariant variant;

  const MyButton1({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 40.0,
    this.isRounded = true,
    this.isTapped = true,
    this.variant = ButtonVariant.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final elevated = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: _getBackgroundColor(cs),
        foregroundColor: _getForegroundColor(cs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          side: _getBorderSide(cs),
        ),
        elevation: variant == ButtonVariant.primary
            ? 2
            : (variant == ButtonVariant.tertiary ? 1 : 0),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (states) {
            if (states.contains(MaterialState.pressed)) {
              return cs.primary.withOpacity(0.8);
            }
            return null;
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: elevated,
      );
    }

    return IntrinsicWidth(
      child: elevated,
    );
  }

  Color _getBackgroundColor(ColorScheme cs) {
    switch (variant) {
      case ButtonVariant.primary:
        return isTapped ? cs.primary : cs.surfaceVariant.withOpacity(0.876);
      case ButtonVariant.secondary:
        return isTapped ? cs.primary.withOpacity(0.1) : Colors.transparent;
      case ButtonVariant.tertiary:
        return isTapped ? cs.secondary : cs.surface;
    }
  }

  Color _getForegroundColor(ColorScheme cs) {
    switch (variant) {
      case ButtonVariant.primary:
        return isTapped ? Colors.white : cs.onSurface.withOpacity(0.7);
      case ButtonVariant.secondary:
        return isTapped ? cs.primary : cs.onSurface.withOpacity(0.7);
      case ButtonVariant.tertiary:
        return isTapped ? cs.onSecondary : cs.onSurface;
    }
  }

  double _getBorderRadius() {
    switch (variant) {
      case ButtonVariant.primary:
        return isRounded ? 20.0 : 8.0;
      case ButtonVariant.secondary:
        return 8.0;
      case ButtonVariant.tertiary:
        return 12.0;
    }
  }

  BorderSide _getBorderSide(ColorScheme cs) {
    switch (variant) {
      case ButtonVariant.primary:
        return BorderSide.none;
      case ButtonVariant.secondary:
        return BorderSide(
          color: isTapped ? cs.primary : cs.outline.withOpacity(0.5),
          width: 1.0,
        );
      case ButtonVariant.tertiary:
        return BorderSide(
          color: isTapped ? cs.secondary : cs.outline.withOpacity(0.3),
          width: 2.0,
        );
    }
  }
}