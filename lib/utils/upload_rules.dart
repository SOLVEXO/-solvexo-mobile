/// Mirrors the API's upload allowlists (`upload.service.ts`). The server is the
/// authority and re-checks extension + MIME; this keeps file pickers to what it
/// will accept and gives a clear message before a large upload starts.
class UploadRules {
  UploadRules._();

  /// `POST /upload/file` — images, video, audio, PDF and Office documents.
  /// SVG, HTML and JS are rejected.
  static const List<String> publicExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'avif', 'heic',
    'mp4', 'webm', 'mov', 'mp3', 'm4a', 'wav',
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv',
  ];

  /// `POST /upload/private-file` (files sold to buyers) — the public set plus
  /// the education formats.
  static const List<String> privateExtensions = [
    ...publicExtensions,
    'epub', 'zip', 'svg', 'odt', 'ods', 'odp', 'rtf', 'key', 'pages', 'numbers',
    'ogg',
  ];

  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  static bool isAllowedPublic(String fileName) =>
      publicExtensions.contains(extensionOf(fileName));

  static bool isAllowedPrivate(String fileName) =>
      privateExtensions.contains(extensionOf(fileName));

  static String notAllowedMessage(String fileName) {
    final ext = extensionOf(fileName);
    return 'Files of type ".${ext.isEmpty ? '?' : ext}" are not allowed.';
  }

  /// Content type for a multipart part, derived from the extension (the server
  /// checks it against the extension, so never label a non-image as `image/*`).
  static String mimeFromExtension(String fileName) {
    switch (extensionOf(fileName)) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'avif':
        return 'image/avif';
      case 'heic':
        return 'image/heic';
      case 'svg':
        return 'image/svg+xml';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'epub':
        return 'application/epub+zip';
      case 'zip':
        return 'application/zip';
      case 'rtf':
        return 'application/rtf';
      default:
        return 'application/octet-stream';
    }
  }
}
