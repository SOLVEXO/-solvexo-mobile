enum RefundIssue {
  missing,
  notReceived,
  notAsDescribed,
  damaged,
  wrongItem,
  defective,
  counterfeit,
}

enum TrackingStatus {
  preparing,
  departed,
  arrivedSorting,
  arrivedHub,
  outForDelivery,
  delivered,
}

enum OrderStatus { unpaid, toShip, shipped, delivered }

enum OrderDeliveryStatus { process, deliver, inTransit, delivered }
