import 'package:book_store_app/core/theme/base_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';

/// The one error screen every redesigned view should use instead of a bare
/// `Text('Error: $e')` — icon, message, and an optional retry action.
class BaseErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const BaseErrorView({
    super.key,
    this.message = "Something went wrong. Please try again.",
    this.onRetry,
    this.retryLabel = "Try Again",
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BaseSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: BaseColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.error_outline_rounded, size: 40, color: BaseColors.danger),
            ),
            const SizedBox(height: BaseSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BaseTypography.bodyMedium(
                color: isDark ? BaseColors.onSurfaceMutedDark : BaseColors.onSurfaceMutedLight,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: BaseSpacing.lg),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: BaseColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: BaseSpacing.xl, vertical: BaseSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.md)),
                ),
                child: Text(retryLabel, style: BaseTypography.labelLarge(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
