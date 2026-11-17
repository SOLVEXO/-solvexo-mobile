import 'package:book_store_app/app/data/models/finance/earnings_models.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Finance page sections (docs Part B 6.10; checklist #6). Seller panel:
// English only. Every amount is shown exactly as the server sent it.

const _minTap = Size(48, 48);

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.lines = 3, this.height = 18});
  final int lines;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(children: [
      for (var i = 0; i < lines; i++)
        Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
        ),
    ]);
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Expanded(
        child: Text(message,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
      ),
      TextButton(
        style: TextButton.styleFrom(minimumSize: _minTap),
        onPressed: onRetry,
        child: const Text('Retry'),
      ),
    ]);
  }
}

// ── Hero tiles ───────────────────────────────────────────────────────────────

class FinanceEarningsTiles extends StatelessWidget {
  const FinanceEarningsTiles({super.key, required this.controller});
  final SellerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.summaryLoading.value && controller.summary.value == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _Skeleton(lines: 2, height: 84),
        );
      }
      final s = controller.summary.value;
      if (s == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ErrorRetry(
            message: 'Could not load your earnings.',
            onRetry: controller.loadSummary,
          ),
        );
      }
      String m(double v) => Money.format(v, s.currency);
      final release = s.clearingReleaseAt;
      final tiles = [
        _Tile(
          key: const Key('tileAvailable'),
          label: 'Available',
          value: m(s.available),
          note: 'Ready for payout',
        ),
        _Tile(
          key: const Key('tileClearing'),
          label: 'Clearing',
          value: m(s.clearing),
          note: release == null
              ? 'Nothing clearing'
              : 'Earliest release ${DateFormat('d MMM').format(release)}',
        ),
        _Tile(
          key: const Key('tileExpected'),
          label: 'Open-order estimate',
          value: m(s.expected.amount),
          note: s.expected.openOrders == 0
              ? 'No open orders'
              : '${s.expected.openOrders} open · ${s.expected.toShip} to ship'
                  '${s.expected.feeEstimate > 0 ? ' · fee ≈ ${m(s.expected.feeEstimate)}' : ''}',
        ),
        _Tile(
          key: const Key('tileOwed'),
          label: 'Commission owed',
          value: m(s.commissionOwed),
          note: s.commissionOwed > 0
              ? 'Platform fee on cash you collected; taken from later sales'
              : 'Nothing owed',
        ),
      ];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (s.isFlaggedForReview)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Your wallet is under review by Edudeen. Payouts are paused until the review ends.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.45,
              children: tiles,
            ),
          ],
        ),
      );
    });
  }
}

class _Tile extends StatelessWidget {
  const _Tile({super.key, required this.label, required this.value, required this.note});
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, style: theme.textTheme.titleLarge),
            ),
            Text(note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ── Monthly statement ────────────────────────────────────────────────────────

class FinanceStatementCard extends StatelessWidget {
  const FinanceStatementCard({super.key, required this.controller});
  final SellerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Monthly statement',
      child: Obx(() {
        final theme = Theme.of(context);
        final header = Row(children: [
          IconButton(
            tooltip: 'Previous month',
            style: IconButton.styleFrom(minimumSize: _minTap),
            onPressed: controller.previousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(controller.statementMonthLabel,
                key: const Key('statementMonth'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall),
          ),
          IconButton(
            tooltip: 'Next month',
            style: IconButton.styleFrom(minimumSize: _minTap),
            onPressed: controller.canGoNextMonth ? controller.nextMonth : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ]);
        Widget body;
        final st = controller.statement.value;
        if (controller.statementLoading.value) {
          body = const _Skeleton(lines: 4);
        } else if (controller.statementFailed.value || st == null) {
          body = _ErrorRetry(message: 'Could not load the statement.', onRetry: controller.loadStatement);
        } else if (st.orderCount == 0 && st.rows.isEmpty) {
          body = Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No sales in ${controller.statementMonthLabel}.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          );
        } else {
          String m(double v) => Money.format(v, st.currency);
          body = Column(children: [
            _Row('Orders', '${st.orderCount}'),
            _Row('Gross sales', m(st.gross)),
            _Row('Platform fee', m(st.platformFee)),
            _Row('Payment processing', m(st.processingFee)),
            _Row('Refunds', m(st.refunds)),
            const Divider(),
            _Row('Net', m(st.net), bold: true),
            if (st.truncated)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Long month: download the file for every line.',
                    style: theme.textTheme.bodySmall),
              ),
          ]);
        }
        final busy = controller.downloading.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            body,
            const SizedBox(height: 12),
            Row(children: [
              for (final f in const ['csv', 'pdf']) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    key: Key('download_$f'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: busy != null || st == null
                        ? null
                        : () => controller.downloadStatement(f),
                    icon: busy == f
                        ? const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(f.toUpperCase()),
                  ),
                ),
                if (f == 'csv') const SizedBox(width: 8),
              ],
            ]),
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ]),
    );
  }
}

