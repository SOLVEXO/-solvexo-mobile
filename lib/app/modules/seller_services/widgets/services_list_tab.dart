import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/bookings/bookable_service_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_address_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_availability_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_package_model.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/shared_form_widgets.dart';
import 'package:book_store_app/app/modules/seller_services/controllers/seller_services_controller.dart';
import 'package:book_store_app/app/modules/seller_services/widgets/services_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const List<String> _kLocationTypes = ['in_person', 'virtual', 'customer_address'];
const List<String> _kServiceStatuses = ['draft', 'active', 'inactive'];
const List<String> _kWeekdayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

String _locationTypeLabel(String type) => switch (type) {
      'in_person' => 'In Person',
      'virtual' => 'Virtual',
      'customer_address' => "Customer's Address",
      _ => type,
    };

class ServicesListTab extends StatelessWidget {
  final SellerServicesController controller;
  const ServicesListTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (controller.isLoadingServices.value) return const ServicesShimmer();

          if (controller.services.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(BaseSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_note_outlined, size: 48, color: AppColors.lightGrey),
                    SizedBox(height: BaseSpacing.sm),
                    CustomText(text: 'No services yet', color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w600),
                    SizedBox(height: BaseSpacing.xxs),
                    CustomText(text: 'Create a bookable service buyers can schedule appointments for.', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return CustomRefreshWrapper(
            onRefresh: controller.loadServices,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
              itemCount: controller.services.length,
              separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
              itemBuilder: (_, i) {
                final service = controller.services[i];
                return _ServiceCard(
                  service: service,
                  onTap: () => _ServiceDetailSheet.show(context, controller, service),
                  onEdit: () => _ServiceFormSheet.show(context, controller, existing: service),
                  onArchive: () => _confirmArchive(context, service),
                  onSetAvailability: () => _openAvailabilityDirect(context, service),
                );
              },
            ),
          );
        }),
        Positioned(
          right: BaseSpacing.md,
          bottom: BaseSpacing.md,
          child: FloatingActionButton.extended(
            heroTag: 'add_service_fab',
            onPressed: () => _ServiceFormSheet.show(context, controller),
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            label: CustomText(text: 'New Service', color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Future<void> _openAvailabilityDirect(BuildContext context, BookableServiceModel service) async {
    await controller.loadAvailability(service.id);
    if (context.mounted) _AvailabilityFormSheet.show(context, controller, service);
  }

  void _confirmArchive(BuildContext context, BookableServiceModel service) {
    CustomConfirmDialog.show(
      context,
      title: 'Archive "${service.name}"?',
      message: 'This service will no longer be bookable by buyers.',
      confirmLabel: 'Archive',
      confirmColor: AppColors.red,
      onConfirm: () => controller.archiveService(service),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Service card
// ─────────────────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final BookableServiceModel service;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onSetAvailability;
  const _ServiceCard({
    required this.service,
    required this.onTap,
    required this.onEdit,
    required this.onArchive,
    required this.onSetAvailability,
  });

  Color get _statusColor => switch (service.status) {
        'active' => AppColors.greenSuccess,
        'inactive' => AppColors.gray600,
        _ => AppColors.orange,
      };

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          border: Border.all(color: service.isActive ? AppColors.primaryColor.withOpacity(0.15) : AppColors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(text: service.name, color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                  child: CustomText(text: service.status, color: _statusColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
                IconButton(icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.gray600), onPressed: onEdit),
                IconButton(icon: Icon(Icons.archive_outlined, size: 18, color: AppColors.gray600), onPressed: onArchive),
              ],
            ),
            Row(
              children: [
                CustomText(text: '\$${service.price.toStringAsFixed(2)} ${service.currency}', color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                SizedBox(width: BaseSpacing.sm),
                Icon(Icons.schedule_rounded, size: 13, color: AppColors.gray600),
                SizedBox(width: BaseSpacing.xxs / 2),
                CustomText(text: '${service.durationMinutes} min', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                if (service.isGroupService) ...[
                  SizedBox(width: BaseSpacing.sm),
                  Icon(Icons.groups_outlined, size: 13, color: AppColors.gray600),
                  SizedBox(width: BaseSpacing.xxs / 2),
                  CustomText(text: 'Group x${service.capacityPerSlot}', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                ],
              ],
            ),
            if (service.locationTypes.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.xs),
              Wrap(
                spacing: BaseSpacing.xxs,
                runSpacing: BaseSpacing.xxs,
                children: service.locationTypes
                    .map((t) => Container(
                          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.pill)),
                          child: CustomText(text: _locationTypeLabel(t), color: AppColors.gray600, fontSize: 10.5, fontWeight: FontWeight.w600),
                        ))
                    .toList(),
              ),
            ],
            if (!service.hasAvailability) ...[
              SizedBox(height: BaseSpacing.xs),
              GestureDetector(
                onTap: onSetAvailability,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(BaseRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.orange),
                      SizedBox(width: BaseSpacing.xxs),
                      Expanded(
                        child: CustomText(
                          text: 'No availability set — not bookable yet',
                          color: AppColors.orange,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      CustomText(
                        text: 'Set now',
                        color: AppColors.orange,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w800,
                      ),
                      Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.orange),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Service detail sheet — entry point to Availability / Packages management
// ─────────────────────────────────────────────────────────────────────────

class _ServiceDetailSheet extends StatelessWidget {
  final SellerServicesController controller;
  final BookableServiceModel service;
  const _ServiceDetailSheet({required this.controller, required this.service});

  static void show(BuildContext context, SellerServicesController controller, BookableServiceModel service) {
    Get.bottomSheet(
      _ServiceDetailSheet(controller: controller, service: service),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _openAvailability() async {
    await controller.loadAvailability(service.id);
    Get.back();
    _AvailabilityFormSheet.show(Get.context!, controller, service);
  }

  Future<void> _openPackages() async {
    await controller.loadPackages(service.id);
    Get.back();
    _PackagesSheet.show(Get.context!, controller, service);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: EdgeInsets.only(bottom: BaseSpacing.md),
                  decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              CustomText(text: service.name, color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
              SizedBox(height: BaseSpacing.xxs),
              CustomText(
                text: '\$${service.price.toStringAsFixed(2)} ${service.currency} · ${service.durationMinutes} min',
                color: AppColors.gray600,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: BaseSpacing.lg),
              Obx(
                () => PrimaryButton(
                  label: 'Manage Availability',
                  isLoading: controller.isLoadingAvailability.value,
                  onPressed: () => _openAvailability(),
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
              ),
              SizedBox(height: BaseSpacing.sm),
              Obx(
                () => OutlineButton(
                  label: 'Manage Packages',
                  isLoading: controller.isLoadingPackages.value,
                  onPressed: () => _openPackages(),
                  icon: const Icon(Icons.card_giftcard_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Service create/edit form
// ─────────────────────────────────────────────────────────────────────────

class _ServiceFormSheet extends StatefulWidget {
  final SellerServicesController controller;
  final BookableServiceModel? existing;
  const _ServiceFormSheet({required this.controller, this.existing});

  static void show(BuildContext context, SellerServicesController controller, {BookableServiceModel? existing}) {
    Get.bottomSheet(
      _ServiceFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final UploadRepository _uploadRepo = UploadRepository();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _cancellationWindowCtrl;
  late final TextEditingController _addressLine1Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;

  late Set<String> _locationTypes;
  late String _status;
  late final RxList<String> _images;
  final RxBool _isUploadingImage = false.obs;

  /// Location-type chips aren't a `Form` field, so they need their own
  /// manually-driven error line instead of a `validator:`.
  String? _locationTypesError;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _durationCtrl = TextEditingController(text: e?.durationMinutes.toString() ?? '30');
    _priceCtrl = TextEditingController(text: e?.price.toString() ?? '');
    _currencyCtrl = TextEditingController(text: e?.currency ?? 'USD');
    _capacityCtrl = TextEditingController(text: e?.capacityPerSlot.toString() ?? '1');
    _cancellationWindowCtrl = TextEditingController(text: e?.cancellationWindowHours.toString() ?? '24');
    _addressLine1Ctrl = TextEditingController(text: e?.inPersonAddress?.addressLine1 ?? '');
    _cityCtrl = TextEditingController(text: e?.inPersonAddress?.city ?? '');
    _phoneCtrl = TextEditingController(text: e?.inPersonAddress?.phone ?? '');
    _locationTypes = (e?.locationTypes ?? const ['virtual']).toSet();
    _status = e?.status ?? 'draft';
    _images = <String>[...e?.images ?? const []].obs;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    _currencyCtrl.dispose();
    _capacityCtrl.dispose();
    _cancellationWindowCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ToastUtil.showToast('You can add up to 5 photos.');
      return;
    }
    _isUploadingImage.value = true;
    final url = await _uploadRepo.pickAndUpload(source: ImageSource.gallery);
    _isUploadingImage.value = false;
    if (url != null) _images.add(url);
  }

  void _removeImage(int index) => _images.removeAt(index);

  String? _requiredValidator(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  String? _positiveIntValidator(String? value, String label) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null) return '$label must be a number';
    if (n <= 0) return '$label must be greater than 0';
    return null;
  }

  String? _nonNegativeNumValidator(String? value, String label) {
    final n = double.tryParse((value ?? '').trim());
    if (n == null) return '$label must be a number';
    if (n < 0) return '$label cannot be negative';
    return null;
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _locationTypesError = _locationTypes.isEmpty ? 'Select at least one location type' : null);
    if (!formValid || _locationTypesError != null) return;

    final duration = int.parse(_durationCtrl.text.trim());
    final price = double.parse(_priceCtrl.text.trim());
    final capacity = int.tryParse(_capacityCtrl.text.trim()) ?? 1;
    final cancellationWindow = int.tryParse(_cancellationWindowCtrl.text.trim()) ?? 24;

    final body = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'images': _images.toList(),
      'durationMinutes': duration,
      'price': price,
      'currency': _currencyCtrl.text.trim().isEmpty ? 'USD' : _currencyCtrl.text.trim().toUpperCase(),
      'capacityPerSlot': capacity,
      'cancellationWindowHours': cancellationWindow,
      'locationTypes': _locationTypes.toList(),
      if (_locationTypes.contains('in_person'))
        'inPersonAddress': ServiceAddressModel(
          addressLine1: _addressLine1Ctrl.text.trim(),
          city: _cityCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        ).toJson(),
      'status': _status,
    };

    if (_isEdit) {
      final ok = await widget.controller.updateService(widget.existing!, body);
      if (ok && mounted) Get.back();
      return;
    }

    final created = await widget.controller.createService(body);
    if (created == null || !mounted) return;
    Get.back();
    // A brand-new service has zero availability by default (see the "not
    // bookable yet" badge on the card) — nudge the seller to set it right
    // away instead of relying on them noticing the badge later.
    CustomConfirmDialog.show(
      Get.context!,
      title: 'Service created!',
      message: 'Set your weekly availability now so buyers can start booking "${created.name}".',
      confirmLabel: 'Set Availability',
      cancelLabel: 'Later',
      onConfirm: () async {
        await widget.controller.loadAvailability(created.id);
        _AvailabilityFormSheet.show(Get.context!, widget.controller, created);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: EdgeInsets.only(bottom: BaseSpacing.md),
                      decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  CustomText(text: _isEdit ? 'Edit Service' : 'Create Service', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                  SizedBox(height: BaseSpacing.md),
                  ImagesSection(
                    label: 'Photos (optional)',
                    hint: 'Add up to 5 photos buyers will see on this service',
                    images: _images,
                    isUploading: _isUploadingImage,
                    onAdd: _pickImage,
                    onRemove: _removeImage,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Service Name',
                    hintText: 'e.g. 1:1 Consultation',
                    controller: _nameCtrl,
                    isborder: true,
                    validator: (v) => _requiredValidator(v, 'Service name'),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Description (optional)', controller: _descCtrl, isborder: true, maxLines: 2),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Duration (min)',
                          controller: _durationCtrl,
                          isborder: true,
                          keyboardType: TextInputType.number,
                          validator: (v) => _positiveIntValidator(v, 'Duration'),
                        ),
                      ),
                      SizedBox(width: BaseSpacing.sm),
                      Expanded(
                        child: CustomTextField(
                          label: 'Capacity per slot',
                          controller: _capacityCtrl,
                          isborder: true,
                          keyboardType: TextInputType.number,
                          validator: (v) => _positiveIntValidator(v, 'Capacity'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Price',
                          controller: _priceCtrl,
                          isborder: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => _nonNegativeNumValidator(v, 'Price'),
                        ),
                      ),
                      SizedBox(width: BaseSpacing.sm),
                      Expanded(
                        child: CustomTextField(
                          label: 'Currency',
                          controller: _currencyCtrl,
                          isborder: true,
                          validator: (v) => _requiredValidator(v, 'Currency'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Cancellation window (hours)',
                    controller: _cancellationWindowCtrl,
                    isborder: true,
                    keyboardType: TextInputType.number,
                    validator: (v) => _positiveIntValidator(v, 'Cancellation window'),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomText(text: 'Location Types', color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                  SizedBox(height: BaseSpacing.xs),
                  Wrap(
                    spacing: BaseSpacing.xs,
                    runSpacing: BaseSpacing.xs,
                    children: _kLocationTypes.map((t) {
                      final selected = _locationTypes.contains(t);
                      return GestureDetector(
                        onTap: () => setState(() {
                          selected ? _locationTypes.remove(t) : _locationTypes.add(t);
                          if (_locationTypes.isNotEmpty) _locationTypesError = null;
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryColor : AppColors.lightGrey10,
                            borderRadius: BorderRadius.circular(BaseRadius.pill),
                          ),
                          child: CustomText(
                            text: _locationTypeLabel(t),
                            color: selected ? AppColors.white : AppColors.gray600,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_locationTypesError != null) ...[
                    SizedBox(height: BaseSpacing.xxs),
                    CustomText(text: _locationTypesError!, color: AppColors.red, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                  ],
                  if (_locationTypes.contains('in_person')) ...[
                    SizedBox(height: BaseSpacing.sm),
                    CustomTextField(
                      label: 'Address Line',
                      controller: _addressLine1Ctrl,
                      isborder: true,
                      validator: (v) => _requiredValidator(v, 'Address line'),
                    ),
                    SizedBox(height: BaseSpacing.sm),
                    CustomTextField(
                      label: 'City',
                      controller: _cityCtrl,
                      isborder: true,
                      validator: (v) => _requiredValidator(v, 'City'),
                    ),
                    SizedBox(height: BaseSpacing.sm),
                    CustomTextField(label: 'Phone (optional)', controller: _phoneCtrl, isborder: true, keyboardType: TextInputType.phone),
                  ],
                  SizedBox(height: BaseSpacing.sm),
                  CustomText(text: 'Status', color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                  SizedBox(height: BaseSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm),
                    decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.md)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _status,
                        isExpanded: true,
                        items: _kServiceStatuses
                            .map((s) => DropdownMenuItem(value: s, child: CustomText(text: s, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _status = v);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => PrimaryButton(
                      label: _isEdit ? 'Save Changes' : 'Create Service',
                      isLoading: widget.controller.isSavingService.value,
                      onPressed: widget.controller.isSavingService.value ? null : _submit,
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Availability editor — 7 weekly rows (Sun–Sat)
// ─────────────────────────────────────────────────────────────────────────

class _AvailabilityFormSheet extends StatefulWidget {
  final SellerServicesController controller;
  final BookableServiceModel service;
  const _AvailabilityFormSheet({required this.controller, required this.service});

  static void show(BuildContext context, SellerServicesController controller, BookableServiceModel service) {
    Get.bottomSheet(
      _AvailabilityFormSheet(controller: controller, service: service),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_AvailabilityFormSheet> createState() => _AvailabilityFormSheetState();
}

class _AvailabilityFormSheetState extends State<_AvailabilityFormSheet> {
  late List<bool> _enabled;
  late List<String> _startTimes;
  late List<String> _endTimes;

  @override
  void initState() {
    super.initState();
    _enabled = List.filled(7, false);
    _startTimes = List.filled(7, '09:00');
    _endTimes = List.filled(7, '17:00');
    for (final rule in widget.controller.availability.value.weeklyRules) {
      if (rule.dayOfWeek < 0 || rule.dayOfWeek > 6) continue;
      _enabled[rule.dayOfWeek] = true;
      _startTimes[rule.dayOfWeek] = rule.startTime;
      _endTimes[rule.dayOfWeek] = rule.endTime;
    }
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickStart(int day) async {
    final picked = await showTimePicker(context: context, initialTime: _parseTime(_startTimes[day]));
    if (picked != null) setState(() => _startTimes[day] = _formatTime(picked));
  }

  Future<void> _pickEnd(int day) async {
    final picked = await showTimePicker(context: context, initialTime: _parseTime(_endTimes[day]));
    if (picked != null) setState(() => _endTimes[day] = _formatTime(picked));
  }

  int _minutes(String hhmm) {
    final parts = hhmm.split(':');
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  Future<void> _submit() async {
    if (!_enabled.contains(true)) {
      ToastUtil.showToast('Turn on at least one day so buyers have something to book.');
      return;
    }
    for (var day = 0; day < 7; day++) {
      if (_enabled[day] && _minutes(_endTimes[day]) <= _minutes(_startTimes[day])) {
        ToastUtil.showToast('${_kWeekdayNames[day]}: end time must be after the start time.');
        return;
      }
    }

    final rules = <WeeklyRuleModel>[];
    for (var day = 0; day < 7; day++) {
      if (_enabled[day]) rules.add(WeeklyRuleModel(dayOfWeek: day, startTime: _startTimes[day], endTime: _endTimes[day]));
    }
    final ok = await widget.controller.saveAvailability(widget.service.id, rules);
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: EdgeInsets.only(bottom: BaseSpacing.md),
                  decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              CustomText(text: 'Weekly Availability', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
              SizedBox(height: BaseSpacing.xxs),
              CustomText(text: widget.service.name, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
              SizedBox(height: BaseSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(7, (day) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: BaseSpacing.sm),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: CustomText(text: _kWeekdayNames[day], color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                            ),
                            Switch(
                              value: _enabled[day],
                              activeColor: AppColors.primaryColor,
                              onChanged: (v) => setState(() => _enabled[day] = v),
                            ),
                            if (_enabled[day]) ...[
                              Expanded(child: _TimeChip(label: _startTimes[day], onTap: () => _pickStart(day))),
                              SizedBox(width: BaseSpacing.xs),
                              CustomText(text: '–', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                              SizedBox(width: BaseSpacing.xs),
                              Expanded(child: _TimeChip(label: _endTimes[day], onTap: () => _pickEnd(day))),
                            ] else
                              Expanded(
                                child: CustomText(text: 'Closed', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: BaseSpacing.md),
              Obx(
                () => PrimaryButton(
                  label: 'Save Availability',
                  isLoading: widget.controller.isSavingAvailability.value,
                  onPressed: widget.controller.isSavingAvailability.value ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimeChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.sm)),
        child: CustomText(text: label, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Packages list + form
// ─────────────────────────────────────────────────────────────────────────

class _PackagesSheet extends StatelessWidget {
  final SellerServicesController controller;
  final BookableServiceModel service;
  const _PackagesSheet({required this.controller, required this.service});

  static void show(BuildContext context, SellerServicesController controller, BookableServiceModel service) {
    Get.bottomSheet(
      _PackagesSheet(controller: controller, service: service),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmArchive(BuildContext context, ServicePackageModel package) {
    CustomConfirmDialog.show(
      context,
      title: 'Archive "${package.name}"?',
      message: 'This package will no longer be available for purchase.',
      confirmLabel: 'Archive',
      confirmColor: AppColors.red,
      onConfirm: () => controller.archivePackage(service.id, package),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: EdgeInsets.only(bottom: BaseSpacing.md),
                  decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomText(text: 'Packages · ${service.name}', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryColor),
                    onPressed: () => _PackageFormSheet.show(context, controller, service),
                  ),
                ],
              ),
              SizedBox(height: BaseSpacing.sm),
              Flexible(
                child: Obx(() {
                  if (controller.isLoadingPackages.value) {
                    return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
                  }
                  if (controller.packages.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
                      child: Center(
                        child: CustomText(text: 'No packages yet. Add a multi-session package to sell.', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.packages.length,
                    separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
                    itemBuilder: (_, i) {
                      final pkg = controller.packages[i];
                      return _PackageRow(
                        package: pkg,
                        onEdit: () => _PackageFormSheet.show(context, controller, service, existing: pkg),
                        onArchive: () => _confirmArchive(context, pkg),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageRow extends StatelessWidget {
  final ServicePackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  const _PackageRow({required this.package, required this.onEdit, required this.onArchive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.md)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: package.name, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                CustomText(
                  text: '${package.sessionsCount} sessions · \$${package.price.toStringAsFixed(2)} ${package.currency} · ${package.validityDays}d',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          if (!package.isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
              decoration: BoxDecoration(color: AppColors.gray600.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
              child: CustomText(text: 'Archived', color: AppColors.gray600, fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          IconButton(icon: Icon(Icons.edit_outlined, size: 16, color: AppColors.gray600), onPressed: onEdit),
          if (package.isActive) IconButton(icon: Icon(Icons.archive_outlined, size: 16, color: AppColors.gray600), onPressed: onArchive),
        ],
      ),
    );
  }
}

class _PackageFormSheet extends StatefulWidget {
  final SellerServicesController controller;
  final BookableServiceModel service;
  final ServicePackageModel? existing;
  const _PackageFormSheet({required this.controller, required this.service, this.existing});

  static void show(BuildContext context, SellerServicesController controller, BookableServiceModel service, {ServicePackageModel? existing}) {
    Get.bottomSheet(
      _PackageFormSheet(controller: controller, service: service, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_PackageFormSheet> createState() => _PackageFormSheetState();
}

class _PackageFormSheetState extends State<_PackageFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _sessionsCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _validityCtrl;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _sessionsCtrl = TextEditingController(text: e?.sessionsCount.toString() ?? '5');
    _priceCtrl = TextEditingController(text: e?.price.toString() ?? '');
    _currencyCtrl = TextEditingController(text: e?.currency ?? 'USD');
    _validityCtrl = TextEditingController(text: e?.validityDays.toString() ?? '90');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sessionsCtrl.dispose();
    _priceCtrl.dispose();
    _currencyCtrl.dispose();
    _validityCtrl.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  String? _positiveIntValidator(String? value, String label) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null) return '$label must be a number';
    if (n <= 0) return '$label must be greater than 0';
    return null;
  }

  String? _nonNegativeNumValidator(String? value, String label) {
    final n = double.tryParse((value ?? '').trim());
    if (n == null) return '$label must be a number';
    if (n < 0) return '$label cannot be negative';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final body = {
      'name': _nameCtrl.text.trim(),
      'sessionsCount': int.parse(_sessionsCtrl.text.trim()),
      'price': double.parse(_priceCtrl.text.trim()),
      'currency': _currencyCtrl.text.trim().isEmpty ? 'USD' : _currencyCtrl.text.trim().toUpperCase(),
      'validityDays': int.parse(_validityCtrl.text.trim()),
    };

    bool ok;
    if (_isEdit) {
      ok = await widget.controller.updatePackage(widget.service.id, widget.existing!, body);
    } else {
      ok = await widget.controller.createPackage(widget.service.id, body);
    }
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: EdgeInsets.only(bottom: BaseSpacing.md),
                      decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  CustomText(text: _isEdit ? 'Edit Package' : 'Create Package', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(
                    label: 'Package Name',
                    hintText: 'e.g. 5-Session Bundle',
                    controller: _nameCtrl,
                    isborder: true,
                    validator: (v) => _requiredValidator(v, 'Package name'),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Number of Sessions',
                    controller: _sessionsCtrl,
                    isborder: true,
                    keyboardType: TextInputType.number,
                    validator: (v) => _positiveIntValidator(v, 'Sessions'),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Price',
                          controller: _priceCtrl,
                          isborder: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => _nonNegativeNumValidator(v, 'Price'),
                        ),
                      ),
                      SizedBox(width: BaseSpacing.sm),
                      Expanded(
                        child: CustomTextField(
                          label: 'Currency',
                          controller: _currencyCtrl,
                          isborder: true,
                          validator: (v) => _requiredValidator(v, 'Currency'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Validity (days)',
                    controller: _validityCtrl,
                    isborder: true,
                    keyboardType: TextInputType.number,
                    validator: (v) => _positiveIntValidator(v, 'Validity'),
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => PrimaryButton(
                      label: _isEdit ? 'Save Changes' : 'Create Package',
                      isLoading: widget.controller.isSavingPackage.value,
                      onPressed: widget.controller.isSavingPackage.value ? null : _submit,
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
