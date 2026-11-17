// GET /api/store/:storeId/dashboard-summary (docs Part B 6.2; checklist #10).
// Live shape for the test store (2026-11-17), all amounts from the server:
// {actionItems:{ordersToShip, ordersOverdue, returnsPending, unreadMessages,
//  unansweredQuestions, pendingReview, rejected, payoutMissing},
//  overview:{period:{from,to}, timezone:'Asia/Karachi', currency:'PKR',
//  bookedValue, collected, grossRevenue, totalRevenue, totalOrders,
//  freeClaims, avgOrderValue, repeatBuyerPercent, totalRefunds,
//  refundRatePercent, cancelledOrders, newCustomersCount,
//  returningCustomersCount}, revenueSeries:[{date, grossRevenue,
//  netRevenue}], today:{revenue, revenueChangePercent, ordersCount,
//  avgOrderValue, freeClaims}, totalProducts, activeProducts, shelf:[],
//  checklist:{steps:[{key,label,done,notNeeded?,path}], completed, total,
//  percent, allDone}, profile:{percent, complete, items:[...]},
//  premium:{premiumOrders, byCurrency, windowDays}}

num _n(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;
Map<String, dynamic> _m(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : const {};

class DashboardActions {
  const DashboardActions(this.raw);
  final Map<String, dynamic> raw;

  int get ordersToShip => _n(raw['ordersToShip']).toInt();
  int get ordersOverdue => _n(raw['ordersOverdue']).toInt();
  int get returnsPending => _n(raw['returnsPending']).toInt();
  int get unreadMessages => _n(raw['unreadMessages']).toInt();
  int get unansweredQuestions => _n(raw['unansweredQuestions']).toInt();
  int get pendingReview => _n(raw['pendingReview']).toInt();
  int get rejected => _n(raw['rejected']).toInt();
  int get payoutMissing => _n(raw['payoutMissing']).toInt();

  /// Docs 6.2: action count = to ship + overdue.
  int get shippingActions => ordersToShip + ordersOverdue;
}

class DashboardOverview {
  const DashboardOverview(this.raw);
  final Map<String, dynamic> raw;

  String get currency => raw['currency']?.toString() ?? '';
  String get timezone => raw['timezone']?.toString() ?? '';
  num get bookedValue => _n(raw['bookedValue']);
  num get collected => _n(raw['collected']);
  num get totalOrders => _n(raw['totalOrders']);
  num get freeClaims => _n(raw['freeClaims']);
  num get avgOrderValue => _n(raw['avgOrderValue']);
  num get refundRatePercent => _n(raw['refundRatePercent']);
  DateTime? get from => DateTime.tryParse('${_m(raw['period'])['from'] ?? ''}');
  DateTime? get to => DateTime.tryParse('${_m(raw['period'])['to'] ?? ''}');
}

class DashboardToday {
  const DashboardToday(this.raw);
  final Map<String, dynamic> raw;
  num get revenue => _n(raw['revenue']);
  num? get revenueChangePercent => raw['revenueChangePercent'] is num ? raw['revenueChangePercent'] as num : null;
  int get ordersCount => _n(raw['ordersCount']).toInt();
  num get avgOrderValue => _n(raw['avgOrderValue']);
  int get freeClaims => _n(raw['freeClaims']).toInt();
}

class ChecklistStep {
  const ChecklistStep({
    required this.key,
    required this.label,
    required this.done,
    required this.notNeeded,
    required this.path,
  });
  final String key;
  final String label;
  final bool done;
  final bool notNeeded;
  final String path;

  factory ChecklistStep.fromJson(Map<String, dynamic> j) => ChecklistStep(
        key: j['key']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        done: j['done'] == true,
        notNeeded: j['notNeeded'] == true,
        path: j['path']?.toString() ?? '',
      );
}

class DashboardSummary {
  const DashboardSummary({
    required this.actions,
    required this.overview,
    required this.today,
    required this.steps,
    required this.checklistPercent,
    required this.checklistDone,
    required this.totalProducts,
    required this.activeProducts,
  });

  final DashboardActions actions;
  final DashboardOverview overview;
  final DashboardToday today;
  final List<ChecklistStep> steps;
  final int checklistPercent;
  final bool checklistDone;
  final int totalProducts;
  final int activeProducts;

  factory DashboardSummary.fromJson(Map<String, dynamic> body) {
    final d = body['data'] is Map ? Map<String, dynamic>.from(body['data'] as Map) : body;
    final checklist = _m(d['checklist']);
    return DashboardSummary(
      actions: DashboardActions(_m(d['actionItems'])),
      overview: DashboardOverview(_m(d['overview'])),
      today: DashboardToday(_m(d['today'])),
      steps: (checklist['steps'] is List ? checklist['steps'] as List : const [])
          .whereType<Map>()
          .map((s) => ChecklistStep.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
      checklistPercent: _n(checklist['percent']).toInt(),
      checklistDone: checklist['allDone'] == true,
      totalProducts: _n(d['totalProducts']).toInt(),
      activeProducts: _n(d['activeProducts']).toInt(),
    );
  }
}
