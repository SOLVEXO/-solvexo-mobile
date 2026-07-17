/// One entry from `GET /api/search/recent` (`solvexo-api`'s `RecentSearch`
/// schema) — the id is needed for per-entry deletion.
class RecentSearchModel {
  final String searchId;
  final String query;

  const RecentSearchModel({required this.searchId, required this.query});

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) =>
      RecentSearchModel(
        searchId: (json['searchId'] ?? json['_id'] ?? '').toString(),
        query: json['query'] as String? ?? '',
      );
}
