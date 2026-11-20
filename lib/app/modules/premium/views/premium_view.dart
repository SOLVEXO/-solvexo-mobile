import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/modules/premium/controllers/premium_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Edudeen Premium (B3). All prices are the server's (plan USD/PKR,
/// payment amountPKR); nothing is calculated on the device.
class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edudeen Premium'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) return const BuyerSkeleton(rows: 3, rowHeight: 140);
        if (controller.failed.value) return BuyerError(message: 'Could not load Premium.'.tr, onRetry: controller.load);
        final s = controller.status.value;
        final pending = s?.pendingPayment;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            if (s?.isPremium == true) const _MemberCard() else const _Intro(),
            if (pending != null) ...[const SizedBox(height: 16), const _PaymentCard()],
            if (s?.isPremium != true && pending == null) ...[const SizedBox(height: 16), const _Plans()],
            if (s?.isPremium == true) ...[const SizedBox(height: 16), const _Deals()],
          ]),
        );
      }),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget row(IconData i, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [Icon(i, color: t.colorScheme.primary), const SizedBox(width: 10), Expanded(child: Text(text))]),
        );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Member prices and more'.tr, style: t.textTheme.titleLarge),
          const SizedBox(height: 12),
          row(Icons.sell_outlined, 'Member prices on products that offer them'.tr),
          row(Icons.schedule_outlined, 'Early access to sales'.tr),
          row(Icons.child_care_outlined, 'More children in your account'.tr),
          row(Icons.support_agent_outlined, 'Priority support'.tr),
          Text('Paid by bank transfer; an Edudeen admin confirms your payment.'.tr, style: t.textTheme.bodySmall),
        ]),
      ),
    );
  }
}

class _Plans extends GetView<PremiumController> {
  const _Plans();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.plans.isEmpty) return BuyerEmpty(icon: Icons.workspace_premium_outlined, title: 'No Premium plans right now'.tr);
      final t = Theme.of(context);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SegmentedButton<bool>(
          key: const Key('premiumInterval'),
          segments: [
            ButtonSegment(value: false, label: Text('Monthly'.tr)),
            ButtonSegment(value: true, label: Text('Yearly'.tr)),
          ],
          selected: {controller.yearly.value},
          onSelectionChanged: (v) => controller.yearly.value = v.first,
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          key: const Key('premiumCurrency'),
          segments: const [ButtonSegment(value: 'PKR', label: Text('PKR')), ButtonSegment(value: 'USD', label: Text('USD'))],
          selected: {controller.currency.value},
          onSelectionChanged: (v) => controller.currency.value = v.first,
        ),
        const SizedBox(height: 12),
        for (final p in controller.plans)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: t.textTheme.titleMedium),
                if (p.description != null) Text(p.description!, style: t.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  '${Money.format(p.price(controller.interval, controller.currency.value), controller.currency.value)} / ${controller.yearly.value ? 'year'.tr : 'month'.tr}',
                  key: Key('planPrice_${p.id}'),
                  style: t.textTheme.headlineSmall,
                ),
                if (controller.yearly.value && p.yearlySavingsPercent != null)
                  Text('${'Save'.tr} ${p.yearlySavingsPercent}%', style: TextStyle(color: t.colorScheme.primary)),
                const SizedBox(height: 12),
                if (!controller.signedIn.value)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () async {
                      await Get.toNamed(Routes.authTabView);
                      controller.load();
                    },
                    child: Text('Log in to join'.tr),
                  )
                else
                  FilledButton(
                    key: Key('subscribe_${p.id}'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: controller.busy.value ? null : () => controller.subscribe(p),
                    child: Text('Join Premium'.tr),
                  ),
              ]),
            ),
          ),
      ]);
    });
  }
}

/// A started purchase: bank details + proof upload, or "under review".
class _PaymentCard extends GetView<PremiumController> {
  const _PaymentCard();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.status.value?.pendingPayment;
      if (p == null) return const SizedBox.shrink();
      final t = Theme.of(context);
      final st = '${p['status']}';
      final amount = Money.format(p['amountPKR'] as num?, 'PKR');
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${p['planName'] ?? 'Premium'} · ${p['interval'] == 'yearly' ? 'Yearly'.tr : 'Monthly'.tr}', style: t.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${'Amount to transfer'.tr}: $amount', key: const Key('premiumAmount'), style: t.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (st == 'pending')
              Text('We are checking your payment. You will get a notification once it is confirmed.'.tr, key: const Key('premiumPending'))
            else ...[
              if (st == 'rejected')
                Text('${'Your proof was not accepted'.tr}: ${p['rejectionReason'] ?? ''}', style: TextStyle(color: t.colorScheme.error)),
              const SizedBox(height: 8),
              if (controller.bankError.value != null)
                Text(controller.bankError.value!, style: TextStyle(color: t.colorScheme.error))
              else if (controller.bank.value != null)
                _BankBox(bank: controller.bank.value!),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('premiumProofPick'),
                onTap: () => AppImagePicker.show(
                  title: 'Payment proof'.tr,
                  canRemove: controller.proof.value != null,
                  onRemove: () => controller.proof.value = null,
                  onPicked: (f) => controller.proof.value = f,
                ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 80),
                  decoration: BoxDecoration(border: Border.all(color: t.colorScheme.outline), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: controller.proof.value == null
                      ? Padding(padding: const EdgeInsets.all(16), child: Text('Add a photo of your transfer receipt'.tr))
                      : Image.file(controller.proof.value!, height: 140),
                ),
              ),
              const SizedBox(height: 8),
              TextField(controller: controller.reference, maxLength: 120, decoration: InputDecoration(labelText: 'Transaction reference (optional)'.tr, border: const OutlineInputBorder())),
              TextField(controller: controller.senderName, maxLength: 120, decoration: InputDecoration(labelText: 'Sender name (optional)'.tr, border: const OutlineInputBorder())),
              FilledButton(
                key: const Key('premiumProofSubmit'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: controller.busy.value || controller.bank.value == null ? null : controller.submitProof,
                child: Text('Send proof'.tr),
              ),
            ],
          ]),
        ),
      );
    });
  }
}

