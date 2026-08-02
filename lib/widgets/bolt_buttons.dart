import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// `.primary-btn` из мокапа: сплошная заливка --on, тёмный текст
/// #0C1310, радиус sm, полная ширина, padding 13px.
class BoltPrimaryButton extends StatelessWidget {
  const BoltPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        child: Text(label),
      ),
    );
  }
}

/// `.secondary-btn` из мокапа: card + border, текст text-1 13/600,
/// полная ширина, margin-top 8px.
class BoltSecondaryButton extends StatelessWidget {
  const BoltSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.topMargin = AppSpace.s2,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double topMargin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3 - 1,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
