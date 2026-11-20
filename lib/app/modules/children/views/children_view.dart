import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/repositories/children_repository.dart';
import 'package:book_store_app/app/modules/children/controllers/children_controller.dart';
import 'package:book_store_app/app/modules/seller/utils/publish_rules.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// My children (B4): list, add, edit, delete.
class ChildrenView extends GetView<ChildrenController> {
  const ChildrenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My children'.tr)),
      floatingActionButton: Obx(() => controller.isLoading.value || controller.failed.value
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              key: const Key('addChild'),
              onPressed: controller.atLimit
                  ? () => Get.snackbar('My children'.tr, '${'You can save up to'.tr} ${controller.limit.value}')
                  : () => ChildForm.open(controller),
              icon: const Icon(Icons.add_rounded),
              label: Text('${'Add child'.tr} (${controller.children.length}/${controller.limit.value})'),
            )),
      body: Obx(() {
        if (controller.isLoading.value) return const BuyerSkeleton(rows: 3);
        if (controller.failed.value) return BuyerError(message: 'Could not load your children.'.tr, onRetry: controller.load);
        if (controller.children.isEmpty) {
          return BuyerEmpty(
            icon: Icons.child_care_outlined,
            title: 'No children added yet'.tr,
            body: 'Add a child to see books and courses for their class.'.tr,
          );
        }
        return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
          for (final c in controller.children)
            Card(
              child: ListTile(
                key: Key('child_${c.id}'),
                minTileHeight: 64,
                leading: const CircleAvatar(child: Icon(Icons.child_care_rounded)),
                title: Text(c.name),
                subtitle: Text([
                  if (c.gradeLabel != null) PublishRules.classLabel(c.gradeLabel),
                  if (c.age != null) '${'Age'.tr} ${c.age}',
                  if (c.subjects.isNotEmpty) c.subjects.join(', '),
                ].join(' · ')),
                trailing: PopupMenuButton<String>(
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  onSelected: (v) async {
                    if (v == 'edit') return ChildForm.open(controller, child: c);
                    final ok = await Get.dialog<bool>(AlertDialog(
                      title: Text('Remove this child?'.tr),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel'.tr)),
                        FilledButton(onPressed: () => Get.back(result: true), child: Text('Remove'.tr)),
                      ],
                    ));
                    if (ok == true) await controller.remove(c);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit'.tr)),
                    PopupMenuItem(value: 'delete', child: Text('Remove'.tr)),
                  ],
                ),
              ),
            ),
        ]);
      }),
    );
  }
}

class ChildForm extends StatefulWidget {
  const ChildForm({super.key, required this.controller, this.child});
  final ChildrenController controller;
  final Child? child;

  static Future<void> open(ChildrenController c, {Child? child}) => Get.bottomSheet(
        ChildForm(controller: c, child: child),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  @override
  State<ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<ChildForm> {
  late final _name = TextEditingController(text: widget.child?.name ?? '');
  late final _age = TextEditingController(text: widget.child?.age?.toString() ?? '');
  late final _subjects = TextEditingController(text: widget.child?.subjects.join(', ') ?? '');
  late String? _class = PublishRules.knownClass(widget.child?.gradeLabel);
  Map<String, String> _errors = {};

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _subjects.dispose();
    super.dispose();
  }

  List<String> get _subjectList => _subjects.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  Future<void> _save() async {
    final e = ChildrenController.validate(name: _name.text, gradeLabel: _class, age: _age.text, subjects: _subjectList);
    setState(() => _errors = e);
    if (e.isNotEmpty) return;
    final ok = await widget.controller.save(Child(
      id: widget.child?.id ?? '',
      name: _name.text,
      gradeLabel: _class,
      age: int.tryParse(_age.text.trim()),
      subjects: _subjectList,
    ));
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.child == null ? 'Add child'.tr : 'Edit child'.tr, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            key: const Key('childName'),
            controller: _name,
            maxLength: 60,
            decoration: InputDecoration(labelText: '${'Name'.tr} *', errorText: _errors['name'], border: const OutlineInputBorder()),
          ),
          DropdownButtonFormField<String>(
            key: const Key('childClass'),
            initialValue: _class,
            decoration: InputDecoration(labelText: '${'Class'.tr} *', errorText: _errors['class'], border: const OutlineInputBorder()),
            items: [for (final c in kClassLevels) DropdownMenuItem(value: c.slug, child: Text(c.label))],
            onChanged: (v) => setState(() => _class = v),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('childAge'),
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Age (optional)'.tr, errorText: _errors['age'], border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('childSubjects'),
            controller: _subjects,
            decoration: InputDecoration(
              labelText: 'Subjects (optional)'.tr,
              helperText: 'Separate with commas, up to 10'.tr,
              errorText: _errors['subjects'],
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => FilledButton(
                key: const Key('childSave'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: widget.controller.saving.value ? null : _save,
                child: Text('Save'.tr),
              )),
        ]),
      ),
    );
  }
}
