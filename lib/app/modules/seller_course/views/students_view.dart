import 'package:book_store_app/app/data/repositories/seller_students_repository.dart';
import 'package:book_store_app/app/modules/seller/widgets/screen_states.dart';
import 'package:book_store_app/app/modules/seller_course/controllers/students_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Students (English, seller panel; checklist #14b).
class StudentsView extends GetView<StudentsController> {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          Obx(() => IconButton(
                key: const Key('exportStudents'),
                tooltip: 'Export CSV',
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: controller.exporting.value || controller.rows.isEmpty ? null : controller.exportCsv,
                icon: controller.exporting.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded),
              )),
        ],
      ),
      body: Obx(() {
        final p = controller.page.value;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300) controller.loadMore();
              return false;
            },
            child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  _Stat('Students', '${p.totalStudents}'),
                  _Stat('Avg. completion', p.avgCompletionPct == null ? '–' : '${p.avgCompletionPct!.round()}%'),
                  _Stat('Active 7 d', '${p.active7d}'),
                ]),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(children: [
                  for (final s in StudentStatus.values)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        key: Key('st_${s.name}'),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text('${s.label} (${p.counts[s] ?? 0})'),
                        selected: controller.status.value == s,
                        onSelected: (_) => controller.setStatus(s),
                      ),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      key: const Key('studentSearch'),
                      onChanged: controller.onSearch,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search students',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<StudentSort>(
                    tooltip: 'Sort',
                    style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                    initialValue: controller.sort.value,
                    onSelected: controller.setSort,
                    icon: const Icon(Icons.sort_rounded),
                    itemBuilder: (_) => [for (final s in StudentSort.values) PopupMenuItem(value: s, child: Text(s.label))],
                  ),
                ]),
              ),
              if (p.products.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DropdownButtonFormField<String?>(
                    initialValue: controller.productId.value,
                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder(), isDense: true),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('All products')),
                      for (final pr in p.products)
                        DropdownMenuItem<String?>(value: pr.id, child: Text(pr.name, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: controller.setProduct,
                  ),
                ),
              const SizedBox(height: 8),
              if (controller.isLoading.value)
                const SizedBox(height: 400, child: ListSkeleton(rows: 5))
              else if (controller.failed.value)
                SizedBox(height: 320, child: ErrorRetry(message: 'Could not load your students.', onRetry: controller.load))
              else if (controller.rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: EmptyMessage(
                    icon: Icons.school_outlined,
                    title: 'No students yet',
                    body: 'Buyers of your digital products and courses show here, with their progress.',
                  ),
                )
              else
                for (final s in controller.rows) _StudentTile(student: s, controller: controller),
              if (controller.isLoadingMore.value)
                const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            ]),
          ),
        );
      }),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: t.textTheme.titleMedium),
        Text(label, style: t.textTheme.bodySmall),
      ]),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.controller});
  final StudentRow student;
  final StudentsController controller;

  @override
  Widget build(BuildContext context) {
    final s = student;
    final t = Theme.of(context);
    final df = DateFormat('d MMM y');
    return ListTile(
      key: Key('student_${s.buyerId}_${s.productId}'),
      minVerticalPadding: 10,
      title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (s.maskedEmail != null) Text(StudentRow.mask(s.maskedEmail!)),
        if (s.productName != null) Text(s.productName!, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        if (s.progressPct != null)
          Row(children: [
            Expanded(child: LinearProgressIndicator(value: (s.progressPct!.clamp(0, 100)) / 100)),
            const SizedBox(width: 8),
            Text('${s.progressPct}%'),
          ]),
        Text(
          [
            if (s.status != null) s.status!.label,
            if (s.lessonsDone != null) '${s.lessonsDone}${s.lessonsTotal != null ? '/${s.lessonsTotal}' : ''} lessons',
            if (s.downloads != null) '${s.downloads} downloads',
            if (s.isFree) 'Free',
            if (s.enrolledAt != null) 'Joined ${df.format(s.enrolledAt!.toLocal())}',
            if (s.lastActivityAt != null) 'Active ${df.format(s.lastActivityAt!.toLocal())}',
          ].join(' · '),
          style: t.textTheme.bodySmall,
        ),
      ]),
      trailing: Obx(() => IconButton(
            key: Key('msg_${s.buyerId}'),
            tooltip: 'Message student',
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: s.buyerId.isEmpty || controller.opening.contains(s.buyerId) ? null : () => controller.message(s),
            icon: controller.opening.contains(s.buyerId)
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chat_bubble_outline_rounded),
          )),
    );
  }
}
