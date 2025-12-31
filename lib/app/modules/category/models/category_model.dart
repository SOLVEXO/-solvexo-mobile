class CategoryModel {
  final String title;
  final String icon;

  // child subcategories (right side)
  final List<String> children;

  CategoryModel({
    required this.title,
    required this.icon,
    required this.children,
  });
}
