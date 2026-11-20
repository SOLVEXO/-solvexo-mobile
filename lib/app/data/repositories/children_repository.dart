import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// My children (B4). Backend 5adba44 src/children (api/children, role user).
// Rules (children.service.ts): name 1-60; gradeLabel = a class slug
// (class-3, o-level, ...) from which the server derives educationLevel;
// age 2-25 or null; up to 10 subjects, each <= 40; at most
// entitlements.childrenLimit children (8, Premium 15).

class Child {
  const Child({required this.id, required this.name, this.gradeLabel, this.age, this.subjects = const []});
  final String id, name;
  final String? gradeLabel;
  final int? age;
  final List<String> subjects;

  factory Child.fromJson(Map j) => Child(
        id: '${j['_id'] ?? ''}',
        name: '${j['name'] ?? ''}',
        gradeLabel: (j['gradeLabel'] as String?)?.isEmpty == true ? null : j['gradeLabel'] as String?,
        age: (j['age'] as num?)?.toInt(),
        subjects: (j['subjects'] as List?)?.map((e) => '$e').toList() ?? const [],
      );

  Map<String, dynamic> toBody() => {
        'name': name.trim(),
        if (gradeLabel != null) 'gradeLabel': gradeLabel,
        'age': age,
        'subjects': subjects,
      };
}

class ChildrenRepository {
  ChildrenRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  /// Throws on failure.
  Future<List<Child>> list() async {
    final d = (await _client.get(ApiConstants.children, requiresAuth: true)).data;
    final list = d is Map && d['data'] is List ? d['data'] as List : const [];
    return list.whereType<Map>().map(Child.fromJson).toList();
  }

  /// Null = OK, else the server's message (e.g. "You can save up to 8 children").
  Future<String?> save(Child c) async {
    try {
      c.id.isEmpty
          ? await _client.post(ApiConstants.children, data: c.toBody(), requiresAuth: true)
          : await _client.patch(ApiConstants.child(c.id), data: c.toBody(), requiresAuth: true);
      return null;
    } on DioException catch (e) {
      return ApiError.fromDio(e) ?? 'Could not save.';
    }
  }

  Future<String?> remove(String id) async {
    try {
      await _client.delete(ApiConstants.child(id), requiresAuth: true);
      return null;
    } on DioException catch (e) {
      return ApiError.fromDio(e) ?? 'Could not delete.';
    }
  }
}