// ── Fee estimate + how fees work ─────────────────────────────────────────────

class FinanceFeeEstimateCard extends StatefulWidget {
  const FinanceFeeEstimateCard({super.key, required this.controller});
  final SellerFinanceController controller;

  @override
  State<FinanceFeeEstimateCard> createState() => _FinanceFeeEstimateCardState();
}

class _FinanceFeeEstimateCardState extends State<FinanceFeeEstimateCard> {
  final _price = TextEditingController();

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return _Section(
      title: 'Fee estimate',
      child: Obx(() {
        final theme = Theme.of(context);
        final s = c.summary.value;
        final currency = s?.currency ?? '';
        final est = c.feeEstimate.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(0, 48))),
              segments: const [
                ButtonSegment(value: 'digital', label: Text('Digital')),
                ButtonSegment(value: 'physical', label: Text('Physical')),
              ],
              selected: {c.feeType.value},
              onSelectionChanged: (v) {
                c.feeType.value = v.first;
                c.feeEstimate.value = null;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('feePrice'),
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: c.estimateFee,
              decoration: InputDecoration(
                labelText: 'Item price',
                prefixText: currency.isEmpty ? null : '${Money.symbol(currency)} ',
                errorText: c.feeError.value,
                constraints: const BoxConstraints(minHeight: 48),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('feeEstimateButton'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: c.feeLoading.value ? null : () => c.estimateFee(_price.text),
              child: c.feeLoading.value
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Estimate my earnings'),
            ),
            if (est != null) ...[
              const SizedBox(height: 12),
              _Row('Platform fee', Money.format(est.fee, est.currency)),
              _Row('You receive', Money.format(est.net, est.currency), bold: true),
              if (est.reason != null && est.reason!.isNotEmpty)
                Text(est.reason!, style: theme.textTheme.bodySmall),
            ],
            if (s != null) _HowFeesWork(summary: s),
          ],
        );
      }),
    );
  }
}

class _HowFeesWork extends StatelessWidget {
  const _HowFeesWork({required this.summary});
  final EarningsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = <String>[
      for (final e in summary.platformFees.entries)
        '${e.key[0].toUpperCase()}${e.key.substring(1)} items: platform fee ${e.value.label}. Never on shipping.',
      if (summary.cardProcessingPercent != null)
        'Card payments: ${summary.cardProcessingPercent}% + ${Money.usd(summary.cardProcessingFixedUSD)} processing. Not charged on COD or bank transfer.',
      if (summary.clearingDaysCard != null || summary.clearingDaysOther != null)
        'Money clears after ${summary.clearingDaysCard ?? '-'} days for card sales and ${summary.clearingDaysOther ?? '-'} days for other payments, then becomes available.',
      'Cash you collect yourself (COD): the platform fee is recorded as "Commission owed" and taken from later sales.',
    ];
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        minTileHeight: 48,
        title: Text('How fees work', style: theme.textTheme.titleSmall),
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  '),
                Expanded(child: Text(l, style: theme.textTheme.bodySmall)),
              ]),
            ),
        ],
      ),
    );
  }
}

// ── Payout history ───────────────────────────────────────────────────────────

class FinancePayoutHistory extends StatelessWidget {
  const FinancePayoutHistory({super.key, required this.controller});
  final SellerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Payout history',
      child: Obx(() {
        final theme = Theme.of(context);
        if (controller.payoutsLoading.value && controller.payouts.isEmpty) {
          return const _Skeleton(lines: 3);
        }
        if (controller.payoutsFailed.value) {
          return _ErrorRetry(message: 'Could not load payouts.', onRetry: controller.loadPayouts);
        }
        if (controller.payouts.isEmpty) {
          return Text('No payouts yet. Request one when you have an available balance.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant));
        }
        return Column(children: [
          for (final p in controller.payouts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 48,
              title: Text(Money.format(p.amount, p.currency)),
              subtitle: Text(
                  '${DateFormat('d MMM yyyy').format(p.createdAt.toLocal())}'
                  '${p.failureReason != null ? ' · ${p.failureReason}' : ''}'),
              trailing: Chip(label: Text(p.status[0].toUpperCase() + p.status.substring(1))),
            ),
        ]);
      }),
    );
  }
}
