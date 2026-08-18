class BookingStatusCount {
  final String status;
  final int count;

  const BookingStatusCount({required this.status, required this.count});

  factory BookingStatusCount.fromJson(Map<String, dynamic> json) {
    return BookingStatusCount(
      status: json['status'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class BookingsDashboardModel {
  final int todayCount;
  final int upcomingCount;
  final int completedThisMonth;
  final int cancelledThisMonth;
  final double revenueThisMonthUSD;
  final List<BookingStatusCount> statusBreakdown;

  const BookingsDashboardModel({
    this.todayCount = 0,
    this.upcomingCount = 0,
    this.completedThisMonth = 0,
    this.cancelledThisMonth = 0,
    this.revenueThisMonthUSD = 0,
    this.statusBreakdown = const [],
  });

  static const empty = BookingsDashboardModel();

  factory BookingsDashboardModel.fromJson(Map<String, dynamic> json) {
    return BookingsDashboardModel(
      todayCount: (json['todayCount'] as num?)?.toInt() ?? 0,
      upcomingCount: (json['upcomingCount'] as num?)?.toInt() ?? 0,
      completedThisMonth: (json['completedThisMonth'] as num?)?.toInt() ?? 0,
      cancelledThisMonth: (json['cancelledThisMonth'] as num?)?.toInt() ?? 0,
      revenueThisMonthUSD: (json['revenueThisMonthUSD'] as num?)?.toDouble() ?? 0,
      statusBreakdown: (json['statusBreakdown'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(BookingStatusCount.fromJson)
          .toList(),
    );
  }
}
