import 'package:get/get.dart';

enum AnalyticsPeriod { today, sevenDays, thirtyDays, ninetyDays }

class BarEntry {
  final String label;
  final double value;
  const BarEntry(this.label, this.value);
}

class StatItem {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  const StatItem({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });
}

class TopProduct {
  final String name;
  final String emoji;
  final int orders;
  final double revenue;
  const TopProduct({
    required this.name,
    required this.emoji,
    required this.orders,
    required this.revenue,
  });
}

class AnalyticsData {
  final String revenueTitle;
  final double revenue;
  final String revenueChange;
  final bool revenuePositive;
  final List<BarEntry> bars;
  final List<StatItem> stats;
  final List<TopProduct> topProducts;

  const AnalyticsData({
    required this.revenueTitle,
    required this.revenue,
    required this.revenueChange,
    required this.revenuePositive,
    required this.bars,
    required this.stats,
    required this.topProducts,
  });
}

class SellerAnalyticsController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<AnalyticsPeriod> selectedPeriod = AnalyticsPeriod.sevenDays.obs;
  final Rx<AnalyticsData?> data = Rx(null);

  static const _topProducts = [
    TopProduct(name: 'Math Bundle', emoji: '📐', orders: 847, revenue: 4802),
    TopProduct(name: 'Fractions Kit', emoji: '➗', orders: 123, revenue: 2214),
    TopProduct(name: 'Figma UI Kit', emoji: '🎨', orders: 40, revenue: 1560),
  ];

  static const _dataset = {
    AnalyticsPeriod.today: AnalyticsData(
      revenueTitle: 'Revenue (Today)',
      revenue: 1240.00,
      revenueChange: '+5.2% vs yesterday',
      revenuePositive: true,
      bars: [
        BarEntry('9am', 80), BarEntry('11am', 210), BarEntry('1pm', 150),
        BarEntry('3pm', 330), BarEntry('5pm', 270), BarEntry('7pm', 200),
      ],
      stats: [
        StatItem(title: 'Orders', value: '38', change: '↑ +5%', isPositive: true),
        StatItem(title: 'Visitors', value: '1.8K', change: '↑ +3%', isPositive: true),
        StatItem(title: 'Conv. Rate', value: '1.8%', change: '↑ +0.1%', isPositive: true),
        StatItem(title: 'Avg Order', value: r'$32.63', change: r'↑ +$1.20', isPositive: true),
      ],
      topProducts: _topProducts,
    ),
    AnalyticsPeriod.sevenDays: AnalyticsData(
      revenueTitle: 'Revenue (Last 7 Days)',
      revenue: 8420.00,
      revenueChange: '+18.4% vs last week',
      revenuePositive: true,
      bars: [
        BarEntry('M', 900), BarEntry('T', 1200), BarEntry('W', 600),
        BarEntry('T', 1400), BarEntry('F', 800), BarEntry('S', 1100),
        BarEntry('S', 2420),
      ],
      stats: [
        StatItem(title: 'Orders', value: '284', change: '↑ +12%', isPositive: true),
        StatItem(title: 'Visitors', value: '14.2K', change: '↑ +8%', isPositive: true),
        StatItem(title: 'Conv. Rate', value: '2.0%', change: '↑ +0.3%', isPositive: true),
        StatItem(title: 'Avg Order', value: r'$29.65', change: r'↑ +$2.10', isPositive: true),
      ],
      topProducts: _topProducts,
    ),
    AnalyticsPeriod.thirtyDays: AnalyticsData(
      revenueTitle: 'Revenue (Last 30 Days)',
      revenue: 32140.00,
      revenueChange: '+9.1% vs last month',
      revenuePositive: true,
      bars: [
        BarEntry('W1', 7200), BarEntry('W2', 8100), BarEntry('W3', 6900),
        BarEntry('W4', 9940),
      ],
      stats: [
        StatItem(title: 'Orders', value: '1,084', change: '↑ +9%', isPositive: true),
        StatItem(title: 'Visitors', value: '54K', change: '↑ +14%', isPositive: true),
        StatItem(title: 'Conv. Rate', value: '2.1%', change: '↑ +0.4%', isPositive: true),
        StatItem(title: 'Avg Order', value: r'$29.65', change: r'↓ -$0.50', isPositive: false),
      ],
      topProducts: _topProducts,
    ),
    AnalyticsPeriod.ninetyDays: AnalyticsData(
      revenueTitle: 'Revenue (Last 90 Days)',
      revenue: 98500.00,
      revenueChange: '+22.3% vs last quarter',
      revenuePositive: true,
      bars: [
        BarEntry('M1', 28000), BarEntry('M2', 32140), BarEntry('M3', 38360),
      ],
      stats: [
        StatItem(title: 'Orders', value: '3,320', change: '↑ +22%', isPositive: true),
        StatItem(title: 'Visitors', value: '160K', change: '↑ +31%', isPositive: true),
        StatItem(title: 'Conv. Rate', value: '2.2%', change: '↑ +0.5%', isPositive: true),
        StatItem(title: 'Avg Order', value: r'$29.67', change: r'↑ +$2.70', isPositive: true),
      ],
      topProducts: _topProducts,
    ),
  };

  void setPeriod(AnalyticsPeriod period) {
    selectedPeriod.value = period;
    _load();
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    data.value = null;
    await Future.delayed(const Duration(milliseconds: 500));
    data.value = _dataset[selectedPeriod.value];
    isLoading.value = false;
  }

  Future<void> refreshData() async => _load();
}
