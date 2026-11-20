import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/bottom_bar/widget/app_nav_bar.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/modules/library/controllers/library_controller.dart';
import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/theme/base_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/core/widgets/base_error_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Library tab (docs §5.9): Files | Courses, each with loading skeleton,
/// error + Retry, empty and signed-out states.
class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<LibraryController>()
        ? Get.find<LibraryController>()
        : Get.put(LibraryController());
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Library'.tr, style: theme.textTheme.headlineMedium),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  BaseSpacing.md, 0, BaseSpacing.md, BaseSpacing.xs),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                child: TabBar(
                  tabs: [
                    Tab(text: 'Files'.tr),
                    Tab(text: 'Courses'.tr),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _FilesTab(c: c),
            _CoursesTab(c: c),
          ],
        ),
      ),
    );
  }
}

// ── Shared pieces ────────────────────────────────────────────────────────

class _GuestState extends StatelessWidget {
  const _GuestState();

  @override
  Widget build(BuildContext context) {
    return BaseEmptyView(
      icon: Icons.lock_outline_rounded,
      title: 'Sign in to see your library'.tr,
      subtitle:
          'Digital files and courses you buy or avail for free appear here.'.tr,
      actionLabel: 'Sign in'.tr,
      onAction: () async {
        await Get.toNamed(Routes.authTabView);
        if (Get.isRegistered<LibraryController>()) {
          Get.find<LibraryController>().loadAll();
        }
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(BaseRadius.sm),
          ),
        );
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(BaseSpacing.md),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: BaseSpacing.sm),
      itemBuilder: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(BaseSpacing.sm),
          child: Row(
            children: [
              bar(56, 72),
              const SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(double.infinity, 14),
                    const SizedBox(height: 8),
                    bar(120, 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _thumb(BuildContext context, String? url, IconData fallback) {
  final scheme = Theme.of(context).colorScheme;
  return ClipRRect(
    borderRadius: BorderRadius.circular(BaseRadius.sm),
    child: Container(
      width: 56,
      height: 72,
      color: scheme.surfaceContainerHighest,
      child: (url == null || url.isEmpty)
          ? Icon(fallback, color: scheme.onSurfaceVariant)
          : CommonImageView(url: url, width: 56, height: 72, fit: BoxFit.contain),
    ),
  );
}

// ── Files ────────────────────────────────────────────────────────────────

class _FilesTab extends StatelessWidget {
  const _FilesTab({required this.c});
  final LibraryController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.filesState.value) {
        case LibraryLoad.guest:
          return const _GuestState();
        case LibraryLoad.loading:
          return const _ListSkeleton();
        case LibraryLoad.error:
          return BaseErrorView(
            message: 'Something went wrong. Please try again.'.tr,
            retryLabel: 'Try again'.tr,
            onRetry: c.loadFiles,
          );
        case LibraryLoad.ready:
          break;
      }
      final files = c.visibleFiles;
      return RefreshIndicator(
        onRefresh: c.loadFiles,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm,
              BaseSpacing.md, AppNavBar.contentBottomInset),
          children: [
            Row(
              children: [
                FilterChip(
                  label: Text('Last 30 days'.tr),
                  selected: c.recentOnly.value,
                  onSelected: (v) => c.recentOnly.value = v,
                ),
                const Spacer(),
                Text('${files.length}',
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: BaseSpacing.sm),
            if (files.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: BaseSpacing.xxl),
                child: BaseEmptyView(
                  icon: Icons.folder_open_rounded,
                  title: 'Your library is empty'.tr,
                  subtitle:
                      'Digital files and courses you buy or avail for free appear here.'.tr,
                  actionLabel: 'Browse resources'.tr,
                  onAction: () => Get.find<BottomNavController>()
                      .changeTab(BottomNavController.browse),
                ),
              )
            else
              for (final f in files) ...[
                _FileCard(file: f, c: c),
                const SizedBox(height: BaseSpacing.sm),
              ],
          ],
        ),
      );
    });
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.c});
  final LibraryFile file;
  final LibraryController c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('d MMM yyyy').format(file.purchasedAt);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        onTap: () => Get.toNamed(Routes.productDetailsView,
            arguments: {'productId': file.productId}),
        child: Padding(
          padding: const EdgeInsets.all(BaseSpacing.sm),
          child: Row(
            children: [
              _thumb(context, file.image, Icons.description_outlined),
              const SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if ((file.storeName ?? '').isNotEmpty)
                          file.storeName!,
                        date,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text('#${file.orderNumber}',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: BaseSpacing.xs),
              if (file.canDownload)
                Obx(() {
                  final busy = c.downloads.isBusy(file.key);
                  return FilledButton.tonalIcon(
                    onPressed: busy ? null : () => c.download(file),
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(busy ? 'Preparing…'.tr : 'Download'.tr),
                  );
                })
              else if (file.unavailable == 'expired')
                Chip(label: Text('Download period ended'.tr))
              else if (!file.available)
                Chip(label: Text('No longer available'.tr))
              else
                Chip(
                  label: Text('Awaiting payment'.tr),
                  backgroundColor: BaseColors.gold.withValues(alpha: 0.18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Courses ──────────────────────────────────────────────────────────────

class _CoursesTab extends StatelessWidget {
  const _CoursesTab({required this.c});
  final LibraryController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.coursesState.value) {
        case LibraryLoad.guest:
          return const _GuestState();
        case LibraryLoad.loading:
          return const _ListSkeleton();
        case LibraryLoad.error:
          return BaseErrorView(
            message: 'Something went wrong. Please try again.'.tr,
            retryLabel: 'Try again'.tr,
            onRetry: c.loadCourses,
          );
        case LibraryLoad.ready:
          break;
      }
      if (c.courses.isEmpty) {
        return RefreshIndicator(
          onRefresh: c.loadCourses,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: BaseSpacing.xxxl),
              BaseEmptyView(
                icon: Icons.play_lesson_outlined,
                title: 'No courses yet'.tr,
                subtitle: 'Online courses you enrol in appear here.'.tr,
                actionLabel: 'Browse resources'.tr,
                onAction: () => Get.find<BottomNavController>()
                    .changeTab(BottomNavController.browse),
              ),
            ],
          ),
        );
      }
      final resume = c.resumeCourse;
      return RefreshIndicator(
        onRefresh: c.loadCourses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm,
              BaseSpacing.md, AppNavBar.contentBottomInset),
          children: [
            if (resume != null) ...[
              _ResumeCard(course: resume),
              const SizedBox(height: BaseSpacing.md),
            ],
            for (final course in c.courses) ...[
              _CourseCard(course: course),
              const SizedBox(height: BaseSpacing.sm),
            ],
          ],
        ),
      );
    });
  }
}

