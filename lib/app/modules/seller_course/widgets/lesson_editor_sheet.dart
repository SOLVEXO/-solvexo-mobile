import 'dart:io';

import 'package:book_store_app/app/data/repositories/seller_course_repository.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum _Source { upload, link }

/// Add / edit one video lesson. Returns the lesson, or null when closed.
class LessonEditorSheet extends StatefulWidget {
  const LessonEditorSheet({super.key, required this.repo, this.lesson});
  final SellerCourseRepository repo;
  final CourseLesson? lesson;

  static Future<CourseLesson?> open(SellerCourseRepository repo, {CourseLesson? lesson}) => Get.bottomSheet<CourseLesson>(
        LessonEditorSheet(repo: repo, lesson: lesson),
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  @override
  State<LessonEditorSheet> createState() => _LessonEditorSheetState();
}

class _LessonEditorSheetState extends State<LessonEditorSheet> {
  late final TextEditingController _title = TextEditingController(text: widget.lesson?.title ?? '');
  late final TextEditingController _link = TextEditingController(text: widget.lesson?.videoUrl ?? '');
  late final TextEditingController _minutes =
      TextEditingController(text: widget.lesson?.durationMinutes?.toString() ?? '');
  late _Source _source = widget.lesson?.isUpload == true ? _Source.upload : (widget.lesson == null ? _Source.upload : _Source.link);
  late bool _preview = widget.lesson?.isPreview ?? false;
  late Map<String, dynamic>? _file = widget.lesson?.file;

  File? _picked;
  double? _progress;
  String? _uploadError;
  CancelToken? _cancel;
  String? _titleError, _linkError, _minutesError;

  bool get _uploading => _progress != null && _uploadError == null;

  @override
  void dispose() {
    _cancel?.cancel();
    _title.dispose();
    _link.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.video);
    final path = r?.files.single.path;
    if (path == null) return;
    _picked = File(path);
    await _upload();
  }

  Future<void> _upload() async {
    final f = _picked;
    if (f == null) return;
    setState(() {
      _progress = 0;
      _uploadError = null;
      _cancel = CancelToken();
    });
    try {
      final file = await widget.repo.uploadVideo(f, cancel: _cancel, onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      });
      if (!mounted) return;
      setState(() {
        _file = file;
        _progress = null;
      });
    } on CourseUploadException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadError = e.message;
        if (e.cancelled) _progress = null;
      });
    }
  }

  void _done() {
    final title = _title.text.trim();
    setState(() {
      _titleError = title.isEmpty
          ? 'Add a lesson title.'
          : title.length > CourseLesson.maxTitle
              ? 'Use at most ${CourseLesson.maxTitle} characters.'
              : null;
      _linkError = _source == _Source.link ? CourseLesson.validateLink(_link.text) : null;
      final m = _minutes.text.trim();
      _minutesError = m.isEmpty || ((int.tryParse(m) ?? 0) >= 1 && (int.tryParse(m) ?? 0) <= 1000) ? null : 'Whole minutes, 1 to 1000.';
    });
    if (_titleError != null || _linkError != null || _minutesError != null) return;
    if (_source == _Source.upload && _file == null) {
      setState(() => _uploadError = _uploading ? 'Wait for the upload to finish.' : 'Upload a video first.');
      return;
    }
    Get.back(
      result: CourseLesson(
        id: widget.lesson?.id,
        title: title,
        file: _source == _Source.upload ? _file : null,
        videoUrl: _source == _Source.link ? _link.text.trim() : null,
        durationMinutes: int.tryParse(_minutes.text.trim()),
        isPreview: _preview,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.lesson == null ? 'New video lesson' : 'Edit lesson', style: t.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            key: const Key('lessonTitle'),
            controller: _title,
            maxLength: CourseLesson.maxTitle,
            decoration: InputDecoration(labelText: 'Lesson title', errorText: _titleError, border: const OutlineInputBorder()),
          ),
          SegmentedButton<_Source>(
            segments: const [
              ButtonSegment(value: _Source.upload, icon: Icon(Icons.upload_rounded), label: Text('Upload video')),
              ButtonSegment(value: _Source.link, icon: Icon(Icons.link_rounded), label: Text('YouTube / Vimeo')),
            ],
            selected: {_source},
            onSelectionChanged: _uploading ? null : (s) => setState(() => _source = s.first),
          ),
          const SizedBox(height: 12),
          if (_source == _Source.link)
            TextField(
              key: const Key('lessonLink'),
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Video link',
                hintText: 'https://www.youtube.com/watch?v=…',
                errorText: _linkError,
                border: const OutlineInputBorder(),
              ),
            )
          else
            _uploadBox(t),
          const SizedBox(height: 12),
          TextField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Length in minutes (optional)',
              errorText: _minutesError,
              border: const OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Free preview'),
            subtitle: const Text('Anyone can watch this lesson before buying.'),
            value: _preview,
            onChanged: (v) => setState(() => _preview = v),
          ),
          Row(children: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('lessonDone'),
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: _uploading ? null : _done,
              child: const Text('Done'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _uploadBox(ThemeData t) {
    final name = _file?['name'] ?? _picked?.path.split('/').last;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _uploadError != null ? t.colorScheme.error : t.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (name != null) Text('$name', maxLines: 1, overflow: TextOverflow.ellipsis),
        if (_uploading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _progress, key: const Key('uploadProgress')),
          const SizedBox(height: 4),
          Row(children: [
            Text('${((_progress ?? 0) * 100).round()}%'),
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
              onPressed: () => _cancel?.cancel(),
              child: const Text('Cancel upload'),
            ),
          ]),
        ] else if (_uploadError != null) ...[
          const SizedBox(height: 6),
          Text(_uploadError!, style: TextStyle(color: t.colorScheme.error)),
          Row(children: [
            if (_picked != null)
              TextButton(
                key: const Key('uploadRetry'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
                onPressed: _upload,
                child: const Text('Retry'),
              ),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
              onPressed: _pick,
              child: const Text('Choose another'),
            ),
          ]),
        ] else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('pickVideo'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
              onPressed: _pick,
              icon: Icon(_file == null ? Icons.video_file_outlined : Icons.check_circle_rounded),
              label: Text(_file == null ? 'Choose a video (MP4, WebM, MOV, up to 500 MB)' : 'Uploaded – replace'),
            ),
          ),
      ]),
    );
  }
}
