/// One downloadable file from a purchased digital product, as returned by
/// `GET /api/orders/download-url`. [token] is a short-lived (10-minute) JWT —
/// the actual bytes are fetched via [endpoint] (relative, e.g.
/// `/api/orders/download-file`) with [token] as a query param.
class DigitalDownloadFile {
  final int index;
  final String fileName;
  final String mimeType;
  final int? size;
  final String type; // 'stamped' | 'download'
  final String endpoint;
  final String token;

  const DigitalDownloadFile({
    required this.index,
    required this.fileName,
    required this.mimeType,
    this.size,
    required this.type,
    required this.endpoint,
    required this.token,
  });

  factory DigitalDownloadFile.fromJson(Map<String, dynamic> json) => DigitalDownloadFile(
        index: json['index'] as int? ?? 0,
        fileName: json['fileName'] as String? ?? 'file',
        mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
        size: json['size'] as int?,
        type: json['type'] as String? ?? 'download',
        endpoint: json['endpoint'] as String? ?? '',
        token: json['token'] as String? ?? '',
      );
}
