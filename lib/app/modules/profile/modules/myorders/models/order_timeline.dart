import 'package:book_store_app/utils/enums.dart';

class OrderTimeline {
  final OrderDeliveryStatus status;
  final String title;
  final String description;

  OrderTimeline({
    required this.status,
    required this.title,
    required this.description,
  });
}
