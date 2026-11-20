import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/repositories/course_repository.dart';
import 'package:book_store_app/app/modules/course_player/controllers/course_player_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Course player (B1). Buyer screen: .tr strings, RTL-safe (EdgeInsetsDirectional).
class CoursePlayerView extends GetView<CoursePlayerController> {
  const CoursePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => controller.touched(),
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(controller.course.value?.name ?? 'Course'.tr, maxLines: 1, overflow: TextOverflow.ellipsis)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Obx(() => LinearProgressIndicator(value: controller.course.value == null ? null : controller.percent / 100)),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const BuyerSkeleton(rows: 4, rowHeight: 90);
          if (controller.failed.value || controller.course.value == null) {
            return BuyerError(message: 'Could not open this course.'.tr, onRetry: controller.load);
          }
          if (controller.lessons.isEmpty) {
            return BuyerEmpty(icon: Icons.play_lesson_outlined, title: 'No lessons yet'.tr, body: 'The teacher is still preparing this course.'.tr);
          }
          return Stack(children: [
            ListView(padding: const EdgeInsets.only(bottom: 24), children: [
              const _Media(),
              const _LessonActions(),
              const _CertificateCard(),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
                child: Text('${'Progress'.tr}: ${controller.percent}%', style: Theme.of(context).textTheme.titleSmall),
              ),
              for (final s in controller.course.value!.sections) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
                  child: Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final l in s.lessons) _LessonTile(lesson: l),
              ],
            ]),
            if (controller.askingStillThere.value) const _StillThere(),
          ]);
        }),
      ),
    );
  }
}

class _Media extends GetView<CoursePlayerController> {
  const _Media();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final l = controller.lesson.value;
      Widget child;
      if (controller.lessonLoading.value) {
        child = const Center(child: CircularProgressIndicator());
      } else if (controller.lessonFailed.value || l == null) {
        child = BuyerError(
          message: 'Could not load this lesson.'.tr,
          onRetry: () => controller.currentId.value == null ? null : controller.openLesson(controller.currentId.value!),
        );
      } else if (l.isNativeVideo && controller.video != null) {
        child = _NativeVideo(video: controller.video!);
      } else if (l.isExternalVideo) {
        final embed = LessonContent.embedUrl(l.url!);
        child = embed == null
            ? Center(
                child: TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => launchUrl(Uri.parse(l.url!), mode: LaunchMode.externalApplication),
                  child: Text('Open video'.tr),
                ),
              )
            : _Embed(key: ValueKey(embed), url: embed);
      } else {
        child = _NonVideo(lesson: l);
      }
      return AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: Colors.black, child: child));
    });
  }
}

class _NativeVideo extends GetView<CoursePlayerController> {
  const _NativeVideo({required this.video});
  final VideoPlayerController video;

  String _fmt(Duration d) => '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.videoTick.value; // rebuild on progress
      final v = video.value;
      final total = v.duration.inMilliseconds.toDouble();
      final pos = v.position.inMilliseconds.clamp(0, v.duration.inMilliseconds).toDouble();
      final done = controller.isDone(controller.currentId.value ?? '');
      return Stack(alignment: Alignment.bottomCenter, children: [
        Center(child: AspectRatio(aspectRatio: v.aspectRatio == 0 ? 16 / 9 : v.aspectRatio, child: VideoPlayer(video))),
        Container(
          color: Colors.black45,
          padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 12, 0),
          child: Row(children: [
            IconButton(
              key: const Key('playPause'),
              tooltip: v.isPlaying ? 'Pause'.tr : 'Play'.tr,
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              color: Colors.white,
              onPressed: controller.togglePlay,
              icon: Icon(v.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
            Expanded(
              child: Slider(
                key: const Key('seekBar'),
                value: total <= 0 ? 0 : pos,
                max: total <= 0 ? 1 : total,
                // Not yet complete: the bar cannot go past what was watched.
                secondaryTrackValue: done || total <= 0 ? null : controller.maxWatched.inMilliseconds.clamp(0, total.toInt()).toDouble(),
                onChanged: total <= 0 ? null : (_) {},
                onChangeEnd: (x) => controller.seek(Duration(milliseconds: x.round())),
              ),
            ),
            Text('${_fmt(v.position)} / ${_fmt(v.duration)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ),
      ]);
    });
  }
}

class _Embed extends StatefulWidget {
  const _Embed({super.key, required this.url});
  final String url;

  @override
  State<_Embed> createState() => _EmbedState();
}

class _EmbedState extends State<_Embed> {
  late final WebViewController _web = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.black)
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _web);
}

class _NonVideo extends StatelessWidget {
  const _NonVideo({required this.lesson});
  final LessonContent lesson;

