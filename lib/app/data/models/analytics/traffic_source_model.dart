class TrafficSourceModel {
  final String source;
  final int count;
  final double revenue;
  final double percent;

  const TrafficSourceModel({required this.source, required this.count, required this.revenue, required this.percent});

  String get label => switch (source) {
        'marketplace_search' => 'Marketplace Search',
        'direct_link' => 'Direct Link',
        'social_media' => 'Social Media',
        'email' => 'Email',
        _ => 'Other',
      };

  factory TrafficSourceModel.fromJson(Map<String, dynamic> json) {
    return TrafficSourceModel(
      source: json['source'] as String? ?? 'other',
      count: json['count'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }
}