class _BankBox extends StatelessWidget {
  const _BankBox({required this.bank});
  final Map bank;
  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      for (final (k, l) in [
        ('bankName', 'Bank'), ('accountTitle', 'Account title'), ('accountNumber', 'Account number'),
        ('iban', 'IBAN'), ('jazzcashNumber', 'JazzCash'), ('easypaisaNumber', 'EasyPaisa'),
      ])
        if ((bank[k] ?? '').toString().isNotEmpty) (l.tr, '${bank[k]}'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final r in rows) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${r.$1}: ${r.$2}')),
      if ((bank['instructions'] ?? '').toString().isNotEmpty) Text('${bank['instructions']}', style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _MemberCard extends GetView<PremiumController> {
  const _MemberCard();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.status.value!;
      final m = s.membership ?? const {};
      final end = DateTime.tryParse('${m['currentPeriodEnd'] ?? ''}');
      final cancelling = m['cancelAtPeriodEnd'] == true;
      final coupon = s.coupon;
      final t = Theme.of(context);
      return Card(
        margin: EdgeInsets.zero,
        color: t.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.workspace_premium_rounded), const SizedBox(width: 8), Text('You are a Premium member'.tr, style: t.textTheme.titleMedium)]),
            if (end != null)
              Text('${cancelling ? 'Ends on'.tr : 'Renews on'.tr} ${DateFormat('d MMM y').format(end.toLocal())}', key: const Key('premiumEnd')),
            if (coupon != null && coupon['code'] != null && coupon['used'] != true && coupon['expired'] != true)
              Padding(padding: const EdgeInsets.only(top: 8), child: Text('${'Your monthly coupon'.tr}: ${coupon['code']}')),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('premiumCancelResume'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: controller.busy.value ? null : controller.cancelOrResume,
              child: Text(cancelling ? 'Keep my Premium'.tr : 'Cancel at the end of the period'.tr),
            ),
          ]),
        ),
      );
    });
  }
}

class _Deals extends GetView<PremiumController> {
  const _Deals();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.deals.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Premium deals'.tr, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final p = controller.deals[i];
              final img = (p['images'] is List && (p['images'] as List).isNotEmpty) ? '${(p['images'] as List).first}' : p['image'] as String?;
              return InkWell(
                onTap: () => Get.toNamed(Routes.productDetailsView, arguments: {'productId': p['_id'] ?? p['productId']}),
                child: SizedBox(
                  width: 130,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AspectRatio(aspectRatio: 1, child: img == null ? const ColoredBox(color: Colors.black12) : CachedNetworkImage(imageUrl: img, fit: BoxFit.contain)),
                    Text('${p['name'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            },
          ),
        ),
      ]);
    });
  }
}

/// Member price / early access on a product, only when the API sends them.
class MemberPriceChips extends StatelessWidget {
  const MemberPriceChips({super.key, this.premiumPrice, this.currency, this.earlyAccess = false});
  final num? premiumPrice;
  final String? currency;
  final bool earlyAccess;

  @override
  Widget build(BuildContext context) {
    if (premiumPrice == null && !earlyAccess) return const SizedBox.shrink();
    final t = Theme.of(context);
    return Wrap(spacing: 8, children: [
      if (premiumPrice != null)
        Chip(
          key: const Key('memberPrice'),
          avatar: const Icon(Icons.workspace_premium_rounded, size: 16),
          label: Text('${'Member price'.tr} ${Money.format(premiumPrice, currency)}'),
          backgroundColor: t.colorScheme.primaryContainer,
        ),
      if (earlyAccess)
        Chip(key: const Key('earlyAccess'), label: Text('Early access'.tr), backgroundColor: t.colorScheme.tertiaryContainer),
    ]);
  }
}
