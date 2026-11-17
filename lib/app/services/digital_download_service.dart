import 'dart:typed_data';

import 'package:book_store_app/app/data/models/orders/digital_download_file_model.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

/// One place for "download a purchased digital item" (Library + My Orders):
/// fetch short-lived signed links, let the buyer pick when there are several
/// files, then hand the bytes to the OS share sheet (save to Files, open in a
/// PDF reader, send to WhatsApp...). Files never sit in a public folder.
class DigitalDownloadService {
  DigitalDownloadService({OrderRepository? repository})
      : _repo = repository ?? OrderRepository();

  final OrderRepository _repo;

  /// Item ids currently preparing, so buttons can show progress.
  final RxSet<String> busy = <String>{}.obs;

  bool isBusy(String key) => busy.contains(key);

  Future<void> download({
    required String busyKey,
    required String orderId,
    required String productId,
  }) async {
    if (busy.contains(busyKey)) return;
    busy.add(busyKey);
    try {
      final files = await _repo.getDigitalDownloadLinks(
        orderId: orderId,
        productId: productId,
      );
      if (files.isEmpty) return;
      if (files.length == 1) {
        await _share(files.first);
      } else {
        final picked = await _pick(files);
        if (picked != null) await _share(picked);
      }
    } finally {
      busy.remove(busyKey);
    }
  }

  Future<DigitalDownloadFile?> _pick(List<DigitalDownloadFile> files) {
    return Get.bottomSheet<DigitalDownloadFile>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Choose a file',
                style: Get.textTheme.titleMedium),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: files.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = files[i];
                  return ListTile(
                    leading: Icon(
                      f.mimeType.contains('pdf')
                          ? Icons.picture_as_pdf_outlined
                          : Icons.insert_drive_file_outlined,
                    ),
                    title: Text(f.fileName),
                    subtitle: f.size == null ? null : Text(_size(f.size!)),
                    onTap: () => Get.back(result: f),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      isScrollControlled: true,
    );
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _share(DigitalDownloadFile file) async {
    final bytes = await _repo.fetchDigitalFileBytes(file);
    if (bytes == null) return;
    final xfile = XFile.fromData(
      Uint8List.fromList(bytes),
      name: file.fileName,
      mimeType: file.mimeType,
    );
    await SharePlus.instance.share(
      ShareParams(files: [xfile], subject: file.fileName),
    );
  }
}
