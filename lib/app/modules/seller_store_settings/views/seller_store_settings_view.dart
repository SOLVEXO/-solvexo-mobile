import 'package:book_store_app/app/modules/seller/widgets/screen_states.dart';
import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_store_settings_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Store settings (English, seller panel; checklist #15).
class SellerStoreSettingsView extends GetView<SellerStoreSettingsController> {
  const SellerStoreSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: !controller.dirty.value,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await Get.dialog<bool>(AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('Your settings are not saved.'),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                  onPressed: () => Get.back(result: false),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                  onPressed: () => Get.back(result: true),
                  child: const Text('Discard'),
                ),
              ],
            ));
            if (leave == true) {
              controller.discard();
              Get.back();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Store settings')),
            body: controller.isLoading.value
                ? const ListSkeleton(rows: 6, rowHeight: 64)
                : controller.failed.value
                    ? ErrorRetry(message: 'Could not load your store settings.', onRetry: controller.load)
                    : _form(context),
            bottomNavigationBar: controller.isLoading.value || controller.failed.value ? null : _saveBar(context),
          ),
        ));
  }

  Widget _saveBar(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            if (controller.dirty.value)
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                onPressed: controller.saving.value ? null : controller.discard,
                child: const Text('Discard'),
              ),
            const Spacer(),
            FilledButton(
              key: const Key('saveSettings'),
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: controller.saving.value || !controller.dirty.value ? null : controller.save,
              child: controller.saving.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ]),
        ),
      );

  Widget _form(BuildContext context) {
    final c = controller;
    final e = c.errors;
    final sym = Money.symbol(c.currency);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const _Header('What you sell'),
        CheckboxListTile(
          key: const Key('typePhysical'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Physical products'),
          value: c.physical.value,
          onChanged: (v) {
            c.physical.value = v ?? false;
            c.touch();
          },
        ),
        CheckboxListTile(
          key: const Key('typeDigital'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Digital downloads and courses'),
          value: c.digital.value,
          onChanged: (v) {
            c.digital.value = v ?? false;
            c.touch();
          },
        ),
        if (e['types'] != null) _ErrorText(e['types']!),
        SwitchListTile(
          key: const Key('codToggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Cash on delivery'),
          subtitle: const Text('Buyers can pay cash for physical orders.'),
          value: c.cod.value,
          onChanged: (v) {
            c.cod.value = v;
            c.touch();
          },
        ),
        const _Header('Shipping'),
        _field(c.city, 'Ships from (city)', error: e['city']),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('province'),
          initialValue: c.province.value,
          decoration: const InputDecoration(labelText: 'Province', border: OutlineInputBorder()),
          items: [
            for (final p in SellerStoreSettingsController.provinces) DropdownMenuItem(value: p, child: Text(p)),
          ],
          onChanged: (v) {
            c.province.value = v;
            c.touch();
          },
        ),
        const SizedBox(height: 12),
        _field(c.dispatchDays, 'Dispatch time (days)', helper: '1 to 7 days', error: e['dispatchDays'], number: true),
        const SizedBox(height: 4),
        Text('Delivery time after dispatch', style: Theme.of(context).textTheme.titleSmall),
        for (final r in SellerStoreSettingsController.routeLabels.entries) ...[
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 120, child: Padding(padding: const EdgeInsets.only(top: 14), child: Text(r.value))),
            Expanded(child: _field(c.days[r.key]!.$1, 'Min days', number: true)),
            const SizedBox(width: 8),
            Expanded(child: _field(c.days[r.key]!.$2, 'Max days', number: true)),
          ]),
          if (e['days_${r.key}'] != null) _ErrorText(e['days_${r.key}']!),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          key: const Key('deliveryFeeToggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Charge my own delivery fee'),
          subtitle: const Text('Off: Edudeen delivery rates apply.'),
          value: c.deliveryFeeOn.value,
          onChanged: (v) {
            c.deliveryFeeOn.value = v;
            c.touch();
          },
        ),
        if (c.deliveryFeeOn.value) ...[
          _field(c.deliveryFee, 'Delivery fee', prefix: sym, error: e['deliveryFee'], number: true),
          const SizedBox(height: 12),
          _field(c.freeOver, 'Free delivery over (optional)', prefix: sym, error: e['freeOver'], number: true),
        ],
        SwitchListTile(
          key: const Key('giftWrapToggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Offer gift wrap'),
          value: c.giftWrapOn.value,
          onChanged: (v) {
            c.giftWrapOn.value = v;
            c.touch();
          },
        ),
        if (c.giftWrapOn.value) _field(c.giftWrapFee, 'Gift wrap charge', prefix: sym, error: e['giftWrapFee'], number: true),
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 48,
          title: const Text('Shipping zones'),
          subtitle: const Text('Where Edudeen delivers (read-only)'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Get.toNamed(Routes.sellerShipping),
        ),
        const _Header('Returns'),
        SwitchListTile(
          key: const Key('returnsToggle'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Accept returns'),
          value: c.returnsAccepted.value,
          onChanged: (v) {
            c.returnsAccepted.value = v;
            c.touch();
          },
        ),
        if (c.returnsAccepted.value) ...[
          _field(c.returnWindow, 'Return window (days)', helper: '0 to 90 days', error: e['returnWindow'], number: true),
          const SizedBox(height: 12),
        ],
        _field(c.returnNote, 'Return policy note (physical)', error: e['returnNote'], maxLength: 300, lines: 3),
        const SizedBox(height: 12),
        _field(c.digitalNote, 'Return policy note (digital)', error: e['digitalNote'], maxLength: 300, lines: 3),
      ],
    );
  }

  Widget _field(TextEditingController t, String label,
          {String? helper, String? error, String? prefix, bool number = false, int? maxLength, int lines = 1}) =>
      TextField(
        controller: t,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        maxLength: maxLength,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          errorText: error,
          prefixText: prefix == null || prefix.isEmpty ? null : '$prefix ',
          border: const OutlineInputBorder(),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
      );
}
