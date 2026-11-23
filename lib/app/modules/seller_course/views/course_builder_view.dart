import 'package:book_store_app/app/data/repositories/seller_course_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/seller/widgets/screen_states.dart';
import 'package:book_store_app/app/modules/seller_course/controllers/course_builder_controller.dart';
import 'package:book_store_app/app/modules/seller_course/widgets/lesson_editor_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Course builder (English, seller panel; checklist #14a).
class CourseBuilderView extends GetView<CourseBuilderController> {
  const CourseBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: !controller.dirty.value,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirm('Discard changes?', 'Your course changes are not saved.', 'Discard')) {
              controller.dirty.value = false;
              Get.back();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(controller.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  key: const Key('openStudents'),
                  tooltip: 'Students',
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => Get.toNamed(Routes.sellerStudents, arguments: {'productId': controller.productId}),
                  icon: const Icon(Icons.people_alt_outlined),
                ),
              ],
            ),
            body: controller.isLoading.value
                ? const ListSkeleton(rows: 5, rowHeight: 88)
                : controller.failed.value || controller.content.value == null
                    ? ErrorRetry(message: controller.loadError.value ?? 'Could not load the course.', onRetry: controller.load)
                    : _body(context, controller.content.value!),
            bottomNavigationBar: controller.content.value == null
                ? null
                : SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: FilledButton(
                        key: const Key('saveCourse'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        onPressed: controller.saving.value || !controller.dirty.value ? null : controller.save,
                        child: controller.saving.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save course'),
                      ),
                    ),
                  ),
          ),
        ));
  }

  Widget _body(BuildContext context, CourseContent c) {
    final t = Theme.of(context);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
      if (c.deliveryFormat.isNotEmpty && c.deliveryFormat != 'course')
        Card(
          color: t.colorScheme.tertiaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('This product is sold as a download. Buyers only see lessons when the product is an online course.'),
          ),
        ),
      Text('${c.learners} learner${c.learners == 1 ? '' : 's'}', style: t.textTheme.bodySmall),
      const _Header('Lessons'),
      if (c.sections.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('No sections yet. Add a section, then add video lessons to it.'),
        ),
      for (var i = 0; i < c.sections.length; i++) _SectionCard(index: i, section: c.sections[i], controller: controller),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const Key('addSection'),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () async {
            final name = await _askText('New section', 'Section title', maxLength: CourseSection.maxTitle, required: true);
            if (name != null) controller.addSection(name);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add section'),
        ),
      ),
      const _Header('What students will learn'),
      for (final o in c.outcomes) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_rounded), title: Text(o)),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(
          key: const Key('editOutcomes'),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => _editOutcomes(c),
          child: Text(c.outcomes.isEmpty ? 'Add outcomes' : 'Edit outcomes'),
        ),
      ),
      const _Header('Instructor'),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(c.instructorName.isEmpty ? 'Not set' : c.instructorName),
        subtitle: c.instructorBio.isEmpty ? null : Text(c.instructorBio, maxLines: 3, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => _editInstructor(c),
      ),
      const _Header('Access'),
      RadioGroup<bool>(
        groupValue: c.accessDays == null,
        onChanged: (lifetime) async {
          if (lifetime == true) return controller.setAccessDays(null);
          final d = await _askText('Access period', 'Days (1 to 3650)',
              number: true, initial: '${c.accessDays ?? 365}', validate: CourseBuilderController.validateAccessDays);
          if (d != null) controller.setAccessDays(int.parse(d));
        },
        child: Column(children: [
          const RadioListTile<bool>(contentPadding: EdgeInsets.zero, value: true, title: Text('Lifetime access')),
          RadioListTile<bool>(
            contentPadding: EdgeInsets.zero,
            value: false,
            title: Text(c.accessDays == null ? 'Limited time' : 'Limited: ${c.accessDays} days after purchase'),
          ),
        ]),
      ),
      const _Header('Certificate'),
      SwitchListTile(
        key: const Key('certEnabled'),
        contentPadding: EdgeInsets.zero,
        title: const Text('Give a certificate on completion'),
        value: c.certificateEnabled,
        onChanged: controller.setCertificateEnabled,
      ),
      if (c.certificateEnabled) _CertificateDesign(controller: controller, content: c),
    ]);
  }

  Future<void> _editOutcomes(CourseContent c) async {
    final text = await _askText('Outcomes', 'One per line (up to 10, 200 characters each)',
        initial: c.outcomes.join('\n'), lines: 6, validate: (v) {
      final items = v.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (items.length > CourseContent.maxOutcomes) return 'Add up to 10 learning outcomes.';
      if (items.any((e) => e.length > CourseContent.maxOutcome)) return 'An outcome can be up to 200 characters.';
      return null;
    });
    if (text != null) controller.setOutcomes(text.split('\n'));
  }

  Future<void> _editInstructor(CourseContent c) async {
    final name = await _askText('Instructor', 'Name', initial: c.instructorName, maxLength: CourseContent.maxInstructorName);
    if (name == null) return;
    final bio = await _askText('Instructor', 'Short bio', initial: c.instructorBio, maxLength: CourseContent.maxBio, lines: 5);
    controller.setInstructor(name, bio ?? c.instructorBio);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.index, required this.section, required this.controller});
  final int index;
  final CourseSection section;
  final CourseBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(section.title, style: t.textTheme.titleSmall)),
            PopupMenuButton<String>(
              key: Key('sectionMenu_$index'),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
              onSelected: (v) async {
                switch (v) {
                  case 'rename':
                    final n = await _askText('Rename section', 'Section title', initial: section.title, maxLength: CourseSection.maxTitle, required: true);
                    if (n != null) controller.renameSection(index, n);
                  case 'up':
                    controller.moveSection(index, -1);
                  case 'down':
                    controller.moveSection(index, 1);
                  case 'delete':
                    if (await _confirm('Delete section?', '"${section.title}" and its ${section.lessons.length} lessons will be removed when you save.', 'Delete')) {
                      controller.removeSection(index);
                    }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'up', child: Text('Move up')),
                PopupMenuItem(value: 'down', child: Text('Move down')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ]),
          for (var j = 0; j < section.lessons.length; j++)
            ListTile(
              key: Key('lesson_${index}_$j'),
              contentPadding: EdgeInsets.zero,
              minTileHeight: 48,
              leading: Icon(section.lessons[j].isLegacy ? Icons.description_outlined : Icons.play_circle_outline_rounded),
              title: Text(section.lessons[j].title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text([
                section.lessons[j].sourceLabel,
                if (section.lessons[j].durationMinutes != null) '${section.lessons[j].durationMinutes} min',
                if (section.lessons[j].isPreview) 'Free preview',
              ].join(' · ')),
              trailing: PopupMenuButton<String>(
                style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
                onSelected: (v) async {
                  final l = section.lessons[j];
                  switch (v) {
                    case 'edit':
                      if (l.isLegacy) {
                        final n = await _askText('Rename lesson', 'Lesson title', initial: l.title, maxLength: CourseLesson.maxTitle, required: true);
                        if (n != null) {
                          l.title = n.trim();
                          controller.putLesson(index, l, index: j);
                        }
                      } else {
                        final edited = await LessonEditorSheet.open(controller.repo, lesson: l);
                        if (edited != null) controller.putLesson(index, edited, index: j);
                      }
                    case 'up':
                      controller.moveLesson(index, j, -1);
                    case 'down':
                      controller.moveLesson(index, j, 1);
                    case 'delete':
                      controller.removeLesson(index, j);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'up', child: Text('Move up')),
                  PopupMenuItem(value: 'down', child: Text('Move down')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: Key('addLesson_$index'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
              onPressed: () async {
                final l = await LessonEditorSheet.open(controller.repo);
                if (l != null) controller.putLesson(index, l);
              },
              icon: const Icon(Icons.video_call_outlined),
              label: const Text('Add video lesson'),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Certificate design + live preview. Images must be uploaded through
/// Edudeen (the API rejects other URLs).
class _CertificateDesign extends StatelessWidget {
  const _CertificateDesign({required this.controller, required this.content});
  final CourseBuilderController controller;
  final CourseContent content;

  @override
  Widget build(BuildContext context) {
    final cert = content.certificate;
    String v(String k) => '${cert[k] ?? ''}';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _CertificatePreview(course: content.productName, cert: cert),
      const SizedBox(height: 12),
      for (final (key, label, max) in [
        ('issuerName', 'Issued by', CourseContent.maxCertText),
        ('signatureName', 'Signed by (name)', CourseContent.maxCertText),
        ('signatureTitle', 'Signer title (e.g. Instructor)', CourseContent.maxCertText),
        ('watermarkText', 'Watermark text', CourseContent.maxWatermark),
      ])
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 48,
          title: Text(label),
          subtitle: Text(v(key).isEmpty ? 'Not set' : v(key)),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final r = await _askText('Certificate', label, initial: v(key), maxLength: max);
            if (r != null) controller.setCertificate(key, r);
          },
        ),
      for (final (key, label) in [
        ('signatureImageUrl', 'Signature image'),
        ('stampImageUrl', 'Stamp image'),
        ('watermarkImageUrl', 'Watermark image'),
      ])
        _ImageRow(label: label, url: cert[key] as String?, onChanged: (u) => controller.setCertificate(key, u)),
    ]);
  }
}

class _ImageRow extends StatefulWidget {
  const _ImageRow({required this.label, required this.url, required this.onChanged});
  final String label;
  final String? url;
  final ValueChanged<String?> onChanged;

  @override
  State<_ImageRow> createState() => _ImageRowState();
}

class _ImageRowState extends State<_ImageRow> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _pickAndUpload() async {
    final repo = UploadRepository();
    final file = await repo.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final url = await repo.uploadImage(file);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = url == null;
    });
    if (url != null) widget.onChanged(url);
  }

  @override
  Widget build(BuildContext context) {
    final has = (widget.url ?? '').isNotEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 56,
      leading: SizedBox(
        width: 44,
        height: 44,
        child: _busy
            ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))
            : has
                ? CachedNetworkImage(imageUrl: widget.url!, fit: BoxFit.contain)
                : const Icon(Icons.image_outlined),
      ),
      title: Text(widget.label),
      subtitle: _failed ? Text('Upload failed.', style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (_failed)
          TextButton(style: TextButton.styleFrom(minimumSize: const Size(48, 44)), onPressed: _pickAndUpload, child: const Text('Retry'))
        else
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
            onPressed: _busy ? null : _pickAndUpload,
            child: Text(has ? 'Change' : 'Upload'),
          ),
        if (has && !_busy)
          IconButton(
            tooltip: 'Remove',
            style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            onPressed: () => widget.onChanged(null),
            icon: const Icon(Icons.close_rounded),
          ),
      ]),
    );
  }
}

