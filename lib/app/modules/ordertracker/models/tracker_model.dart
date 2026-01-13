import 'package:book_store_app/app/data/models/enums/enums.dart';

class TrackingEvent {
  final TrackingStatus status;
  final String title;
  final String description;
  final DateTime time;

  TrackingEvent({
    required this.status,
    required this.title,
    required this.description,
    required this.time,
  });
}
