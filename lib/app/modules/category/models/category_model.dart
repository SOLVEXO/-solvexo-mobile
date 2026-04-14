class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// class CategoryModel {
//   final String id;
//   final String name;
//   final String? description;
//   final String? image;
//   final String? parentId;
//   final int sortOrder;
//   final String status;
//   final bool isDelete;
//   final List<CategoryModel> children;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     this.description,
//     this.image,
//     this.parentId,
//     required this.sortOrder,
//     required this.status,
//     required this.isDelete,
//     required this.children,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     try {
//       return CategoryModel(
//         id: json['_id'] ?? '',
//         name: json['name'] ?? '',
//         description: json['description'],
//         image: json['image'],
//         parentId: json['parentId'],
//         sortOrder: json['sortOrder'] ?? 0,
//         status: json['status'] ?? 'inactive',
//         isDelete: json['isDelete'] ?? false,

//         // 🔥 RECURSIVE PARSING
//         children: (json['children'] as List? ?? [])
//             .map((child) => CategoryModel.fromJson(child))
//             .toList(),

//         createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
//             DateTime.now(),
//         updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
//             DateTime.now(),
//       );
//     } catch (e) {
//       throw Exception("CategoryModel parsing error: $e");
//     }
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'description': description,
//       'image': image,
//       'parentId': parentId,
//       'sortOrder': sortOrder,
//       'status': status,
//       'isDelete': isDelete,
//       'children': children.map((e) => e.toJson()).toList(),
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
// }