class _CertificatePreview extends StatelessWidget {
  const _CertificatePreview({required this.course, required this.cert});
  final String course;
  final Map<String, dynamic> cert;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    String? s(String k) => (cert[k] as String?)?.trim().isEmpty == true ? null : cert[k] as String?;
    Widget img(String? url, double h) => url == null ? SizedBox(height: h) : CachedNetworkImage(imageUrl: url, height: h, fit: BoxFit.contain);
    return AspectRatio(
      aspectRatio: 297 / 210, // A4 landscape
      child: Container(
        key: const Key('certPreview'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: t.colorScheme.outline, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(children: [
          if (s('watermarkImageUrl') != null)
            Positioned.fill(child: Opacity(opacity: 0.08, child: img(s('watermarkImageUrl'), 120))),
          if (s('watermarkText') != null)
            Center(
              child: Transform.rotate(
                angle: -0.35,
                child: Text(s('watermarkText')!,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black.withValues(alpha: 0.06))),
              ),
            ),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Certificate of Completion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
            Column(children: [
              const Text('Student name', style: TextStyle(fontSize: 14, color: Colors.black54)),
              Text(course, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  img(s('signatureImageUrl'), 22),
                  Text(s('signatureName') ?? 'Signer name', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                  Text(s('signatureTitle') ?? 'Title', style: const TextStyle(fontSize: 9, color: Colors.black54)),
                ]),
              ),
              img(s('stampImageUrl'), 36),
              Expanded(
                child: Text(s('issuerName') ?? 'Issuer', textAlign: TextAlign.end, style: const TextStyle(fontSize: 10, color: Colors.black87)),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }
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

Future<bool> _confirm(String title, String body, String action) async =>
    await Get.dialog<bool>(AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(style: TextButton.styleFrom(minimumSize: const Size(64, 48)), onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(style: TextButton.styleFrom(minimumSize: const Size(64, 48)), onPressed: () => Get.back(result: true), child: Text(action)),
      ],
    )) ??
    false;

/// Text prompt with validation. Returns null when cancelled.
Future<String?> _askText(String title, String label,
    {String initial = '', int? maxLength, int lines = 1, bool number = false, bool required = false, String? Function(String)? validate}) {
  final c = TextEditingController(text: initial);
  String? error;
  return Get.dialog<String>(StatefulBuilder(
    builder: (context, setState) => AlertDialog(
      title: Text(title),
      content: TextField(
        key: const Key('askField'),
        controller: c,
        autofocus: true,
        maxLength: maxLength,
        minLines: lines,
        maxLines: lines,
        keyboardType: number ? TextInputType.number : null,
        decoration: InputDecoration(labelText: label, errorText: error, border: const OutlineInputBorder()),
      ),
      actions: [
        TextButton(style: TextButton.styleFrom(minimumSize: const Size(64, 48)), onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          key: const Key('askOk'),
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () {
            final v = c.text;
            final e = validate?.call(v) ?? (required && v.trim().isEmpty ? 'Required.' : null);
            if (e != null) return setState(() => error = e);
            Get.back(result: v);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  ));
}