  @override
  Widget build(BuildContext context) {
    final white = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(lesson.type == 'pdf' ? Icons.picture_as_pdf_outlined : lesson.type == 'quiz' ? Icons.quiz_outlined : Icons.article_outlined, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          if (lesson.type == 'text' && lesson.text.trim().isNotEmpty) Text(lesson.text, style: white),
          if (lesson.type == 'pdf' && lesson.url != null)
            FilledButton.tonal(
              style: FilledButton.styleFrom(minimumSize: const Size(140, 48)),
              onPressed: () => launchUrl(Uri.parse(lesson.url!), mode: LaunchMode.inAppBrowserView),
              child: Text('Open PDF'.tr),
            ),
          if (lesson.type == 'quiz') Text('This quiz opens on the Edudeen website.'.tr, style: white, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _LessonActions extends GetView<CoursePlayerController> {
  const _LessonActions();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cur = controller.current;
      if (cur == null) return const SizedBox.shrink();
      final done = controller.isDone(cur.id);
      final l = controller.lesson.value;
      String? hint;
      if (!done && l != null) {
        if (l.isNativeVideo) hint = 'Watch to the end to unlock the next lesson.'.tr;
        if (l.isExternalVideo && controller.externalWait.value > 0) {
          hint = '${'You can mark this lesson as watched in'.tr} ${controller.externalWait.value}s';
        }
      }
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(cur.title, style: Theme.of(context).textTheme.titleMedium),
          if (hint != null) ...[const SizedBox(height: 4), Text(hint, style: Theme.of(context).textTheme.bodySmall)],
          const SizedBox(height: 8),
          Row(children: [
            if (!done && (l?.isNativeVideo != true))
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('markComplete'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: controller.canMarkComplete ? controller.markComplete : null,
                  icon: const Icon(Icons.check_rounded),
                  label: Text((l?.isExternalVideo ?? false) ? 'Mark as watched'.tr : 'Mark complete'.tr),
                ),
              ),
            if (done)
              Expanded(
                child: Row(children: [
                  Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text('Completed'.tr),
                ]),
              ),
            const SizedBox(width: 8),
            if (controller.next != null)
              FilledButton.icon(
                key: const Key('nextLesson'),
                style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
                onPressed: controller.canGoNext ? controller.goNext : null,
                icon: Icon(controller.canGoNext ? Icons.skip_next_rounded : Icons.lock_outline_rounded),
                label: Text('Next'.tr),
              ),
          ]),
        ]),
      );
    });
  }
}

/// Shown when every lesson is complete and the course gives a certificate.
class _CertificateCard extends GetView<CoursePlayerController> {
  const _CertificateCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = controller.course.value;
      final finished = controller.lessons.isNotEmpty && controller.lessons.every((l) => controller.isDone(l.id));
      if (c == null || !c.certificateEnabled || !finished) return const SizedBox.shrink();
      final code = controller.certificateCode.value;
      return Card(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
        child: ListTile(
          key: const Key('certificateCard'),
          minTileHeight: 56,
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(code == null ? 'Get your certificate'.tr : 'Your certificate'.tr),
          subtitle: Text(code ?? 'Add the name to print on it.'.tr),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            if (code != null) {
              Get.toNamed(Routes.certificateView, arguments: {'code': code});
            } else {
              final issued = await Get.toNamed(Routes.certificateDetails, arguments: {'slug': controller.slug});
              if (issued is String && issued.isNotEmpty) controller.certificateCode.value = issued;
            }
          },
        ),
      );
    });
  }
}

class _LessonTile extends GetView<CoursePlayerController> {
  const _LessonTile({required this.lesson});
  final CourseLessonRef lesson;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final done = controller.isDone(lesson.id);
      final open = controller.isUnlocked(lesson.id);
      final active = controller.currentId.value == lesson.id;
      return ListTile(
        key: Key('lesson_${lesson.id}'),
        minTileHeight: 52,
        selected: active,
        leading: Icon(done
            ? Icons.check_circle_rounded
            : open
                ? (lesson.type == 'video' ? Icons.play_circle_outline_rounded : Icons.article_outlined)
                : Icons.lock_outline_rounded),
        title: Text(lesson.title),
        subtitle: lesson.durationMinutes == null ? null : Text('${lesson.durationMinutes} ${'min'.tr}'),
        enabled: open,
        onTap: open && !active ? () => controller.openLesson(lesson.id) : null,
      );
    });
  }
}

class _StillThere extends GetView<CoursePlayerController> {
  const _StillThere();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: Colors.black54,
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Are you still there?'.tr, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('The video paused because there was no activity for a minute.'.tr, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('stillHere'),
                    style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                    onPressed: controller.resumeAfterIdle,
                    child: Text("I'm here, continue".tr),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}
