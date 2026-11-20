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