/// The in-app course player is a later phase; until then a course opens on
/// edudeen.com in the in-app browser.
Future<void> _openCourse(LibraryCourse course) async {
  final slug = course.slug;
  if (slug == null) return;
  await Get.toNamed(Routes.coursePlayer, arguments: {'slug': slug});
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.course});
  final LibraryCourse course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: BaseColors.heroGradient,
        borderRadius: BorderRadius.circular(BaseRadius.xl),
      ),
      padding: const EdgeInsets.all(BaseSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Continue learning'.tr,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 6),
          Text(course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          if (course.progress != null) ...[
            const SizedBox(height: BaseSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(BaseRadius.pill),
              child: LinearProgressIndicator(
                value: course.progress! / 100,
                color: BaseColors.gold,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 4),
            Text('${course.progress!.round()}% ${'complete'.tr}',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
          ],
          const SizedBox(height: BaseSpacing.sm),
          if (course.slug != null)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: BaseColors.ink,
              ),
              onPressed: () => _openCourse(course),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Continue learning'.tr),
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final LibraryCourse course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        onTap: course.slug == null || course.accessExpired
            ? null
            : () => _openCourse(course),
        child: Padding(
          padding: const EdgeInsets.all(BaseSpacing.sm),
          child: Row(
            children: [
              _thumb(context, course.image, Icons.play_lesson_outlined),
              const SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall),
                    if (course.accessExpired) ...[
                      const SizedBox(height: BaseSpacing.xs),
                      Text('Access ended'.tr,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.error)),
                    ] else if (course.progress != null) ...[
                      const SizedBox(height: BaseSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(BaseRadius.pill),
                        child: LinearProgressIndicator(value: course.progress! / 100),
                      ),
                      const SizedBox(height: 4),
                      Text('${course.progress!.round()}% ${'complete'.tr}',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: BaseSpacing.xs),
              Icon(
                course.accessExpired
                    ? Icons.lock_clock_outlined
                    : course.started
                    ? Icons.play_circle_fill_rounded
                    : Icons.play_circle_outline_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
