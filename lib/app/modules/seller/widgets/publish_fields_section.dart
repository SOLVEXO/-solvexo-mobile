import 'package:book_store_app/app/modules/seller/utils/publish_rules.dart';
import 'package:flutter/material.dart';

/// "Product card style" (book | flat) + "Class range" inputs shared by the
/// Add and Edit product screens. Seller panel: English only.
class PublishFieldsSection extends StatelessWidget {
  const PublishFieldsSection({
    super.key,
    required this.coverStyle,
    required this.classFrom,
    required this.classTo,
    required this.onCoverStyleChanged,
    required this.onClassFromChanged,
    required this.onClassToChanged,
    required this.classRangeRequired,
    this.errorText,
  });

  final String? coverStyle;
  final String? classFrom;
  final String? classTo;
  final ValueChanged<String> onCoverStyleChanged;
  final ValueChanged<String?> onClassFromChanged;
  final ValueChanged<String?> onClassToChanged;

  /// Digital products need a class range to publish.
  final bool classRangeRequired;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fromIdx = PublishRules.classIndex(classFrom);
    final toItems = kClassLevels
        .where((c) => fromIdx < 0 || PublishRules.classIndex(c.slug) >= fromIdx)
        .toList();
    final toValue = toItems.any((c) => c.slug == classTo) ? classTo : null;

    Widget label(String text, {bool required = false, String? hint}) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(
                text: text,
                style: theme.textTheme.labelLarge,
                children: [
                  if (required)
                    TextSpan(
                        text: ' *',
                        style: TextStyle(color: theme.colorScheme.error)),
                ],
              )),
              if (hint != null)
                Text(hint,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label('Product card style',
            required: true, hint: 'How the product picture looks to buyers. Needed to go live.'),
        SegmentedButton<String>(
          key: const Key('coverStyle'),
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(0, 48)),
          ),
          segments: const [
            ButtonSegment(
                value: 'book',
                icon: Icon(Icons.menu_book_rounded),
                label: Text('Book cover')),
            ButtonSegment(
                value: 'flat',
                icon: Icon(Icons.crop_square_rounded),
                label: Text('Flat')),
          ],
          selected: {if (coverStyle != null) coverStyle!},
          onSelectionChanged: (s) {
            if (s.isNotEmpty) onCoverStyleChanged(s.first);
          },
        ),
        const SizedBox(height: 16),
        label('Class range',
            required: classRangeRequired,
            hint: classRangeRequired
                ? 'Needed to publish a digital product.'
                : 'Optional — helps buyers find it by class.'),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                key: const Key('classFrom'),
                initialValue: PublishRules.knownClass(classFrom),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'From',
                  constraints: BoxConstraints(minHeight: 48),
                ),
                items: [
                  for (final c in kClassLevels)
                    DropdownMenuItem(value: c.slug, child: Text(c.label)),
                ],
                onChanged: onClassFromChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                // Rebuild when "From" changes so the "To" list and value stay valid.
                key: ValueKey('classTo:$classFrom'),
                initialValue: toValue,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'To',
                  constraints: BoxConstraints(minHeight: 48),
                ),
                items: [
                  for (final c in toItems)
                    DropdownMenuItem(value: c.slug, child: Text(c.label)),
                ],
                onChanged: onClassToChanged,
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(errorText!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error)),
        ],
      ],
    );
  }
}
