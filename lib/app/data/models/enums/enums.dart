enum RefundIssue {
  missing,
  notReceived,
  wrongItem,
  damaged,
  defective,
  notAsDescribed,
  counterfeit,
}

extension RefundIssueExtension on RefundIssue {
  String get apiValue {
    switch (this) {
      case RefundIssue.missing:
        return "missing";
      case RefundIssue.notReceived:
        return "not_received";
      case RefundIssue.wrongItem:
        return "wrong_item";
      case RefundIssue.damaged:
        return "damaged";
      case RefundIssue.defective:
        return "defective";
      case RefundIssue.notAsDescribed:
        return "not_as_described";
      case RefundIssue.counterfeit:
        return "counterfeit";
    }
  }
}

enum TrackingStatus {
  preparing,
  departed,
  arrivedSorting,
  arrivedHub,
  outForDelivery,
  delivered,
}

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

enum OrderDeliveryStatus { process, deliver, inTransit, delivered }
